import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  // Save Data
  static Future<void> saveData(
    String boxName,
    String key,
    dynamic value,
  ) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, value);
  }

  // Get Data
  static Future<dynamic> getData(
    String boxName,
    String key,
  ) async {
    final box = await Hive.openBox(boxName);
    return box.get(key);
  }

  // Delete Data
  static Future<void> deleteData(
    String boxName,
    String key,
  ) async {
    final box = await Hive.openBox(boxName);
    await box.delete(key);
  }

  // Clear Box
  static Future<void> clearBox(
    String boxName,
  ) async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }
}