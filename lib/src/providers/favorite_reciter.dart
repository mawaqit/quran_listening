import 'package:flutter/material.dart';
import 'package:mawaqit_core_logger/mawaqit_core_logger.dart';

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
    } catch (error, stackTrace) {
      Log.e("Error adding reciter to favorite: $error", error: error, stackTrace: stackTrace);
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
    } catch (error, stackTrace) {
      Log.e("Error removing reciter from favorite: $error", error: error, stackTrace: stackTrace);
      return false;
    }
  }
}
