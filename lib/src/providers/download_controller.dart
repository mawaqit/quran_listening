import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mawaqit_core_logger/mawaqit_core_logger.dart';
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

      final finalPath = '${reciterDir.path}/$surahId.mp3';

      final surahDir = Directory('${reciterDir.path}/$surahId');
      await surahDir.create(recursive: true);

      bool downloadCompleted = await downloadWithSafeConcurrentChunks(
        url: url,
        tempDirPath: surahDir.path,
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
        Log.i('Download cancelled by user: $downloadKey');
        // Keep temp file so we can resume later
      } else {
        Log.i('Download error: $e');
        Fluttertoast.showToast(
          msg: downloadFailedMsg,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
      _activeDownloads.remove(downloadKey);
      return false;
    }
  }

  Future<bool> downloadWithSafeConcurrentChunks({
    required String url,
    required String tempDirPath,
    required String finalPath,
    required CancelToken cancelToken,
    Function(double)? onProgress,
    int chunkSize = 5 * 1024 * 1024,
    int concurrentChunks = 3,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        followRedirects: true,
        validateStatus: (status) => status != null && (status < 400 || status == 416),
      ),
    );

    final tempDir = Directory(tempDirPath);
    await tempDir.create(recursive: true);

    // GET bytes=0-0 to probe the true file size from content-range.
    // HEAD content-length is unreliable on this CDN — edge nodes return stale values.
    final probe = await dio.get(
      url,
      options: Options(
        headers: {'Range': 'bytes=0-0'},
        responseType: ResponseType.stream,
      ),
      cancelToken: cancelToken,
    );
    try {
      await (probe.data.stream as Stream).drain<void>();
    } catch (_) {}

    final probeContentRange = probe.headers.value('content-range') ?? '';
    int totalSize =
        RegExp(r'/(\d+)$').firstMatch(probeContentRange) != null
            ? int.parse(RegExp(r'/(\d+)$').firstMatch(probeContentRange)!.group(1)!)
            : int.tryParse(probe.headers.value('content-length') ?? '') ?? 0;

    if (totalSize == 0) throw Exception('Unable to determine file size');

    // Mutable via single-element list so inner closures can update it.
    // CDN edge nodes disagree on file size; we refine as we receive responses.
    final trueTotalRef = [totalSize];

    // Build chunk list
    final chunks = <_ChunkInfo>[];
    for (int i = 0, start = 0; start < totalSize; start += chunkSize, i++) {
      final int end = (start + chunkSize - 1).clamp(0, totalSize - 1);
      final int expectedSize = end - start + 1;
      final partFile = File('$tempDirPath/part_$i.tmp');

      int existing = 0;
      if (await partFile.exists()) {
        existing = await partFile.length();
        if (existing > expectedSize) {
          await partFile.delete();
          existing = 0;
        }
      }
      chunks.add(
        _ChunkInfo(
          index: i,
          start: start,
          end: end,
          file: partFile,
          existingBytes: existing,
        ),
      );
    }

    // Per-chunk counters — never a shared accumulator.
    // Each counter is reset to real disk size at the top of every attempt,
    // so progress can never drift ahead on retries.
    final chunkCounters = List<int>.from(chunks.map((c) => c.existingBytes));
    void reportProgress() {
      final int written = chunkCounters.fold(0, (s, v) => s + v);
      onProgress?.call((written / trueTotalRef[0]).clamp(0.0, 1.0));
    }

    reportProgress();

    Future<void> downloadChunk(_ChunkInfo chunk) async {
      while (true) {
        if (cancelToken.isCancelled) {
          throw DioException(
            requestOptions: RequestOptions(path: url),
            type: DioExceptionType.cancel,
          );
        }

        // Re-read disk size on every attempt — in-memory state is unreliable
        // after a partial write or stream drop.
        int existingSize = 0;
        if (await chunk.file.exists()) {
          existingSize = await chunk.file.length();
          if (existingSize > chunk.expectedSize) {
            await chunk.file.delete();
            existingSize = 0;
          }
        }
        chunkCounters[chunk.index] = existingSize;
        if (existingSize == chunk.expectedSize) return;

        final int rangeStart = chunk.start + existingSize;
        final int rangeEnd = chunk.end;

        Response? response;
        try {
          response = await dio.get(
            url,
            options: Options(
              headers: {'Range': 'bytes=$rangeStart-$rangeEnd'},
              responseType: ResponseType.stream,
            ),
            cancelToken: cancelToken,
          );
        } on DioException catch (e) {
          if (e.type == DioExceptionType.cancel) rethrow;
          Log.w('Download: chunk ${chunk.index} connect error — ${e.message}');
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        if (response.statusCode == 416) {
          final cr = response.headers.value('content-range') ?? '';
          final m = RegExp(r'/(\d+)$').firstMatch(cr);
          final int? serverTotal = m != null ? int.parse(m.group(1)!) : null;

          if (serverTotal != null) {
            // 416 always means our range overshoots real EOF — trust this total.
            if (serverTotal < trueTotalRef[0]) {
              trueTotalRef[0] = serverTotal;
            }

            if (chunk.start >= serverTotal) {
              // Entire chunk is beyond real EOF — nothing to download.
              if (await chunk.file.exists()) await chunk.file.delete();
              chunk.clampEnd(chunk.start - 1);
              chunkCounters[chunk.index] = 0;
              return;
            }

            if (rangeStart >= serverTotal) {
              // The bytes already on disk reach the server's EOF — chunk is complete.
              chunk.clampEnd(serverTotal - 1);
              chunkCounters[chunk.index] = existingSize;
              return;
            }

            if (chunk.end >= serverTotal) {
              // Our end overshoots — clamp and retry.
              chunk.clampEnd(serverTotal - 1);
              if (existingSize > chunk.expectedSize) {
                await chunk.file.delete();
                chunkCounters[chunk.index] = 0;
              }
              continue;
            }
          }

          // 416 with no usable content-range — wipe and retry.
          Log.w('Download: chunk ${chunk.index} got 416 with no content-range');
          if (await chunk.file.exists()) await chunk.file.delete();
          chunkCounters[chunk.index] = 0;
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        if (response.statusCode != 206 && response.statusCode != 200) {
          throw Exception('Unexpected status: ${response.statusCode}');
        }

        // Server returned 200 (ignored Range header) — restart from zero.
        if (response.statusCode == 200 && rangeStart > 0) {
          if (await chunk.file.exists()) await chunk.file.delete();
          existingSize = 0;
          chunkCounters[chunk.index] = 0;
        }

        // Only update trueTotalRef if this response's rangeEnd touches the server's
        // reported EOF (rangeEnd == serverTotal - 1). Middle chunks from inconsistent
        // edge nodes may report a smaller total that doesn't reflect reality — ignore those.
        final responseCR = response.headers.value('content-range') ?? '';
        final rcm = RegExp(r'bytes (\d+)-(\d+)/(\d+)').firstMatch(responseCR);
        if (rcm != null) {
          final int responseRangeEnd = int.parse(rcm.group(2)!);
          final int responseTotal = int.parse(rcm.group(3)!);
          if (responseRangeEnd == responseTotal - 1 &&
              responseTotal < trueTotalRef[0]) {
            trueTotalRef[0] = responseTotal;
            if (chunk.end >= responseTotal) chunk.clampEnd(responseTotal - 1);
          }
        }

        // Stream bytes to disk
        final raf = await chunk.file.open(mode: FileMode.append);
        bool rafClosed = false;
        Object? streamError;

        try {
          final stream = response.data.stream as Stream<List<int>>;
          await for (final data in stream) {
            if (cancelToken.isCancelled) break;
            final int remaining = chunk.expectedSize - existingSize;
            if (remaining <= 0) break;
            final List<int> toWrite =
                data.length > remaining ? data.sublist(0, remaining) : data;
            await raf.writeFrom(toWrite);
            existingSize += toWrite.length;
            chunkCounters[chunk.index] = existingSize;
            reportProgress();
            if (toWrite.length < data.length) break;
          }
          await raf.flush();
          await raf.close();
          rafClosed = true;
        } catch (e) {
          streamError = e;
          if (!rafClosed) {
            try {
              await raf.flush();
              await raf.close();
            } catch (_) {}
          }
          if (e is DioException && e.type == DioExceptionType.cancel) rethrow;
        }

        if (cancelToken.isCancelled) return;

        final int diskSize =
            await chunk.file.exists() ? await chunk.file.length() : 0;
        chunkCounters[chunk.index] = diskSize;

        if (diskSize == chunk.expectedSize) return;

        // Stream ended short — log and reconnect from where we left off.
        Log.w(
          'Download: chunk ${chunk.index} incomplete '
          '($diskSize/${chunk.expectedSize})${streamError != null ? ' — $streamError' : ''}, reconnecting',
        );
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Run in batches. Errors are collected per-chunk so sibling futures
    // always complete before the error is propagated.
    for (int i = 0; i < chunks.length; i += concurrentChunks) {
      if (cancelToken.isCancelled) {
        throw DioException(
          requestOptions: RequestOptions(path: url),
          type: DioExceptionType.cancel,
        );
      }

      final batch = chunks.sublist(
        i, (i + concurrentChunks).clamp(0, chunks.length),
      );
      final errors = <Object>[];
      await Future.wait(
        batch.map((chunk) async {
          try {
            await downloadChunk(chunk);
          } catch (e) {
            if (e is DioException && e.type == DioExceptionType.cancel) rethrow;
            errors.add(e);
          }
        }),
      );
      if (errors.isNotEmpty) throw errors.first;
    }

    // Validate
    for (final chunk in chunks) {
      if (chunk.expectedSize <= 0) continue;
      if (!await chunk.file.exists()) {
        throw Exception('Missing chunk file: ${chunk.index}');
      }
      final int size = await chunk.file.length();
      if (size != chunk.expectedSize) {
        throw Exception('Chunk ${chunk.index} corrupted ($size / ${chunk.expectedSize})');
      }
    }

    // Merge
    final finalFile = File(finalPath);
    if (await finalFile.exists()) await finalFile.delete();
    final output = await finalFile.open(mode: FileMode.write);
    for (final chunk in chunks) {
      if (chunk.expectedSize <= 0) continue;
      final input = await chunk.file.open(mode: FileMode.read);
      const int bufferSize = 64 * 1024;
      while (true) {
        final bytes = await input.read(bufferSize);
        if (bytes.isEmpty) break;
        await output.writeFrom(bytes);
      }
      await input.close();
      await chunk.file.delete();
    }
    await output.close();

    final int mergedSize = await finalFile.length();
    if (mergedSize != trueTotalRef[0]) {
      throw Exception('Merged file corrupted: $mergedSize / ${trueTotalRef[0]}');
    }

    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
    onProgress?.call(1.0);
    Log.i('Download complete: $finalPath ($mergedSize bytes)');
    return true;
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
    } catch (e, stackTrace) {
      // Download failed, remove from progress
      _inProgressSurahs[reciterId]?.remove(chapterId);
      notifyListeners();
      Log.e('Download error: $e', error: e, stackTrace: stackTrace);
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
      Fluttertoast.showToast(
        msg: deletedSuccessfullyMsg,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (error, stackTrace) {
      Log.e(
        'Error while deleting all recitations: $error',
        error: error,
        stackTrace: stackTrace,
      );
      Fluttertoast.showToast(
        msg: failedDeleteMsg,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}

class _ChunkInfo {
  final int index;
  final int start;
  int end;
  final File file;
  final int existingBytes;

  _ChunkInfo({
    required this.index,
    required this.start,
    required this.end,
    required this.file,
    required this.existingBytes,
  });

  int get expectedSize => end - start + 1;
  void clampEnd(int newEnd) => end = newEnd;
}
