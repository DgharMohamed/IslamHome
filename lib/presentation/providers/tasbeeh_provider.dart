import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/tasbeeh_model.dart';
import 'package:islam_home/data/services/auth_service.dart';
import 'package:islam_home/data/services/tasbeeh_service.dart';
import 'package:islam_home/data/services/firestore_sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

final tasbeehServiceProvider = Provider((ref) => TasbeehService());

final tasbeehListProvider =
    NotifierProvider<TasbeehNotifier, List<TasbeehModel>>(TasbeehNotifier.new);

class TasbeehNotifier extends Notifier<List<TasbeehModel>> {
  TasbeehService get _service => ref.read(tasbeehServiceProvider);
  FirestoreSyncService get _syncService => ref.read(firestoreSyncServiceProvider);
  FirebaseAuth get _auth => FirebaseAuth.instance;
  StreamSubscription? _cloudSubscription;
  String? _listeningUid;

  @override
  List<TasbeehModel> build() {
    ref.onDispose(() => _cloudSubscription?.cancel());
    ref.listen(authStateProvider, (previous, next) {
      _listenToCloudChanges(next.asData?.value?.uid);
    });

    // Hive boxes are opened in main.dart; still guard against corrupted local data.
    try {
      final initialData = _service.getDhikrList();
      _listenToCloudChanges(_auth.currentUser?.uid);
      return initialData;
    } catch (e) {
      debugPrint('TasbeehNotifier: failed to load dhikr list: $e');
      return const [];
    }
  }

  void _listenToCloudChanges(String? uid) {
    if (_listeningUid == uid) return;

    _cloudSubscription?.cancel();
    _cloudSubscription = null;
    _listeningUid = uid;
    if (uid == null) return;

    _cloudSubscription = _syncService
        .getUserCollectionStream('tasbeeh', uid: uid)
        .listen((snapshot) {
      bool localUpdated = false;
      final currentList = List<TasbeehModel>.from(state);

      for (var doc in snapshot.docs) {
        final cloudDhikr = TasbeehModel.fromJson(doc.data());
        final index = currentList.indexWhere((d) => d.id == cloudDhikr.id);

        if (index != -1) {
          final localDhikr = currentList[index];
          // Only update if cloud version is newer
          final cloudTime = cloudDhikr.lastUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);
          final localTime = localDhikr.lastUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);
          
          if (cloudTime.isAfter(localTime)) {
            currentList[index] = cloudDhikr;
            _service.updateDhikr(cloudDhikr);
            localUpdated = true;
          }
        } else {
          // New dhikr from cloud
          currentList.add(cloudDhikr);
          _service.updateDhikr(cloudDhikr);
          localUpdated = true;
        }
      }

      if (localUpdated) {
        state = currentList;
      }
    }, onError: (Object error) {
      debugPrint('TasbeehNotifier: cloud listener error: $error');
    });
  }

  Future<void> increment(String id) async {
    if (state.isEmpty) return;
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;
    final dhikr = state[index];
    final newCount = dhikr.count + 1;
    final isTargetReached = newCount >= dhikr.target;

    state = [
      for (final d in state)
        if (d.id == id)
          d.copyWith(
            count: isTargetReached ? 0 : newCount,
            totalCount: d.totalCount + 1,
          )
        else
          d,
    ];

    final updatedDhikr = state.firstWhere((d) => d.id == id).copyWith(lastUpdated: DateTime.now());
    
    // Update local state with the one having the new timestamp
    state = [
      for (final d in state)
        if (d.id == id) updatedDhikr else d,
    ];

    await _service.updateDhikr(updatedDhikr);
    await _service.incrementTotalCount();

    // Sync to Firestore if logged in
    if (_auth.currentUser != null) {
      await _syncService.saveUserData(
        collection: 'tasbeeh',
        docId: id,
        data: updatedDhikr.toJson(),
      );
    }

    // Log the increment, and if target reached, log as a completed set
    await _service.logIncrement(
      id,
      count: isTargetReached ? dhikr.target : 1,
      isSetComplete: isTargetReached,
    );

    if (isTargetReached) {
      // Switch to next dhikr
      final currentIndex = state.indexWhere((d) => d.id == id);
      final nextIndex = (currentIndex + 1) % state.length;
      ref.read(activeDhikrProvider.notifier).set(state[nextIndex].id);
    }
  }

  Future<void> reset(String id) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;
    state = [
      for (final dhikr in state)
        if (dhikr.id == id) dhikr.copyWith(count: 0) else dhikr,
    ];

    final updatedDhikr = state[index].copyWith(lastUpdated: DateTime.now());
    state = [
      for (final dhikr in state)
        if (dhikr.id == id) updatedDhikr else dhikr,
    ];
    await _service.updateDhikr(updatedDhikr);

    if (_auth.currentUser != null) {
      await _syncService.saveUserData(
        collection: 'tasbeeh',
        docId: id,
        data: updatedDhikr.toJson(),
      );
    }
  }

  Future<void> updateTarget(String id, int target) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;
    final safeTarget = target < 1 ? 1 : target;
    final updatedDhikr = state[index].copyWith(
      target: safeTarget,
      lastUpdated: DateTime.now(),
    );
    state = [
      for (final dhikr in state)
        if (dhikr.id == id) updatedDhikr else dhikr,
    ];

    await _service.updateDhikr(updatedDhikr);

    if (_auth.currentUser != null) {
      await _syncService.saveUserData(
        collection: 'tasbeeh',
        docId: id,
        data: updatedDhikr.toJson(),
      );
    }
  }

  int getTotalCount() {
    try {
      return _service.getTotalCount();
    } catch (e) {
      debugPrint('TasbeehNotifier: Error getting total count: $e');
      return 0;
    }
  }
}

final activeDhikrProvider = NotifierProvider<ActiveDhikrNotifier, String?>(
  ActiveDhikrNotifier.new,
);

class ActiveDhikrNotifier extends Notifier<String?> {
  static const String _activeDhikrKey = 'active_dhikr_id';
  static const String _defaultDhikrId = 'subhanallah';

  @override
  String? build() {
    final box = Hive.box('settings_box');
    final raw = box.get(_activeDhikrKey);
    if (raw is String && raw.isNotEmpty) {
      return raw;
    }
    return _defaultDhikrId;
  }

  void set(String? id) {
    if (state != id) {
      final safeId = (id == null || id.isEmpty) ? _defaultDhikrId : id;
      state = safeId;
      Hive.box('settings_box').put(_activeDhikrKey, safeId);
    }
  }
}
