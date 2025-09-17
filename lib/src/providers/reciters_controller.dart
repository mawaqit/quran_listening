import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import '../core/api/quran_api.dart';
import '../core/repository/quran_listening_repository.dart';
import '../models/reciter.dart';
import '../models/surah_model.dart';

enum RecitersScreenState { loading, success, failed }

const String quranRecitersKey = 'localReciters';
const String chaptersKey = 'localChapters';

class RecitorsProvider extends ChangeNotifier {
  final QuranListeningRepository _repository;

  RecitorsProvider(this._repository);

  // view attributes
  List<Reciter> originalReciters = [];
  List<Reciter> recitersForFavorite = [];
  List<Reciter> reciters = [];

  // search attributes
  List<Reciter> enReciters = [];
  List<Reciter> arReciters = [];
  List<Reciter> frReciters = [];
  List<Reciter> languageBasedAllReciters = [];

  // surah
  List<SurahModel> surahList = [];
  Map<String, List<SurahModel>> allSurahList = {};
  late RecitersScreenState state = RecitersScreenState.loading;

  bool get isLoading => state == RecitersScreenState.loading;

  bool get isError => state == RecitersScreenState.failed;

  Future<void> getReciters(BuildContext context, {String? language}) async {
    String? localeName = language ?? context.tr.localeName;
    List<String> availableLocales = ['ar', 'en', 'fr', 'ru', 'de', 'es', 'tr', 'cn', 'th', 'ur', 'bn', 'bs', 'ug', 'fa', 'tg', 'ml', 'tl', 'id', 'pt', 'ha', 'sw'];
    if (!availableLocales.contains(localeName)) {
      localeName = 'eng';
    }

    try {
      state = RecitersScreenState.loading;
      notifyListeners();

      reciters = await _repository.getReciters(localeName);
      inspect(reciters);
      originalReciters = reciters;
      recitersForFavorite = reciters;

      if (reciters.isNotEmpty) {
        state = RecitersScreenState.success;
      } else {
        state = RecitersScreenState.failed;
      }

      bool isReciterLocalExist = await _repository.isReciterLocalExist(localeName);
      if (!isReciterLocalExist) {
        reciters = await QuranApi.reciters(language: localeName);
        originalReciters = reciters;
        recitersForFavorite = reciters;

        if (reciters.isNotEmpty) {
          _repository.hiveManager.write(key: '${quranRecitersKey}_$localeName', value: reciters.map((e) => e.toMap()).toList());
        }
      }

      notifyListeners();
      await checkLocalSurahs(context: context, locale: localeName);
    } on Exception {
      state = RecitersScreenState.failed;
      notifyListeners();
    }
  }

  Future<void> checkLocalSurahs({required BuildContext context, required String locale}) async {
    final localeName = locale;
    final data = await _repository.hiveManager.read(key: '${chaptersKey}_$localeName', defaultValue: '[]');
    if (data != null && data.isNotEmpty) {
      surahList = json.decode(data).map<SurahModel>((e) => SurahModel.fromMap(e)).toList();
    }
    bool isSurahsLocalExist = await _repository.hiveManager.isKeyExist('${chaptersKey}_$localeName');
    if (!isSurahsLocalExist) {
      surahList = await QuranApi.getSurah(language: localeName);
      if (surahList.isNotEmpty) {
        _repository.hiveManager.write(key: '${chaptersKey}_$localeName', value: surahList.map((e) => e.toMap()).toList());
      }
    }
    notifyListeners();
  }

  Widget getImage(String path, {double? width, double? height}) {
    return Image.asset(
      path,
      height: height ?? 40,
      width: width ?? 40,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height ?? 40,
          width: width ?? 40,
          decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
          child: Icon(Icons.person, color: Colors.grey[600], size: (height ?? 40) * 0.6),
        );
      },
    );
  }

  void cacheReciters() {
    Future.microtask(() async {
      try {
        enReciters = await _repository.getReciters('en');

        arReciters = await _repository.getReciters('ar');

        frReciters = await _repository.getReciters('fr');

        languageBasedAllReciters = [...enReciters, ...arReciters, ...frReciters];
      } catch (e) {
        debugPrint('RecitorsProvider: Error caching reciters: $e');
      }
    });
    notifyListeners();
  }

  Future<List<Reciter>> filterReciters(String word) async {
    return Future(() {
      return languageBasedAllReciters.where((e) {
        return e.reciterName.toLowerCase().contains(word.toLowerCase());
      }).toList();
    });
  }

  List<Reciter> removeDuplicatesById(List<Reciter> reciters) {
    final seenIds = <int>{};
    return reciters.where((reciter) => seenIds.add(reciter.id)).toList();
  }

  void searchReciters(String word) async {
    List<Reciter> filteredList = await filterReciters(word);
    filteredList = removeDuplicatesById(filteredList);

    inspect(filteredList);
    reciters = [];

    if (filteredList.isNotEmpty) {
      for (var filterIndex in filteredList) {
        for (var originalRectorsIndex in originalReciters) {
          if (filterIndex.id == originalRectorsIndex.id) {
            reciters.add(originalRectorsIndex);
          }
        }
      }
    } else {
      reciters = [];
      reciters.addAll(originalReciters.where((element) => element.reciterName.toLowerCase().contains(word.toLowerCase())));
    }

    notifyListeners();
  }

  void resetReciters() {
    reciters = originalReciters;
    notifyListeners();
  }

  void resetFavoriteReciters() {
    recitersForFavorite = originalReciters;
    notifyListeners();
  }

  void searchFavoriteReciters(String word) async {
    List<Reciter> filteredList = await filterReciters(word);
    filteredList = removeDuplicatesById(filteredList);

    inspect(filteredList);
    recitersForFavorite = [];

    if (filteredList.isNotEmpty) {
      for (var filterIndex in filteredList) {
        for (var originalRectorsIndex in originalReciters) {
          if (filterIndex.id == originalRectorsIndex.id) {
            recitersForFavorite.add(originalRectorsIndex);
          }
        }
      }
    } else {
      recitersForFavorite = [];
      recitersForFavorite.addAll(originalReciters.where((element) => element.reciterName.toLowerCase().contains(word.toLowerCase())));
    }
    notifyListeners();
  }
}
