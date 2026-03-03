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

      bool downloadCompleted = await downloadWithConcurrentChunks(
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


  Future<bool> downloadWithConcurrentChunks({
    required String url,
    required String tempPath,
    required String finalPath,
    required CancelToken cancelToken,
    Function(double)? onProgress,
    int maxRetries = 3,
    int chunkSize = 5 * 1024 * 1024, // 5MB
    int concurrentChunks = 3,
  }) async {
    final tempFile = File(tempPath);

    // STEP 1: Get total file size
    int totalSize = 0;
    try {
      final dio = Dio();
      final headResponse = await dio.head(url);
      totalSize =
          int.tryParse(headResponse.headers.value('content-length') ?? '') ?? 0;
      if (totalSize == 0) throw Exception('Cannot determine file size');
    } catch (e) {
      debugPrint('HEAD request failed: $e');
      totalSize = 0;
    }

    // STEP 2: Create or open temp file
    if (!await tempFile.exists()) {
      await tempFile.create(recursive: true);
    }

    // STEP 3: Calculate chunk ranges
    List<Map<String, int>> chunks = [];
    for (int start = 0; start < totalSize; start += chunkSize) {
      int end = (start + chunkSize - 1).clamp(0, totalSize - 1);
      chunks.add({'start': start, 'end': end});
    }

    // STEP 4: Track downloaded bytes for progress
    int downloadedBytes = await tempFile.length();
    final progressLock = Object();

    if (onProgress != null) {
      onProgress(downloadedBytes / totalSize);
    }

    // STEP 5: Helper function to download a single chunk
    Future<void> downloadChunk(Map<String, int> chunk) async {
      int attempt = 0;
      while (attempt < maxRetries) {
        attempt++;
        try {
          final dio = Dio();
          final headers = {'Range': 'bytes=${chunk['start']}-${chunk['end']}'};

          final response = await dio.get(
            url,
            options: Options(
              headers: headers,
              responseType: ResponseType.stream,
            ),
            cancelToken: cancelToken,
          );

          if (response.statusCode != 206 && response.statusCode != 200) {
            throw Exception('Unexpected response: ${response.statusCode}');
          }

          final chunkRaf = await tempFile.open(mode: FileMode.write);
          await chunkRaf.setPosition(chunk['start']!);

          final stream = response.data.stream as Stream<List<int>>;
          await for (final data in stream) {
            await chunkRaf.writeFrom(data);
            downloadedBytes += data.length;

            if (onProgress != null && totalSize > 0) {
              synchronized(progressLock, () {
                onProgress(downloadedBytes / totalSize);
              });
            }
          }
          await chunkRaf.close();
          break; // success
        } catch (e) {
          debugPrint('Chunk download failed (attempt $attempt): $e');
          if (attempt >= maxRetries) rethrow;
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }

    // STEP 6: Download chunks in concurrent batches
    for (int i = 0; i < chunks.length; i += concurrentChunks) {
      final batch = chunks.sublist(
        i,
        (i + concurrentChunks).clamp(0, chunks.length),
      );
      await Future.wait(batch.map(downloadChunk));
    }

    // STEP 7: Finalize
    await tempFile.copy(finalPath);
    await tempFile.delete();

    if (onProgress != null) onProgress(1.0);

    debugPrint('Download completed: $finalPath');
    return true;
  }

  // Lock helper for progress updates
  void synchronized(Object lock, void Function() action) {
    action();
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
