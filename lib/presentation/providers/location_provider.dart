import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
  @override
  LocationState build() {
    // Initial state
    final box = Hive.box('settings');
    // Force GPS usage
    const useGPS = true;
    final city = box.get('prayer_city', defaultValue: 'Rabat');
    final country = box.get('prayer_country', defaultValue: 'Morocco');
    final coords = box.get('prayer_coords');

    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Trigger async refresh always
    Future.delayed(Duration.zero, () => refreshLocation());

    // Listen for service status changes
    final serviceStatusStream = Geolocator.getServiceStatusStream();
    final subscription = serviceStatusStream.listen((status) {
      if (status == ServiceStatus.enabled) {
        debugPrint('📍 GPS Service enabled by user - Refreshing location...');
        refreshLocation();
      }
    });

    // Cleanup subscription and observer on dispose
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
      debugPrint('📍 App resumed - Checking location...');
      refreshLocation();
    }
  }

  Future<void> _saveSettings() async {
    final box = Hive.box('settings');
    await box.put('prayer_use_gps', true); // Always true
    await box.put('prayer_city', state.city);
    await box.put('prayer_country', state.country);
    if (state.gpsCoordinates != null) {
      await box.put('prayer_coords', state.gpsCoordinates);
    }
  }

  Future<void> toggleGPS(bool enabled) async {
    // GPS is always enabled.
    if (!enabled) return;
    state = state.copyWith(useGPS: true);
    await refreshLocation();
  }

  Future<void> refreshLocation() async {
    // Prevent multiple simultaneous refreshes
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Permission checks
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(isLoading: false, error: 'Permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error: 'Permission permanently denied',
        );
        return;
      }

      // Check if service is enabled
      bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'GPS service is disabled',
        );
        return;
      }

      // Try last known position first as a quick fallback
      Position? position = await Geolocator.getLastKnownPosition();

      // If no last known or we want fresh, try current with timeout
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (e) {
        debugPrint('Location timeout or error, using last known: $e');
        // position remains lastKnown if getCurrentPosition fails
      }

      if (position == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not get location',
        );
        return;
      }

      // Resolve city/country
      String? resolvedCity;
      String? resolvedCountry;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          resolvedCity = place.locality ?? place.subAdministrativeArea;
          resolvedCountry = place.country;
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }

      state = state.copyWith(
        useGPS: true,
        gpsCoordinates: '${position.latitude},${position.longitude}',
        city: resolvedCity ?? state.city,
        country: resolvedCountry ?? state.country,
        isLoading: false,
      );
      await _saveSettings();
    } catch (e) {
      debugPrint('Location refresh error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(() {
  return LocationNotifier();
});
