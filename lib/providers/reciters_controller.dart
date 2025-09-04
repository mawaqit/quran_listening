import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data_sources/quran_api.dart';
import '../models/reciter.dart';
import '../models/surah_model.dart';
import '../repository/quran_listening_repository.dart';

enum RecitersScreenState { loading, success, failed }

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
    String localeName = language ?? 'en';
    List<String> availableLocales = [
      'ar',
      'en',
      'fr',
      'ru',
      'de',
      'es',
      'tr',
      'cn',
      'th',
      'ur',
      'bn',
      'bs',
      'ug',
      'fa',
      'tg',
      'ml',
      'tl',
      'id',
      'pt',
      'ha',
      'sw',
    ];
    if (!availableLocales.contains(localeName)) {
      localeName = 'en';
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

      bool isReciterLocalExist = await _repository.isReciterLocalExist(
        localeName,
      );
      if (!isReciterLocalExist) {
        reciters = await QuranApi.reciters(language: localeName);
        originalReciters = reciters;
        recitersForFavorite = reciters;

        if (reciters.isNotEmpty) {
          await _repository.sharedPreferences.setString(
            '${recitersKey}_$localeName',
            json.encode(reciters.map((e) => e.toMap()).toList()),
          );
        }
      }

      notifyListeners();
    } on Exception {
      state = RecitersScreenState.failed;
      notifyListeners();
    }
  }

  Widget getImage(String path, {double? width, double? height}) {
    return Image.asset(
      '',
      height: height ?? 40,
      width: width ?? 40,
      fit: BoxFit.cover,
    );
  }

  void cacheReciters() {
    Future.microtask(() async {
      enReciters = await _repository.getReciters('en');
      arReciters = await _repository.getReciters('ar');
      frReciters = await _repository.getReciters('fr');
      languageBasedAllReciters = [...enReciters, ...arReciters, ...frReciters];
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
      reciters.addAll(
        originalReciters.where(
          (element) =>
              element.reciterName.toLowerCase().contains(word.toLowerCase()),
        ),
      );
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
      recitersForFavorite.addAll(
        originalReciters.where(
          (element) =>
              element.reciterName.toLowerCase().contains(word.toLowerCase()),
        ),
      );
    }
    notifyListeners();
  }

  void changeReciter(Reciter reciter) {
    // This method can be used to set the current selected reciter
    // You can add logic here to handle reciter selection
    notifyListeners();
  }
}
