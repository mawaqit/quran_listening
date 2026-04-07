import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:mawaqit_core_logger/mawaqit_core_logger.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';

enum RecitationsScreenState { loading, success, failed }

class RecitationsManager extends ChangeNotifier {
  RecitationsManager();

  final ReciterHiveManager _hiveManager = ReciterHiveManager();

  RecitationsScreenState state = RecitationsScreenState.success;

  bool get isLoading => state == RecitationsScreenState.loading;
  Map<int, List<Recitation>> recitations = {};
  List<SurahModel> surahs = [];
  final Map<String, List<SurahModel>> _surahsByLanguage = {};
  final Set<int> _loadingReciterIds =
      {}; // Track reciters currently being loaded

  Future<void> initializeSurahs() async {
    if (surahs.isEmpty) {
      try {
        surahs = await getSearchableSurahs();
        notifyListeners();
      } catch (e, stackTrace) {
        Log.e(
          'Error initializing surahs: $e',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  void cacheSurahs() {
    Future.microtask(() async {
      if (surahs.isEmpty) {
        try {
          surahs = await getSearchableSurahs();
          notifyListeners();
        } catch (e, stackTrace) {
          Log.e('Error caching surahs: $e', error: e, stackTrace: stackTrace);
        }
      }
    });
  }

  Future<List<SurahModel>> getSearchableSurahs() async {
    return getSearchableSurahsForBase();
  }

  Future<List<SurahModel>> getSearchableSurahsForBase([
    List<SurahModel>? baseSurahs,
    String baseLanguage = 'en',
  ]) async {
    if (surahs.isNotEmpty &&
        baseSurahs == null &&
        surahs.every(
          (surah) =>
              (surah.name?.isNotEmpty ?? false) &&
              (surah.englishName?.isNotEmpty ?? false) &&
              (surah.frenchName?.isNotEmpty ?? false) &&
              (surah.arabicName?.isNotEmpty ?? false),
        )) {
      return surahs;
    }

    final cachedEnglish = _surahsByLanguage['en'];
    final cachedFrench = _surahsByLanguage['fr'];
    final cachedArabic = _surahsByLanguage['ar'];

    if (cachedEnglish != null && cachedFrench != null && cachedArabic != null) {
      surahs = _mergeSurahLanguages(
        baseSurahs: baseSurahs,
        baseLanguage: baseLanguage,
        english: cachedEnglish,
        french: cachedFrench,
        arabic: cachedArabic,
      );
      return surahs;
    }

    final english = await QuranApi.getSurah(language: 'en');
    final french = await QuranApi.getSurah(language: 'fr');
    final arabic = await QuranApi.getSurah(language: 'ar');

    _surahsByLanguage['en'] = english;
    _surahsByLanguage['fr'] = french;
    _surahsByLanguage['ar'] = arabic;

    surahs = _mergeSurahLanguages(
      baseSurahs: baseSurahs,
      baseLanguage: baseLanguage,
      english: english,
      french: french,
      arabic: arabic,
    );
    return surahs;
  }

  List<SurahModel> _mergeSurahLanguages({
    List<SurahModel>? baseSurahs,
    required String baseLanguage,
    required List<SurahModel> english,
    required List<SurahModel> french,
    required List<SurahModel> arabic,
  }) {
    final sourceSurahs = baseSurahs ?? english;
    return sourceSurahs.map((sourceSurah) {
      final englishSurah = english.firstWhereOrNull(
        (item) => item.id == sourceSurah.id,
      );
      final frenchSurah = french.firstWhereOrNull(
        (item) => item.id == sourceSurah.id,
      );
      final arabicSurah = arabic.firstWhereOrNull(
        (item) => item.id == sourceSurah.id,
      );
      String? localizedName;
      if (baseLanguage == 'ar') {
        localizedName = arabicSurah?.name ?? sourceSurah.name;
      } else if (baseLanguage == 'fr') {
        localizedName = frenchSurah?.name ?? sourceSurah.name;
      } else {
        localizedName = englishSurah?.name ?? sourceSurah.name;
      }

      return sourceSurah.copyWith(
        name: localizedName,
        englishName: englishSurah?.name,
        arabicName: arabicSurah?.name,
        frenchName: frenchSurah?.name,
      );
    }).toList();
  }

  Future<void> getRecitations({
    required int reciterId,
    bool retry = false,
  }) async {
    try {
      // If already loaded, return immediately
      if (recitations.containsKey(reciterId)) {
        state = RecitationsScreenState.success;
        notifyListeners();
        return;
      }

      // If already loading for this reciter, skip duplicate call
      if (_loadingReciterIds.contains(reciterId)) {
        Log.i(
          'RecitationsManager: Already loading recitations for reciter ID $reciterId, skipping duplicate call',
        );
        return;
      }

      // Check cache first
      final result = await _hiveManager.read(
        key: 'localRecitations_$reciterId',
        defaultValue: '[]',
      );

      List<Recitation> list = [];
      if (result != null && result.isNotEmpty && result != '[]') {
        try {
          list =
              json
                  .decode(result)
                  .map<Recitation>((e) => Recitation.fromMap(e))
                  .toList();
          recitations.putIfAbsent(reciterId, () => list);
          state = RecitationsScreenState.success;
          notifyListeners();
          return;
        } catch (e, stackTrace) {
          Log.e(
            'RecitationsManager: Error parsing cached data: $e',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }

      // Mark as loading to prevent concurrent calls
      _loadingReciterIds.add(reciterId);

      if (retry) {
        state = RecitationsScreenState.loading;
        notifyListeners();
      }

      try {
        list = await QuranApi.chapterRecitations(reciterId: reciterId);

        await _hiveManager.write(
          key: 'localRecitations_$reciterId',
          value: list.map((e) => e.toMap()).toList(),
        );
        recitations.putIfAbsent(reciterId, () => list);

        state = RecitationsScreenState.success;
        notifyListeners();
      } finally {
        // Always remove from loading set, even if there's an error
        _loadingReciterIds.remove(reciterId);
      }
    } on Exception catch (e, stackTrace) {
      Log.e(
        'RecitationsManager: Error getting recitations for reciter ID $reciterId: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = RecitationsScreenState.failed;
      _loadingReciterIds.remove(reciterId); // Ensure it's removed on error
      notifyListeners();
    }
  }
}
