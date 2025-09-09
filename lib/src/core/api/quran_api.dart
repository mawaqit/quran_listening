import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:super_converter/converter/converter.dart';

import '../../models/reciter.dart';
import '../../models/recitation.dart';
import '../../models/surah_model.dart';
import '../database/hive_manager.dart';

extension on Map<dynamic, dynamic> {
  Map<String, dynamic> get toStringDynamic {
    Map<String, dynamic> map = {};
    forEach((key, value) {
      if (value is Map) {
        Map<String, dynamic> map2 = {};
        value.forEach((key, value) {
          map2[key.toString()] = value;
        });
        map[key.toString()] = map2;
      } else {
        map[key.toString()] = value;
      }
    });
    return map;
  }
}

const kBaseUrlV4 = 'https://api.quran.com/api/v4/';

class QuranApi {
  static final ReciterHiveManager _hiveManager = ReciterHiveManager();
  static final options = CacheOptions(
    policy: CachePolicy.forceCache,
    store: HiveCacheStore(null),
  );
  static final dio = Dio(BaseOptions(baseUrl: kBaseUrlV4))
    ..interceptors.addAll([DioCacheInterceptor(options: options)]);

  static Future<List<Reciter>> reciters({String? language}) async {
    if (language == 'en') language = 'eng';
    var url =
        'https://www.mp3quran.net/api/v3/reciters${language != null ? '?language=$language' : ''}';
    final response = await dio.get<Map>(url);

    log('-------------------- url :  $url');
    List<Reciter> reciters = [];
    response.data!['reciters'].forEach((element) {
      Reciter reciter = Reciter.fromMap(element);
      reciter.mainReciterId = reciter.id;
      for (var mushaf in reciter.mushaf) {
        Reciter r = reciter.copyWith(
          id: mushaf.id,
          serverUrl: mushaf.server,
          style: mushaf.name,
          totalSurah: mushaf.totalSurah,
          surahsList: mushaf.surahsList,
        );
        reciters.add(r);
      }
    });
    return reciters;
  }

  static Future<List<Recitation>> chapterRecitations({
    required int reciterId,
  }) async {
    var url = 'https://mp3quran.net/api/v3/suwar';
    final response = await dio.get<Map>(url);

    return response.data!.fromList('audio_files', skipInvalid: true);
  }

  static Future<List<SurahModel>> getSurah({required String language}) async {
    if (language == 'en') language = 'eng';
    var url = 'https://mp3quran.net/api/v3/suwar?language=$language';
    final response = await dio.get<Map>(url);
    final surah = response.data!['suwar'];
    final result = (surah as List).map((e) => SurahModel.fromMap(e)).toList();
    return result;
  }
}
