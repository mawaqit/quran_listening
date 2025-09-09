import 'package:flutter/material.dart';
import 'package:mawaqit_quran_listening/src/core/database/reciter_db.dart';

class FavoriteSurah extends ChangeNotifier {
  final Map<String, List<String>> _favoriteSurahs = {};

  Map<String, List<String>> get favoriteSurahs => _favoriteSurahs;

  FavoriteSurah();

  Future<List<int>> fetchFavoriteSurahs(String reciterUuid) async {
    final favSurahs = await ReciterDB.getFavoriteSurahs(reciterUuid);
    _favoriteSurahs[reciterUuid] = favSurahs;
    notifyListeners();
    return (_favoriteSurahs[reciterUuid] ?? []).map((e) => int.parse(e)).toList();
  }

  Future<bool> addReciterToFavorite(String reciterUuid, String uuid) async {
    try {
      final res = await ReciterDB.addSurahToFav(reciterUuid, uuid);
      if (res) {
        fetchFavoriteSurahs(reciterUuid);
      }
      return res;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  Future<bool> removeReciterFromFavorite(String reciterUuid, String uuid) async {
    try {
      final res = await ReciterDB.removeSurahFromFav(reciterUuid, uuid);
      if (res) {
        fetchFavoriteSurahs(reciterUuid);
      }
      return res;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }
}
