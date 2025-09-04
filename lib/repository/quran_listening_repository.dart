import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data_sources/quran_api.dart';
import '../models/reciter.dart';

const String recitersKey = 'localReciters';

class QuranListeningRepository {
  final SharedPreferences sharedPreferences;

  QuranListeningRepository(this.sharedPreferences);

  Future<List<Reciter>> getReciters(String localeName) async {
    try {
      final result = sharedPreferences.getString('${recitersKey}_$localeName');
      if (result != null && result.isNotEmpty) {
        final decoded = await json.decode(result);
        final reciters = decoded
            .map<Reciter>((e) => Reciter.fromMap(e))
            .where(
                (reciter) => reciter != null && reciter.mainReciterId != null)
            .toList();
        if (reciters.isNotEmpty) {
          return reciters;
        }
      }

      final apiReciters = await QuranApi.reciters(language: localeName);
      if (apiReciters.isNotEmpty) {
        await sharedPreferences.setString(
          '${recitersKey}_$localeName',
          json.encode(apiReciters.map((e) => e.toMap()).toList()),
        );
      }
      return apiReciters;
    } catch (e) {
      debugPrint('QuranListeningRepository.getReciters error: $e');
      return [];
    }
  }

  Future<bool> isReciterLocalExist(String localeName) async {
    return sharedPreferences.containsKey('${recitersKey}_$localeName');
  }
}
