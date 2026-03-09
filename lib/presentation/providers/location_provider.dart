import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocationState {
  final bool useGPS;
  final String city;
  final String country;
  final String? gpsCoordinates;
  final bool isLoading;
  final String? error;

  LocationState({
    required this.useGPS,
    required this.city,
    required this.country,
    this.gpsCoordinates,
    this.isLoading = false,
    this.error,
  });

  String get query => '$city,$country';

  LocationState copyWith({
    bool? useGPS,
    String? city,
    String? country,
    String? gpsCoordinates,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      useGPS: useGPS ?? this.useGPS,
      city: city ?? this.city,
      country: country ?? this.country,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LocationNotifier extends Notifier<LocationState>
    with WidgetsBindingObserver {
  static const Duration _autoRefreshInterval = Duration(minutes: 30);

  bool _isRefreshDue(Box box, {Duration maxAge = _autoRefreshInterval}) {
    final ts = box.get('prayer_location_last_refresh_ms');
    if (ts is! int) return true;
    final last = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(last) > maxAge;
  }

  @override
  LocationState build() {
    final box = Hive.box('settings');
    const useGPS = true;
    final city = box.get('prayer_city', defaultValue: 'Rabat');
    final country = box.get('prayer_country', defaultValue: 'Morocco');
    final coords = box.get('prayer_coords');

    WidgetsBinding.instance.addObserver(this);

    final shouldAutoRefresh = coords == null || _isRefreshDue(box);
    if (shouldAutoRefresh) {
      Future.microtask(() => refreshLocation(requestPermissionIfNeeded: false));
    }

    final subscription = Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.enabled) {
        debugPrint(
          '[LocationNotifier] Location service enabled, refreshing silently.',
        );
        refreshLocation(requestPermissionIfNeeded: false, force: true);
      }
    });

    ref.onDispose(() {
      subscription.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });

    return LocationState(
      useGPS: useGPS,
      city: city,
      country: country,
      gpsCoordinates: coords,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final box = Hive.box('settings');
      if (_isRefreshDue(box, maxAge: const Duration(minutes: 45))) {
        debugPrint('[LocationNotifier] App resumed, stale cache -> refresh.');
        refreshLocation(requestPermissionIfNeeded: false);
      }
    }
  }

  Future<void> _saveSettings() async {
    final box = Hive.box('settings');
    await box.put('prayer_use_gps', true);
    await box.put('prayer_city', state.city);
    await box.put('prayer_country', state.country);
    if (state.gpsCoordinates != null) {
      await box.put('prayer_coords', state.gpsCoordinates);
    }
    await box.put(
      'prayer_location_last_refresh_ms',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> toggleGPS(bool enabled) async {
    if (!enabled) return;
    state = state.copyWith(useGPS: true);
    await refreshLocation(force: true, requestPermissionIfNeeded: true);
  }

  Future<void> refreshLocation({
    bool force = false,
    bool requestPermissionIfNeeded = true,
  }) async {
    if (state.isLoading) return;

    final box = Hive.box('settings');
    if (!force && state.gpsCoordinates != null && !_isRefreshDue(box)) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (!requestPermissionIfNeeded) {
          state = state.copyWith(isLoading: false, error: null);
          return;
        }
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(isLoading: false, error: 'Permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error: requestPermissionIfNeeded
              ? 'Permission permanently denied'
              : null,
        );
        return;
      }

      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: requestPermissionIfNeeded ? 'GPS service is disabled' : null,
        );
        return;
      }

      Position? position = await Geolocator.getLastKnownPosition();

      try {
        // Try to get a fresh fix; if it fails we keep last-known position.
        final fresh = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
        position = fresh;
      } catch (e) {
        debugPrint('[LocationNotifier] Fresh location unavailable: $e');
      }

      if (position == null) {
        state = state.copyWith(
          isLoading: false,
          error: requestPermissionIfNeeded ? 'Could not get location' : null,
        );
        return;
      }

      String? resolvedCity;
      String? resolvedCountry;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          resolvedCity = place.locality ?? place.subAdministrativeArea;
          resolvedCountry = place.country;
        }
      } catch (e) {
        debugPrint('[LocationNotifier] Geocoding failed: $e');
      }

      state = state.copyWith(
        useGPS: true,
        gpsCoordinates: '${position.latitude},${position.longitude}',
        city: resolvedCity ?? state.city,
        country: resolvedCountry ?? state.country,
        isLoading: false,
        error: null,
      );
      await _saveSettings();
    } catch (e) {
      debugPrint('[LocationNotifier] refreshLocation failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: requestPermissionIfNeeded ? e.toString() : null,
      );
    }
  }
}

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(() {
  return LocationNotifier();
});
