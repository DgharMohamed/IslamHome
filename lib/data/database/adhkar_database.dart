import 'package:hive/hive.dart';
import 'package:islam_home/data/models/adhkar_model.dart';

class AdhkarDatabase {
  static const String adhkarBoxName = 'adhkarBox';
  static const String favoriteBoxName = 'favoriteBox';
  static const String progressBoxName = 'progressBox';
  static const String metaBoxName = 'adhkarMetaBox';

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(60)) {
      Hive.registerAdapter(AdhkarModelAdapter());
    }

    if (!Hive.isBoxOpen(adhkarBoxName)) {
      await Hive.openBox<AdhkarModel>(adhkarBoxName);
    }
    if (!Hive.isBoxOpen(favoriteBoxName)) {
      await Hive.openBox<bool>(favoriteBoxName);
    }
    if (!Hive.isBoxOpen(progressBoxName)) {
      await Hive.openBox<int>(progressBoxName);
    }
    if (!Hive.isBoxOpen(metaBoxName)) {
      await Hive.openBox(metaBoxName);
    }
  }

  static Box<AdhkarModel> get adhkarBox => Hive.box<AdhkarModel>(adhkarBoxName);
  static Box<bool> get favoriteBox => Hive.box<bool>(favoriteBoxName);
  static Box<int> get progressBox => Hive.box<int>(progressBoxName);
  static Box get metaBox => Hive.box(metaBoxName);
}
