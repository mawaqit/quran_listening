import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

const String DownloadedRecitationPath = 'downloaded_recitations';

class ReciterHiveManager extends ChangeNotifier {
  static final ReciterHiveManager _instance = ReciterHiveManager._internal();
  factory ReciterHiveManager() => _instance;
  ReciterHiveManager._internal();

  late Box recitationsBox;
  late Box recitersBox;

  Future<void> init() async {
    await Hive.initFlutter();
    recitationsBox = await Hive.openBox('recitations');
    recitersBox = await Hive.openBox('reciters');
  }

  Future<bool> addDownloadedRecitationPath({
    required String reciterId,
    required String chapterId,
    required String path,
  }) async {
    final newData = {
      reciterId: {chapterId: path},
    };

    final listDownloadedRecitation = getDownloadedRecitation();
    var hiveData = json.decode(listDownloadedRecitation);

    if (hiveData!.containsKey(reciterId)) {
      Map reciterMap = hiveData[reciterId]!;
      if (reciterMap.containsKey(chapterId)) {
        final data = hiveData[reciterId]![chapterId];
        if (data == path) {
          notifyListeners();
          return false;
        }
        hiveData[reciterId]![chapterId] = path;
        notifyListeners();
        return true;
      } else {
        hiveData[reciterId]!.addAll(newData[reciterId]!);
        recitationsBox.put(DownloadedRecitationPath, json.encode(hiveData));
        notifyListeners();
        return true;
      }
    } else {
      hiveData[reciterId] = newData[reciterId];
      recitationsBox.put(DownloadedRecitationPath, json.encode(hiveData));
      notifyListeners();
      return true;
    }
  }

  String getDownloadedRecitation() {
    return recitationsBox.get(DownloadedRecitationPath, defaultValue: '{}')
        as String;
  }

  Future<bool> removeDownloadedRecitationPath({
    required BuildContext context,
    required String reciterId,
    required String chapterId,
  }) async {
    final savePath = await getApplicationSupportDirectory();
    final filePath = '${savePath.path}/$reciterId/$chapterId.mp3';

    File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    final listDownloadedRecitation = getDownloadedRecitation();
    var hiveData = json.decode(listDownloadedRecitation);
    if (hiveData!.containsKey(reciterId)) {
      if (hiveData[reciterId]!.toString().toLowerCase().contains(chapterId)) {
        hiveData[reciterId]!.remove(chapterId);
        recitationsBox.put(DownloadedRecitationPath, json.encode(hiveData));
        notifyListeners();
        Fluttertoast.showToast(
          msg: 'Recitation deleted successfully',
          toastLength: Toast.LENGTH_SHORT,
        );
        return true;
      }
    }
    notifyListeners();
    return false;
  }

  Future<bool> isKeyExist(String key) async {
    return recitersBox.containsKey(key);
  }

  Future<void> write({
    required String key,
    required dynamic value,
    Box? boxName,
  }) async {
    if (boxName == null) {
      await recitersBox.put(key, json.encode(value));
    } else {
      await boxName.put(key, json.encode(value));
    }
  }

  Future<dynamic> read({required String key, var defaultValue}) async {
    final data = recitersBox.get(key);
    return data;
  }
}
