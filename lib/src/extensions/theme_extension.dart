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

  /// check the local direction
  bool get isRtl {
    return Directionality.of(this) == TextDirection.rtl;
  }

  /// Get appropriate font family based on language.
  /// Mirrors the main app's text theme: Cairo for Arabic and Urdu, Figtree otherwise.
  String get fontFamily => ['ar', 'ur'].contains(Localizations.localeOf(this).languageCode) ? 'Cairo' : 'Figtree';

  /// Get font family (same as getFontFamily in main app)
  String getFontFamily() => fontFamily;
}
