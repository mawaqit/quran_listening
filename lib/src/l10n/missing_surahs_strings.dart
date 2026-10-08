import 'package:flutter/widgets.dart';

/// Temporary English strings for the missing-surahs guidance.
///
/// TODO(i18n): once these keys are on Crowdin and mawaqit_mobile_i18n is
/// bumped, replace each getter with its `context.tr.<key>` equivalent and
/// delete this file.
extension MissingSurahsStrings on BuildContext {
  /// key: available_surahs_count
  String availableSurahsCount(int count, int total) =>
      'This recitation includes $count of $total surahs';

  /// key: missing_surahs_suggestion
  String get missingSurahsSuggestion =>
      'Listen to the missing surahs with another reciter';

  /// key: missing_surahs
  String get missingSurahsTitle => 'Missing surahs';

  /// key: not_available_from_reciter
  String get notAvailableFromReciter => 'Not available from this reciter';

  /// key: find_another_reciter
  String get findAnotherReciter => 'Find another reciter';
}
