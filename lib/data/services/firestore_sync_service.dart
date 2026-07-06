import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/tasbeeh_model.dart';
import 'package:islam_home/data/models/khatma_v2_models.dart';
import 'package:islam_home/data/models/tasbeeh_log.dart';

final firestoreSyncServiceProvider = Provider<FirestoreSyncService>(
  (ref) => FirestoreSyncService(),
);

class FirestoreSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Initial migration from local Hive to Firestore
  Future<void> syncLocalToCloud() async {
    final uid = _uid;
    if (uid == null) return;

    debugPrint(
      'FirestoreSyncService: Starting initial migration for UID: $uid',
    );

    try {
      // 1. Sync Tasbeeh
      final tasbeehBox = Hive.box<TasbeehModel>('tasbeeh_box');
      for (var item in tasbeehBox.values) {
        await saveUserData(
          collection: 'tasbeeh',
          docId: item.id,
          data: item.toJson(),
        );
      }

      // 2. Sync Tasbeeh History
      final historyBox = Hive.box<TasbeehLog>('tasbeeh_history_box');
      for (var key in historyBox.keys) {
        final item = historyBox.get(key);
        if (item != null) {
          await saveUserData(
            collection: 'tasbeeh_history',
            docId: key.toString(),
            data: item.toJson(),
          );
        }
      }

      // 3. Sync Khatma
      final khatmaBox = Hive.box<KhatmaTrack>('khatma_tracks_box');
      for (var item in khatmaBox.values) {
        await saveUserData(
          collection: 'khatma',
          docId: item.id,
          data: item.toJson(),
        );
      }

      // 4. Sync Favorites
      final favBox = Hive.box('favorites');
      final categories = [
        'reciters',
        'surahs',
        'ayahs',
        'playlists',
        'hadiths',
        'tafsir',
        'seerah',
      ];
      for (var cat in categories) {
        final json = favBox.get(cat);
        if (json != null) {
          final list = jsonDecode(json);
          final timestamp = favBox.get('${cat}_timestamp');
          await saveUserData(
            collection: 'favorites',
            docId: cat,
            data: {
              'items': list,
              'lastUpdated': timestamp ?? DateTime.now().toIso8601String(),
            },
          );
        }
      }

      // 5. Sync Settings
      final settingsBox = Hive.box('settings');
      final appSettings = <String, dynamic>{};
      for (var key in settingsBox.keys) {
        appSettings[key.toString()] = settingsBox.get(key);
      }
      if (appSettings.isNotEmpty) {
        await syncSettings(appSettings);
      }

      debugPrint(
        'FirestoreSyncService: Initial migration completed successfully',
      );
    } catch (e) {
      debugPrint('FirestoreSyncService: Initial migration failed: $e');
    }
  }

  /// Generic method to save a document with a server timestamp
  Future<void> saveUserData({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection(collection)
          .doc(docId)
          .set({
            ...data,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreSyncService: saveUserData error: $e');
    }
  }

  /// Generic method to stream user-specific collection data
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserCollectionStream(
    String collection, {
    String? uid,
  }) {
    final effectiveUid = uid ?? _uid;
    if (effectiveUid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(effectiveUid)
        .collection(collection)
        .orderBy('lastUpdated', descending: true)
        .snapshots();
  }

  /// Syncs app settings to the cloud
  Future<void> syncSettings(Map<String, dynamic> settings) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).set({
        'settings': settings,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreSyncService: syncSettings error: $e');
    }
  }

  /// Fetches cloud settings
  Future<Map<String, dynamic>?> getCloudSettings() async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['settings'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('FirestoreSyncService: getCloudSettings error: $e');
    }
    return null;
  }

  /// Fetches the dynamic inspiration pool for the home screen
  Future<List<Map<String, dynamic>>> getDailyVerses() async {
    try {
      final snapshot = await _firestore.collection('daily_verses').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('FirestoreSyncService: getDailyVerses error: $e');
      return [];
    }
  }

  /// Fetches the system config (Maintenance Mode, etc.)
  Future<Map<String, dynamic>?> getSystemConfig() async {
    try {
      final doc = await _firestore.collection('system').doc('config').get();
      return doc.data();
    } catch (e) {
      debugPrint('FirestoreSyncService: getSystemConfig error: $e');
      return null;
    }
  }
}
