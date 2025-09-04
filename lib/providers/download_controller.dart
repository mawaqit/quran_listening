import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reciter.dart';
import '../models/surah_model.dart';

const int oneTimeDownloadLimit = 3;
const String kReciterId = 'reciterId';
const String kChapterId = 'chapterId';
const String kPath = 'path';

class DownloadController extends ChangeNotifier {
  bool isSaved = false;

  final Map<String, Map<String, double>> _inProgressSurahs = {};

  Map<String, Map<String, double>> get inProgressSurahs => _inProgressSurahs;

  List<String> _downloadedRecitation = [];
  List<Map<String, String>> _downloadedSurahs = [];
  Map<String, dynamic> _downloadedSurahsForSpecificReciter = {};

  /// recitors
  List<Reciter> originalRecitersForDownloadedRecitations = [];
  List<Reciter> recitersForDownloadedRecitations = [];

  /// recitations
  List<SurahModel> originalDownloadedRecitations = [];
  List<SurahModel> downloadedRecitations = [];

  /// Combined list
  List<CombinedSurahRecitorModel> originalSurahRecitorList = [];
  List<CombinedSurahRecitorModel> surahRecitorList = [];

  List<Map<String, String>> get downloadedSurahs => _downloadedSurahs;

  List<String> get downloadedRecitation => _downloadedRecitation;

  Map<String, dynamic> get downloadedSurahsForSpecificReciter => _downloadedSurahsForSpecificReciter;

  final SharedPreferences _sharedPreferences;

  DownloadController({required String reciterId, required SharedPreferences sharedPreferences}) 
      : _sharedPreferences = sharedPreferences {
    fetchDownloadedRecitation(reciterId: reciterId);
  }

  void setCombinedList() {
    originalSurahRecitorList.clear();
    surahRecitorList.clear();

    for (int i = 0; i < downloadedRecitations.length; i++) {
      originalSurahRecitorList.add(
        CombinedSurahRecitorModel(
          id: i,
          surah: downloadedRecitations[i],
          recitor: recitersForDownloadedRecitations[i],
        ),
      );
    }
    surahRecitorList = originalSurahRecitorList;
  }

  void removeItemFromList(int id) {
    final obj = surahRecitorList.firstWhere((e) => e.id == id);
    originalSurahRecitorList.remove(obj);
    surahRecitorList.remove(obj);
    notifyListeners();
  }

  void searchDownloadedSurah(String query) {
    surahRecitorList = [];
    surahRecitorList.addAll(
      originalSurahRecitorList.where(
        (element) => element.surah.name!.toLowerCase().contains(query.toLowerCase()),
      ),
    );
    notifyListeners();
  }

  resetDownloadedSurahs() {
    surahRecitorList = originalSurahRecitorList;
    notifyListeners();
  }

  bool canDownload() {
    int count = 0;
    for (var element in _inProgressSurahs.keys) {
      count += (_inProgressSurahs[element] ?? {}).length;
    }
    return count < oneTimeDownloadLimit;
  }

  String? singleSavedRecitation({
    required int reciterId,
    required int recitationId,
  }) {
    var recitation = _downloadedSurahs.firstWhereOrNull(
        (element) => element['chapterId'] == recitationId.toString() && element['reciterId'] == reciterId.toString());
    return recitation?['path'];
  }

  fetchDownloadedRecitation({required String reciterId}) async {
    String downloadedRecitationStoredOnHive = _sharedPreferences.getString('downloadedRecitations') ?? '{}';
    Map map = downloadedRecitationStoredOnHive.isNotEmpty ? json.decode(downloadedRecitationStoredOnHive) : {};
    _downloadedSurahs = [];
    map.forEach((reciterId, reciterValue) {
      if (reciterValue is Map) {
        reciterValue.forEach((chapterId, chapterPath) {
          _downloadedSurahs.add({
            kChapterId: chapterId,
            kReciterId: reciterId,
            kPath: chapterPath,
          });
        });
      }
    });
    _downloadedSurahsForSpecificReciter = map[reciterId] ?? {};
    // sort them based on their keys
    var listData = _downloadedSurahsForSpecificReciter.keys.toList();
    listData.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    _downloadedSurahsForSpecificReciter = {for (var k in listData) k: _downloadedSurahsForSpecificReciter[k]};
    _downloadedRecitation = map[reciterId] != null && map[reciterId].isNotEmpty ? map[reciterId].keys.toList() : [];
  }

  Future<bool> addDownloadedRecitationPath({
    required String chapterId,
    required String reciterId,
    required String path,
  }) async {
    try {
      final downloadedData = _sharedPreferences.getString('downloadedRecitations') ?? '{}';
      final Map<String, dynamic> data = json.decode(downloadedData);
      
      if (!data.containsKey(reciterId)) {
        data[reciterId] = {};
      }
      data[reciterId][chapterId] = path;
      
      final res = await _sharedPreferences.setString('downloadedRecitations', json.encode(data));
      _inProgressSurahs[reciterId]![chapterId] = 0.95;
      notifyListeners();
      if (res) {
        fetchDownloadedRecitation(reciterId: reciterId);
      }
      return res;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  Future<bool> deleteDownloadedRecitationPath({
    required String chapterId,
    required String reciterId,
    required String path,
  }) async {
    try {
      final downloadedData = _sharedPreferences.getString('downloadedRecitations') ?? '{}';
      final Map<String, dynamic> data = json.decode(downloadedData);
      
      if (data.containsKey(reciterId) && data[reciterId].containsKey(chapterId)) {
        data[reciterId].remove(chapterId);
        if (data[reciterId].isEmpty) {
          data.remove(reciterId);
        }
        
        final res = await _sharedPreferences.setString('downloadedRecitations', json.encode(data));
        if (res) {
          fetchDownloadedRecitation(reciterId: reciterId);
        }
        return res;
      }
      return false;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  final Map<String, Map<String, CancelToken>> _cancelTokens = {};

  downloadRecite({
    required BuildContext context,
    required String url,
    required String reciterId,
    required String chapterId,
  }) async {
    if (_inProgressSurahs.containsKey(reciterId)) {
      _inProgressSurahs[reciterId]?.putIfAbsent(chapterId, () => 0);
    } else {
      _inProgressSurahs.putIfAbsent(reciterId, () => {chapterId: 0});
    }
    notifyListeners();
    try {
      final savePath = await getApplicationSupportDirectory();

      final filePath = '${savePath.path}/$reciterId/$chapterId.mp3';

      File file = File(filePath);
      if (await file.exists()) {
        isSaved = await addDownloadedRecitationPath(
          chapterId: chapterId,
          reciterId: reciterId,
          path: filePath,
        );
        _inProgressSurahs[reciterId]!.remove(chapterId);
        notifyListeners();
        return file.path;
      }

      Dio dio = Dio();
      CancelToken cancelToken = CancelToken();

      await dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        options: Options(
          headers: {'Connection': 'Keep-Alive'},
        ),
        onReceiveProgress: (rec, total) {
          _inProgressSurahs[reciterId]![chapterId] = rec / (total * 1.2);
          if (_cancelTokens.containsKey(reciterId)) {
            _cancelTokens[reciterId]?[chapterId] = cancelToken;
          } else {
            _cancelTokens[reciterId] = {chapterId: cancelToken};
          }
          notifyListeners();
        },
      ).then(
        (value) async {
          Fluttertoast.showToast(
            msg: 'Download completed',
            toastLength: Toast.LENGTH_SHORT,
          );
          _inProgressSurahs[reciterId]![chapterId] = 0.9;
          notifyListeners();
          isSaved = await addDownloadedRecitationPath(
            chapterId: chapterId,
            reciterId: reciterId,
            path: filePath,
          );

          _inProgressSurahs[reciterId]!.remove(chapterId);
          _cancelTokens[reciterId]?.remove(chapterId);
        },
      ).onError(
        (error, stackTrace) {
          var errorMsg = 'Download failed';
          if (error is DioException) {
            debugPrint('error exp is :: ${error.message}');
            if (error.message == 'The request was manually cancelled by the user.') {
              errorMsg = 'Download cancelled';
            }
          }

          _inProgressSurahs[reciterId]?.remove(chapterId);
          _cancelTokens[reciterId]?.remove(chapterId);
          _cancelTokens.remove(reciterId);
          notifyListeners();
          Fluttertoast.showToast(
            msg: errorMsg,
            toastLength: Toast.LENGTH_SHORT,
          );

          return;
        },
      ).catchError(
        (error) {
          debugPrint('CATCH ERROR');
          Fluttertoast.showToast(
            msg: 'Download failed',
            toastLength: Toast.LENGTH_SHORT,
          );
          _inProgressSurahs[reciterId]!.remove(chapterId);
          _cancelTokens[reciterId]?.remove(chapterId);

          notifyListeners();
          debugPrint(error.toString());
          return;
        },
      );

      notifyListeners();
      return isSaved;
    } on DioException {
      _inProgressSurahs[reciterId]!.remove(chapterId);
      _cancelTokens[reciterId]?.remove(chapterId);
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('SIMPLE CATCH');
      _inProgressSurahs[reciterId]!.remove(chapterId);
      _cancelTokens[reciterId]?.remove(chapterId);
      notifyListeners();
      return false;
    }
  }

  Future<void> cancelDownload({
    required String reciterId,
    required String chapterId,
  }) async {
    if (_cancelTokens.containsKey(reciterId) && _cancelTokens[reciterId]!.containsKey(chapterId)) {
      _cancelTokens[reciterId]?[chapterId]!.cancel();
      _inProgressSurahs[reciterId]?.remove(chapterId);
      _cancelTokens[reciterId]?.remove(chapterId);
      notifyListeners();
    }
  }

  Future<void> deleteAllDownloadedRecitations(BuildContext context) async {
    try {
      final downloadedDataJson = _sharedPreferences.getString('downloadedRecitations') ?? '{}';
      final downloadedData = json.decode(downloadedDataJson) as Map<String, dynamic>;

      for (final reciterId in downloadedData.keys) {
        final chapters = downloadedData[reciterId] as Map<String, dynamic>;
        for (final chapterId in chapters.keys) {
          final path = chapters[chapterId] as String;
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
      // Clear data
      await _sharedPreferences.setString('downloadedRecitations', json.encode({}));

      originalSurahRecitorList=[];
      surahRecitorList=[];
      notifyListeners();
      
      Fluttertoast.showToast(
        msg: 'Downloaded files deleted successfully',
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (error) {
      debugPrint('Error while deleting all recitations: $error');
      Fluttertoast.showToast(
        msg: 'Failed to delete recitations',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}

class CombinedSurahRecitorModel {
  final int id;
  final SurahModel surah;
  final Reciter recitor;

  CombinedSurahRecitorModel({
    required this.id,
    required this.surah,
    required this.recitor,
  });
}
