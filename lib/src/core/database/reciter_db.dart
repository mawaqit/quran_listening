
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const reciterListIds = 'RECITER_IDS';
const DownloadedRecitationPath = 'DOWNLOADED_RECITATION_PATH';

String surahListIds(String id) => '${id}_SURAH_IDS';

class ReciterDB {
  static void cleanAll() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }

  static Future<bool> getDebuggingMenuSetting(String key) async {
    final db = await SharedPreferences.getInstance();
    return db.getBool(key) ?? false;
  }

  static Future<bool> setDebuggingMenuSetting(String key, bool val) async {
    final db = await SharedPreferences.getInstance();
    return db.setBool(key, val);
  }

  static Future<List<String>> getRecitersIds() async {
    try {
      final db = await SharedPreferences.getInstance();
      final List<String>? data = db.getStringList(reciterListIds);
      if (data == null) {
        return [];
      }

      return data;
    } on Exception catch (error) {
      debugPrint(error.toString());

      return [];
    }
  }

  static Future<bool> addReciter(String uuid) async {
    final db = await SharedPreferences.getInstance();
    final listRecitersIds = await getRecitersIds();
    if (listRecitersIds.contains(uuid)) {
      return false;
    } else {
      listRecitersIds.add(uuid);
      db.setStringList(reciterListIds, listRecitersIds);
      return true;
    }
  }

  static Future<bool> removeReciter(String uuid) async {
    final db = await SharedPreferences.getInstance();
    final listRecitersIds = await getRecitersIds();
    if (listRecitersIds.contains(uuid)) {
      listRecitersIds.remove(uuid);
      db.setStringList(reciterListIds, listRecitersIds);
      return true;
    }
    return false;
  }

  static Future<List<String>> getFavoriteSurahs(String reciterUuid) async {
    try {
      final db = await SharedPreferences.getInstance();
      final List<String>? data = db.getStringList(surahListIds(reciterUuid));
      if (data == null) {
        return [];
      }
      return data;
    } on Exception catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  static Future<bool> addSurahToFav(String reciterUuid, String uuid) async {
    final db = await SharedPreferences.getInstance();
    final listRecitersIds = await getFavoriteSurahs(reciterUuid);
    if (listRecitersIds.contains(uuid)) {
      return false;
    } else {
      listRecitersIds.add(uuid);
      db.setStringList(surahListIds(reciterUuid), listRecitersIds);
      return true;
    }
  }

  static Future<bool> removeSurahFromFav(String reciterUuid, String uuid) async {
    final db = await SharedPreferences.getInstance();
    final listRecitersIds = await getFavoriteSurahs(reciterUuid);
    if (listRecitersIds.contains(uuid)) {
      listRecitersIds.remove(uuid);
      db.setStringList(surahListIds(reciterUuid), listRecitersIds);
      return true;
    }
    return false;
  }

  static Future<List<String>> getDownloadedRecitation() async {
    try {
      final db = await SharedPreferences.getInstance();
      final List<String> data = db.getStringList(DownloadedRecitationPath) ?? [];

      return data;
    } on Exception catch (error) {
      debugPrint(error.toString());

      return [];
    }
  }

  static Future<bool> addDownloadedRecitationPath({
    required String reciterId,
    required String chapterId,
    required String path,
  }) async {
    String abc = jsonEncode({'reciterId': reciterId, 'chapterId': chapterId});
    final recitation = DownloadedRecitationPath + abc;
    final db = await SharedPreferences.getInstance();
    final listDownloadedRecitation = await getDownloadedRecitation();

    if (listDownloadedRecitation.contains(abc)) {
      final String data = db.getString(recitation) ?? '';
      if (data == path) {
        return false;
      }
      db.setString(recitation, path);

      return true;
    } else {
      listDownloadedRecitation.add(abc);
      db.setString(recitation, path);
      db.setStringList(DownloadedRecitationPath, listDownloadedRecitation);
      return true;
    }
  }

  static Future<String> getSingleDownloadedRecitationPath({
    required String reciterId,
    required String chapterId,
  }) async {
    String abc = jsonEncode({'reciterId': reciterId, 'chapterId': chapterId});
    final recitation = DownloadedRecitationPath + abc;
    final db = await SharedPreferences.getInstance();

    final String data = db.getString(recitation) ?? '';
    if (data.isNotEmpty) {
      return data;
    }

    return '';
  }

  static Future<bool> deleteDownloadedRecitationPath({
    required String reciterId,
    required String chapterId,
    required String path,
  }) async {
    String abc = jsonEncode({'reciterId': reciterId, 'chapterId': chapterId});
    final recitation = DownloadedRecitationPath + abc;
    final db = await SharedPreferences.getInstance();
    final listDownloadedRecitation = await getDownloadedRecitation();

    if (listDownloadedRecitation.contains(abc)) {
      listDownloadedRecitation.remove(abc);
      db.remove(recitation);
      File file = File(path);

      if (await file.exists()) {
        await file.delete(recursive: true);
      }
      db.setStringList(DownloadedRecitationPath, listDownloadedRecitation);
      return true;
    } else {
      return false;
    }
  }
}
