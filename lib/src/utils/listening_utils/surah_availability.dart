import '../../models/reciter.dart';

/// Number of surahs in the Quran.
const int kTotalQuranSurahs = 114;

/// The audio source does not provide every surah for every recitation.
/// These helpers read [Reciter.surahsList] to tell which ones exist.
extension ReciterSurahAvailability on Reciter {
  /// Count of surahs this recitation provides.
  int get availableSurahCount => surahsList?.length ?? 0;

  /// True when the source gives a surah list and it is incomplete.
  /// An empty list means "unknown", so it is treated as complete.
  bool get hasMissingSurahs =>
      availableSurahCount > 0 && availableSurahCount < kTotalQuranSurahs;

  bool hasSurah(int surahId) =>
      surahsList?.contains(surahId.toString()) ?? false;
}
