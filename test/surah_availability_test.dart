import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';
import 'package:mawaqit_quran_listening/src/utils/listening_utils/surah_availability.dart';

Reciter _reciter(List<String>? surahs) => Reciter(
  id: 1,
  mainReciterId: 1,
  reciterName: 'Test',
  mushaf: const [],
  surahsList: surahs,
);

void main() {
  test('complete recitation has no missing surahs', () {
    final reciter = _reciter(
      List.generate(kTotalQuranSurahs, (i) => '${i + 1}'),
    );
    expect(reciter.hasMissingSurahs, isFalse);
    expect(reciter.availableSurahCount, kTotalQuranSurahs);
  });

  test('partial recitation reports missing surahs', () {
    final reciter = _reciter(['1', '2', '36', '67']);
    expect(reciter.hasMissingSurahs, isTrue);
    expect(reciter.availableSurahCount, 4);
    expect(reciter.hasSurah(36), isTrue);
    expect(reciter.hasSurah(18), isFalse);
  });

  test('unknown surah list is not flagged as incomplete', () {
    expect(_reciter(null).hasMissingSurahs, isFalse);
    expect(_reciter(const []).hasMissingSurahs, isFalse);
  });
}
