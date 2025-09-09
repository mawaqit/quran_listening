import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';

enum RecitationsScreenState { loading, success, failed }

class RecitationsManager extends ChangeNotifier {
  RecitationsManager();

  final ReciterHiveManager _hiveManager = ReciterHiveManager();

  RecitationsScreenState state = RecitationsScreenState.success;

  bool get isLoading => state == RecitationsScreenState.loading;
  Map<int, List<Recitation>> recitations = {};
  List<SurahModel> surahs = [];

  Future<void> initializeSurahs() async {
    if (surahs.isEmpty) {
      try {
        surahs = await QuranApi.getSurah(language: 'en');
        notifyListeners();
      } catch (e) {
        debugPrint('Error initializing surahs: $e');
      }
    }
  }

  void cacheSurahs() {
    Future.microtask(() async {
      if (surahs.isEmpty) {
        try {
          surahs = await QuranApi.getSurah(language: 'en');
          notifyListeners();
        } catch (e) {
          debugPrint('Error caching surahs: $e');
        }
      }
    });
  }

  Future<void> getRecitations({
    required int reciterId,
    bool retry = false,
  }) async {
    try {
      if (recitations.containsKey(reciterId)) {
        // Recitations already loaded, set success state immediately
        state = RecitationsScreenState.success;
        notifyListeners();
        return;
      }

      // Check cache first
      final result = await _hiveManager.read(
        key: 'localRecitations_$reciterId',
        defaultValue: '[]',
      );

      List<Recitation> list = [];
      if (result != null && result.isNotEmpty) {
        // Data exists in cache, load it
        list =
            json
                .decode(result)
                .map<Recitation>((e) => Recitation.fromMap(e))
                .toList();
        recitations.putIfAbsent(reciterId, () => list);
        state = RecitationsScreenState.success;
        notifyListeners();
        return;
      }

      // No cached data, fetch from API
      if (retry) {
        state = RecitationsScreenState.loading;
        notifyListeners();
      }

      list = await QuranApi.chapterRecitations(reciterId: reciterId);
      _hiveManager.write(
        key: 'localRecitations_$reciterId',
        value: list.map((e) => e.toMap()).toList(),
      );
      recitations.putIfAbsent(reciterId, () => list);

      state = RecitationsScreenState.success;
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      state = RecitationsScreenState.failed;
      notifyListeners();
    }
  }
}
