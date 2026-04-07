import 'dart:convert';

import 'package:mawaqit_core_logger/mawaqit_core_logger.dart';
import '../api/quran_api.dart';
import '../database/hive_manager.dart';
import '../../models/reciter.dart';

const String _quranRecitersKey = 'localReciters';

class QuranListeningRepository {
  final ReciterHiveManager hiveManager;

  QuranListeningRepository(this.hiveManager);

  Future<List<Reciter>> getReciters(String localeName) async {
    try {
      final result = await hiveManager.read(
        key: '${_quranRecitersKey}_$localeName',
        defaultValue: '[]',
      );
      if (result != null && result.isNotEmpty) {
        final decoded = await json.decode(result);
        final reciters =
            decoded
                .map<Reciter>((e) => Reciter.fromMap(e))
                .where(
                  (reciter) => reciter != null && reciter.mainReciterId != null,
                )
                .toList();
        if (reciters.isNotEmpty) {
          return reciters;
        }
      }

      final apiReciters = await QuranApi.reciters(language: localeName);
      if (apiReciters.isNotEmpty) {
        hiveManager.write(
          key: '${_quranRecitersKey}_$localeName',
          value: apiReciters.map((e) => e.toMap()).toList(),
        );
      }
      return apiReciters;
    } catch (e, stackTrace) {
      Log.e("Error getting reciters: $e", error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<bool> isReciterLocalExist(String localeName) async {
    return await hiveManager.isKeyExist('${_quranRecitersKey}_$localeName');
  }
}
