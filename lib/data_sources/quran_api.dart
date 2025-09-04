import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';

import '../models/reciter.dart';
import '../models/recitation.dart';
import '../models/surah_audio.dart';
import '../models/quran_audio.dart';

const kBaseUrlV4 = 'https://api.quran.com/api/v4/';

class QuranApi {
  static final options = CacheOptions(
    policy: CachePolicy.forceCache,
    store: HiveCacheStore(null),
  );
  static final dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrlV4,
    ),
  )..interceptors.addAll([
      DioCacheInterceptor(options: options),
    ]);

  static Future<List<Reciter>> reciters({required String language}) async {
    try {
      final response = await dio.get('resources/recitations?language=$language');
      final data = response.data;
      final reciters = data['recitations']
          .map<Reciter>((e) => Reciter.fromMap(e))
          .where((reciter) => reciter.mainReciterId != null)
          .toList();
      return reciters;
    } catch (e) {
      log('QuranApi.reciters error: $e');
      return [];
    }
  }

  static Future<List<Recitation>> chapterRecitations({
    required int recitationId,
    required int chapterId,
  }) async {
    try {
      final response = await dio.get(
        'chapter_recitations/$recitationId?chapter_number=$chapterId',
      );
      final data = response.data;
      final recitations = data['audio_files']
          .map<Recitation>((e) => Recitation.fromMap(e))
          .toList();
      return recitations;
    } catch (e) {
      log('QuranApi.chapterRecitations error: $e');
      return [];
    }
  }

  static Future<List<SurahAudio>> surahAudio({
    required int recitationId,
    required int chapterId,
  }) async {
    try {
      final response = await dio.get(
        'chapter_recitations/$recitationId?chapter_number=$chapterId',
      );
      final data = response.data;
      final surahAudios = data['audio_files']
          .map<SurahAudio>((e) => SurahAudio.fromMap(e))
          .toList();
      return surahAudios;
    } catch (e) {
      log('QuranApi.surahAudio error: $e');
      return [];
    }
  }

  static Future<AudioQuran?> quranRecitations({required int recitationId}) async {
    try {
      final response = await dio.get('quran/recitations/$recitationId');
      final data = response.data;
      return AudioQuran.fromMap(data);
    } catch (e) {
      log('QuranApi.quranRecitations error: $e');
      return null;
    }
  }
}
