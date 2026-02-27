import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:path_provider/path_provider.dart';
import '../core/database/hive_manager.dart';
import '../models/reciter.dart';
import '../models/surah_model.dart';

const int oneTimeDownloadLimit = 3;
const String kReciterId = 'reciterId';
const String kChapterId = 'chapterId';
const String kPath = 'path';

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

class DownloadController extends ChangeNotifier {
  bool isSaved = false;
  final String reciterId;
  bool _isLoading = true;

  final Map<String, Map<String, double>> _inProgressSurahs = {};
  final Map<String, CancelToken> _activeDownloads = {};

  Map<String, Map<String, double>> get inProgressSurahs => _inProgressSurahs;
  bool get isLoading => _isLoading;

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

  Map<String, dynamic> get downloadedSurahsForSpecificReciter =>
      _downloadedSurahsForSpecificReciter;

  DownloadController({required this.reciterId});

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

  void searchDownloadedSurah(String word) {
    surahRecitorList =
        originalSurahRecitorList.where((element) {
          return element.surah.name?.toLowerCase().contains(
                word.toLowerCase(),
              ) ??
              false;
        }).toList();
    notifyListeners();
  }

  void resetDownloadedSurahs() {
    surahRecitorList = originalSurahRecitorList;
    notifyListeners();
  }

  Future<void> loadDownloadedRecitations() async {
    final hiveManager = ReciterHiveManager();
    final downloadedRecitationsJson = hiveManager.getDownloadedRecitation();
    _downloadedSurahsForSpecificReciter = json.decode(
      downloadedRecitationsJson,
    );

    _downloadedSurahs = [];
    _downloadedRecitation = [];

    _downloadedSurahsForSpecificReciter.forEach((reciterId, surahs) {
      if (surahs is Map) {
        surahs.forEach((surahId, path) {
          _downloadedSurahs.add({
            kReciterId: reciterId,
            kChapterId: surahId,
            kPath: path,
          });
          _downloadedRecitation.add(path);
        });
      }
    });

    _isLoading = false;
    notifyListeners();
  }

Future<bool> downloadSurah({
  required BuildContext context,
  required String reciterId,
  required String surahId,
  required String url,
  Function(double)? onProgress,
}) async {
  final downloadCompletedMsg = context.tr.download_completed;
  final downloadFailedMsg = context.tr.download_failed;

  final cancelToken = CancelToken();
  final downloadKey = '${reciterId}_$surahId';
  _activeDownloads[downloadKey] = cancelToken;

  try {
    final savePath = await getApplicationSupportDirectory();
    final reciterDir = Directory('${savePath.path}/$reciterId');
    await reciterDir.create(recursive: true);

    final tempPath = '${reciterDir.path}/$surahId.temp';
    final finalPath = '${reciterDir.path}/$surahId.mp3';

    bool downloadCompleted = await _downloadWithResume(
      url: url,
      tempPath: tempPath,
      finalPath: finalPath,
      cancelToken: cancelToken,
      onProgress: onProgress,
    );

    if (downloadCompleted) {
      final finalFile = File(finalPath);
      if (!await finalFile.exists() || await finalFile.length() == 0) {
        await finalFile.delete();
        throw Exception('Downloaded file is empty or missing');
      }

      final hiveManager = ReciterHiveManager();
      await hiveManager.addDownloadedRecitationPath(
        reciterId: reciterId,
        chapterId: surahId,
        path: finalPath,
      );

      await loadDownloadedRecitations();

      Fluttertoast.showToast(
        msg: downloadCompletedMsg,
        toastLength: Toast.LENGTH_SHORT,
      );

      _activeDownloads.remove(downloadKey);
      return true;
    }

    _activeDownloads.remove(downloadKey);
    return false;
  } catch (e) {
    if (e is DioException && e.type == DioExceptionType.cancel) {
      debugPrint('Download cancelled by user: $downloadKey');
      // Keep temp file so we can resume later
    } else {
      debugPrint('Download error: $e');
      Fluttertoast.showToast(
        msg: downloadFailedMsg,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
    _activeDownloads.remove(downloadKey);
    return false;
  }
}

Future<bool> _downloadWithResume({
  required String url,
  required String tempPath,
  required String finalPath,
  required CancelToken cancelToken,
  Function(double)? onProgress,
  int maxRetries = 3,
}) async {
  int attempt = 0;

  while (attempt < maxRetries) {
    attempt++;
    debugPrint('Download attempt $attempt/$maxRetries');

    try {
      final tempFile = File(tempPath);
      int downloadedBytes = await tempFile.exists() ? await tempFile.length() : 0;

      // Get total file size first via HEAD request
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ));

      int totalSize = await _getFileSize(dio, url);
      debugPrint('Total size: $totalSize, Already downloaded: $downloadedBytes');

      // If temp file already has all bytes, just finalize
      if (totalSize > 0 && downloadedBytes >= totalSize) {
        debugPrint('File already complete, finalizing...');
        await tempFile.copy(finalPath);
        await tempFile.delete();
        return true;
      }

      // Set Range header to resume
      final options = Options(
        headers: downloadedBytes > 0
            ? {'Range': 'bytes=$downloadedBytes-'}
            : {},
        responseType: ResponseType.stream,
      );

      final response = await dio.get(
        url,
        options: options,
        cancelToken: cancelToken,
      );

      // Open file in append mode if resuming, write mode if fresh
      final raf = await tempFile.open(
        mode: downloadedBytes > 0 ? FileMode.append : FileMode.write,
      );

      int received = downloadedBytes;
      final stream = response.data.stream as Stream<List<int>>;

      await for (final chunk in stream) {
        await raf.writeFrom(chunk);
        received += chunk.length;

        if (totalSize > 0 && onProgress != null) {
          onProgress(received / totalSize);
        }
      }

      await raf.close();

      // Verify downloaded size
      final finalTempSize = await tempFile.length();
      debugPrint('Download finished. File size: $finalTempSize / $totalSize');

      if (totalSize > 0 && finalTempSize < totalSize) {
        debugPrint('Incomplete download, will retry...');
        continue; // retry
      }

      // Move to final path
      await tempFile.copy(finalPath);
      await tempFile.delete();
      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;

      debugPrint('DioException on attempt $attempt: ${e.message}');

      if (attempt >= maxRetries) {
        rethrow;
      }

      // Wait before retrying
      await Future.delayed(Duration(seconds: attempt * 2));
    } catch (e) {
      debugPrint('Error on attempt $attempt: $e');
      if (attempt >= maxRetries) rethrow;
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }

  return false;
}

Future<int> _getFileSize(Dio dio, String url) async {
  try {
    final response = await dio.head(url);
    final contentLength = response.headers.value('content-length');
    return int.tryParse(contentLength ?? '') ?? 0;
  } catch (e) {
    debugPrint('Could not get file size: $e');
    return 0;
  }
}
  Future<bool> deleteDownloadedSurah({
    required BuildContext context,
    required String reciterId,
    required String surahId,
  }) async {
    final hiveManager = ReciterHiveManager();
    return await hiveManager.removeDownloadedRecitationPath(
      context: context,
      reciterId: reciterId,
      chapterId: surahId,
    );
  }

  Future<bool> removeDownloadedRecitationPath({
    required BuildContext context,
    required String reciterId,
    required String chapterId,
  }) async {
    final hiveManager = ReciterHiveManager();
    return await hiveManager.removeDownloadedRecitationPath(
      context: context,
      reciterId: reciterId,
      chapterId: chapterId,
    );
  }

  String? singleSavedRecitation({
    required int reciterId,
    required int recitationId,
  }) {
    var recitation = _downloadedSurahs.firstWhereOrNull(
      (element) =>
          element['chapterId'] == recitationId.toString() &&
          element['reciterId'] == reciterId.toString(),
    );
    return recitation?['path'];
  }

  Future<void> cancelDownload({
    required String reciterId,
    required String chapterId,
  }) async {
    // Cancel the actual Dio download
    final downloadKey = '${reciterId}_$chapterId';
    final cancelToken = _activeDownloads[downloadKey];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Download cancelled by user');
    }

    // Remove from tracking
    _activeDownloads.remove(downloadKey);
    _inProgressSurahs[reciterId]?.remove(chapterId);
    notifyListeners();
  }

  Future<void> fetchDownloadedRecitation({required String reciterId}) async {
    // Load downloaded recitations and update the UI
    await loadDownloadedRecitations();
  }

  bool canDownload() {
    // Check if can download (e.g., limit of 3 concurrent downloads)
    // Count currently downloading surahs across all reciters
    int concurrentDownloads = 0;
    _inProgressSurahs.forEach((reciterId, surahs) {
      concurrentDownloads += surahs.length;
    });
    return concurrentDownloads < 3;
  }

  Future<void> downloadRecite({
    required BuildContext context,
    required String url,
    required String reciterId,
    required String chapterId,
  }) async {
    // Start download progress tracking
    _inProgressSurahs[reciterId] ??= {};
    _inProgressSurahs[reciterId]![chapterId] = 0.0;
    notifyListeners();

    try {
      // Call the real download method with progress callback
      final success = await downloadSurah(
        context: context,
        reciterId: reciterId,
        surahId: chapterId,
        url: url,
        onProgress: (progress) {
          _inProgressSurahs[reciterId]![chapterId] = progress;
          notifyListeners();
        },
      );

      if (success) {
        // Download successful, remove from progress
        _inProgressSurahs[reciterId]?.remove(chapterId);
        // loadDownloadedRecitations() is already called in downloadSurah
        notifyListeners();
      } else {
        // Download failed, remove from progress
        _inProgressSurahs[reciterId]?.remove(chapterId);
        notifyListeners();
      }
    } catch (e) {
      // Download failed, remove from progress
      _inProgressSurahs[reciterId]?.remove(chapterId);
      notifyListeners();
      debugPrint('Download error: $e');
    }
  }

  void removeItemFromList(int id) {
    final obj = surahRecitorList.firstWhere((e) => e.id == id);
    originalSurahRecitorList.remove(obj);
    surahRecitorList.remove(obj);
    notifyListeners();
  }

  Future<void> deleteAllDownloadedRecitations(BuildContext context) async {
    // Store context values before async operations
    final deletedSuccessfullyMsg = context.tr.downloaded_deleted_successfully;
    final failedDeleteMsg = context.tr.failed_delete_recitations;

    try {
      final downloadedDataJson = ReciterHiveManager().getDownloadedRecitation();
      final downloadedData =
          json.decode(downloadedDataJson) as Map<String, dynamic>;

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
      // Clear Hive data
      await ReciterHiveManager().recitationsBox.put(
        DownloadedRecitationPath,
        json.encode({}),
      );

      originalSurahRecitorList = [];
      surahRecitorList = [];
      notifyListeners();
      // TODO
      Fluttertoast.showToast(
        msg: deletedSuccessfullyMsg,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (error) {
      debugPrint('Error while deleting all recitations: $error');
      Fluttertoast.showToast(
        msg: failedDeleteMsg,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}
