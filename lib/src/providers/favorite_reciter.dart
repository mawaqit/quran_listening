import 'package:flutter/material.dart';

import '../core/database/reciter_db.dart';

class FavoriteReciter extends ChangeNotifier {
  List<String> _favoriteReciterUuids = [];

  List<String> get favoriteReciterUuids => _favoriteReciterUuids;

  FavoriteReciter() {
    fetchFavoriteReciter();
  }

  fetchFavoriteReciter() async {
    final favReciterId = await ReciterDB.getRecitersIds();
    _favoriteReciterUuids = favReciterId;
    notifyListeners();
  }

  Future<bool> addReciterToFavorite(String uuid) async {
    try {
      final res = await ReciterDB.addReciter(uuid);
      if (res) {
        fetchFavoriteReciter();
      }
      return res;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  Future<bool> removeReciterFromFavorite(String uuid) async {
    try {
      final res = await ReciterDB.removeReciter(uuid);
      if (res) {
        fetchFavoriteReciter();
      }
      return res;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }
}
