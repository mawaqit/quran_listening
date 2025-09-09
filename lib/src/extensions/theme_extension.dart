import 'package:flutter/material.dart';

/// Theme extension for consistent styling across the Quran Listening package
/// This ensures the package uses the same theme as the main app
extension QuranThemeDataX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;

  void closeKeyboard() {
    FocusScope.of(this).unfocus();
  }

  /// Check if current locale is Arabic
  bool get isArabicLanguage {
    return Localizations.localeOf(this).languageCode == 'ar';
  }

  /// Get appropriate font family based on language
  String get fontFamily => isArabicLanguage ? 'Tajawal' : 'Figtree';

  /// Get font family (same as getFontFamily in main app)
  String getFontFamily() => fontFamily;
}
