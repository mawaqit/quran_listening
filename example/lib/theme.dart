import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:mawaqit_quran_listening/src/extensions/device_extensions.dart';

Color backgroundColorNew = const Color.fromRGBO(222, 215, 232, 1.0);
Color activeIconColor = const Color.fromRGBO(78, 43, 129, 1);
Color inactiveIconColor = const Color.fromRGBO(78, 43, 129, 0.4);
Color backgroundTransparentColor = Colors.transparent;
Color snackBarBgColor = const Color(0xff4E2B81);
Color snackBarTextColor = Colors.white;

const double headingSize = 28.0;
const double subHeadingSize = 24.0;
const double bodySizeLarge = 18;
const double bodySizeSmall = 16;

Color screenBackground = const Color(0xff0c0918);
Color innerSurface = const Color(0xff110e1c);
Color outerSurface = const Color(0xff1c182b);
Color primaryColor = const Color(0xff490094);

class ThemeProvider {
  static const String mainFont = 'Figtree';
  static const String arabicFontFamily = 'Cairo';
  static const String notoFontFamily = 'Noto'; //'hafs',
  static const List<String> _fontFallback = [mainFont, notoFontFamily, arabicFontFamily, 'exo'];

  static TextTheme _commonTextTheme(
      BuildContext context, Color color, Color secondColor, Color thirdColor, Locale locale) {
    String fontFamily = locale == const Locale('ar') ||
            locale == const Locale('ur')
        ? arabicFontFamily
        : mainFont;
    double scale(double size) => context.isFoldable ? size : size.sp;
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fontFallback,
        fontWeight: FontWeight.bold,
        fontSize: scale(30.0),
        color: secondColor,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fontFallback,
        fontWeight: FontWeight.w500,
        fontSize: scale(20.0),
        color: color,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fontFallback,
        fontWeight: FontWeight.w500,
        fontSize: scale(20.0),
        color: thirdColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fontFallback,
        fontWeight: FontWeight.w500,
        fontSize: scale(12.0),
        color: color,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fontFallback,
        fontWeight: FontWeight.w400,
        fontSize: scale(16.0),
        color: color,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fontFallback,
        fontWeight: FontWeight.w500,
        fontSize: scale(14.0),
        color: color,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fontFallback,
        fontWeight: FontWeight.w500,
        fontSize: scale(12.0),
        color: thirdColor,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fontFallback,
        fontWeight: FontWeight.w400,
        fontSize: scale(10.0),
        color: color,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fontFallback,
        fontWeight: FontWeight.w400,
        fontSize: scale(12.0),
        color: thirdColor,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fontFallback,
        fontWeight: FontWeight.w400,
        fontSize: scale(8.0),
        color: thirdColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: _fontFallback,
        fontWeight: FontWeight.w400,
        fontSize: scale(7.0),
        color: thirdColor,
      ),
    );
  }

  static ThemeData buildLightTheme(BuildContext context, Locale locale) {
    String fontFamily = locale == const Locale('ar') ? arabicFontFamily : mainFont;
    return ThemeData(
      fontFamily: fontFamily,
      fontFamilyFallback: _fontFallback,

      /// New design V3
      primaryIconTheme: IconThemeData(
        color: primaryColor,
      ),
      iconTheme: const IconThemeData(
        color: Colors.grey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          foregroundColor: const Color(0xffF1F1F1),
          backgroundColor: primaryColor,
          shadowColor: const Color(0x29000000),
          surfaceTintColor: const Color(0x1f000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),

      /// ColorSchema light
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: primaryColor,
        secondary: const Color(0xff2A2A2A),
        onSecondary: const Color(0xFFF1F1F1),
        onPrimaryContainer: primaryColor,
        primaryContainer: primaryColor.withOpacity(.1),
        secondaryContainer: primaryColor.withOpacity(.05),
        inversePrimary: primaryColor.withOpacity(.1),
        onSecondaryContainer: const Color(0xFF5D5D5D),
        tertiaryContainer: primaryColor,
        inverseSurface: const Color(0xFF313233),
        onTertiary: const Color(0xFFE7E7E7),
        tertiary: const Color(0xff5E5E5E),
        surface: const Color(0xFFF8F8F8),
        surfaceContainer: const Color(0xffF1F1F1),
        surfaceContainerLow: const Color(0xffF1F1F1),
        // for main containers background
        surfaceContainerHigh: primaryColor,
        // for images background or actions background inside container,
        surfaceContainerHighest: const Color(0xffE8E8E8),
        surfaceBright: const Color(0xFF2A2A2A),
        onSurface: Colors.white,
        onPrimaryFixed: const Color(0xFF6B7A90),
        surfaceTint: const Color(0x0C490094),
        primaryFixed: primaryColor,
        onTertiaryContainer: primaryColor,
        outlineVariant: const Color(0x0C490094),
        outline: Colors.white.withOpacity(0.05000000074505806),
        error: const Color(0xffF34235),
        onError: const Color(0xffEB5757),
      ),
      textTheme:
          _commonTextTheme(context, const Color(0xff2A2A2A), primaryColor, const Color(0xff5E5E5E), locale),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFFF7F7F7),
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade400;
        }),
      ),

      /// End V3

      focusColor: Colors.black,
      shadowColor: const Color(0xff4E2B81),
      primaryColor: primaryColor,
      primaryColorLight: const Color(0xffd1c4e9),
      primaryColorDark: const Color(0xff512da8),
      canvasColor: const Color(0xffffffff),
      scaffoldBackgroundColor: const Color(0xfffafafa),
      cardColor: const Color.fromRGBO(222, 215, 232, 1.0),
      dividerColor: Colors.grey[400],
      highlightColor: const Color(0xffDED7E8),
      splashColor: const Color(0x66c8c8c8),
      unselectedWidgetColor: const Color(0x8a000000),
      disabledColor: const Color(0xFF898888),
      secondaryHeaderColor: const Color(0xffede7f6),
      dialogBackgroundColor: const Color(0xffffffff),
      indicatorColor: const Color(0xff4E2B81),
      hintColor: const Color(0x8a000000),
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.normal,
        buttonColor: primaryColor,
        disabledColor: const Color(0x61000000),
        highlightColor: const Color(0x29000000),
        splashColor: const Color(0x1f000000),
        focusColor: const Color(0x1f000000),
        hoverColor: const Color(0x0a000000),
        colorScheme: const ColorScheme(
          primary: Color(0xff4e2b81),
          primaryContainer: Color(0xff512da8),
          secondary: Color(0xff4e2b81),
          secondaryContainer: Color(0xff512da8),
          surface: Color(0xffffffff),
          error: Color(0xffd32f2f),
          onPrimary: Color(0xffffffff),
          onSecondary: Color(0xffffffff),
          onSurface: Color(0xff000000),
          onError: Color(0xffffffff),
          brightness: Brightness.light,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 5,
        selectedIconTheme: IconThemeData(
          color: primaryColor,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Color(0xffA8A8A8),
        ),
      ),
      splashFactory: NoSplash.splashFactory,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBarBgColor,
        actionTextColor: snackBarTextColor,
      ),
      bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xffffffff)),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
        checkColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white; // Color for the check mark when selected
          }
          return null; // No check mark when not selected
        }),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle:
            TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14.sp, fontFamily: fontFamily),
        contentTextStyle: TextStyle(color: Colors.black, fontSize: 12.sp, fontFamily: fontFamily),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData buildDarkTheme(BuildContext context, Locale locale) {
    String fontFamily = locale == const Locale('ar') ? arabicFontFamily : mainFont;

    return ThemeData(
      fontFamilyFallback: _fontFallback,
      fontFamily: fontFamily,

      /// New design V3
      primaryIconTheme: const IconThemeData(color: Color(0xffF1F1F1)),
      iconTheme: const IconThemeData(
        color: Colors.grey,
      ),
      splashFactory: NoSplash.splashFactory,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          foregroundColor: const Color(0xffF1F1F1),
          backgroundColor: primaryColor,
          shadowColor: const Color(0x29000000),
          surfaceTintColor: const Color(0x1f000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xffF1F1F1),
        ),
      ),

      // ColorSchema Dark
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: primaryColor,
        onPrimary: outerSurface,
        secondary: const Color(0xffF1F1F1),
        onSecondary: const Color(0xFFF1F1F1),
        onPrimaryContainer: Colors.white,
        primaryContainer: outerSurface,
        surfaceContainerLow: innerSurface,
        surfaceContainerHigh: outerSurface,
        surfaceContainerHighest: outerSurface,
        secondaryContainer: primaryColor,
        inversePrimary: const Color(0xFFA697FF),
        onSecondaryContainer: const Color(0xFFF1F1F1).withOpacity(.6),
        tertiaryContainer: outerSurface,
        onTertiary: outerSurface,
        onTertiaryContainer: const Color(0xFFA697FF),
        inverseSurface: const Color(0xFFF1F1F1),
        surfaceTint: primaryColor,
        primaryFixed: const Color(0xFFA8A8A8),
        tertiary: const Color(0xffF1F1F1),
        surface: screenBackground,
        surfaceContainer: outerSurface,
        surfaceBright: const Color(0xFFCFCFCF),
        outlineVariant: outerSurface,
        outline: outerSurface,
        onSurface: primaryColor,
        onPrimaryFixed: Colors.white60,
        error: const Color(0xffF34235),
        onError: const Color(0xffEB5757),
      ),
      textTheme:
          _commonTextTheme(context, const Color(0xffF1F1F1), const Color(0xffF1F1F1), const Color(0xffF1F1F1), locale),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1C1B23),
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.white24;
        }),
      ),

      /// End V3
      focusColor: Colors.grey,
      shadowColor: const Color(0xff1F1C29),
      primaryColor: const Color(0xffffffff),
      primaryColorLight: const Color(0xffd1c4e9),
      primaryColorDark: const Color(0xff512da8),
      canvasColor: const Color(0xffffffff),
      scaffoldBackgroundColor: const Color(0xfffafafa),
      cardColor: const Color(0xff000000),
      dividerColor: Colors.grey[300],
      highlightColor: const Color(0xff2B2B2B),
      splashColor: const Color(0x66c8c8c8),
      unselectedWidgetColor: const Color(0x8a000000),
      disabledColor: const Color(0xff929292),
      secondaryHeaderColor: const Color(0xffede7f6),
      dialogBackgroundColor: const Color(0xff171717),
      indicatorColor: const Color(0xff000000),
      hintColor: const Color(0xffe0e0e0),
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.normal,
        buttonColor: primaryColor,
        disabledColor: const Color(0x61000000),
        highlightColor: const Color(0x29000000),
        splashColor: const Color(0x1f000000),
        focusColor: const Color(0x1f000000),
        hoverColor: const Color(0x0a000000),
        colorScheme: const ColorScheme(
          primary: Color(0xffffffff),
          primaryContainer: Color(0xff512da8),
          secondary: Color(0xff4e2b81),
          secondaryContainer: Color(0xff512da8),
          surface: Color(0xffffffff),
          error: Color(0xffd32f2f),
          onPrimary: Color(0xffffffff),
          onSecondary: Color(0xffffffff),
          onSurface: Color(0xff000000),
          onError: Color(0xffffffff),
          brightness: Brightness.light,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xff2B2B2B),
        elevation: 5,
        selectedIconTheme: IconThemeData(color: Colors.red),
        unselectedIconTheme: IconThemeData(color: Color(0xff5E5E5E)),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
            color: const Color(0xffffffff), fontWeight: FontWeight.w500, fontSize: 14.sp, fontFamily: fontFamily),
        contentTextStyle: TextStyle(color: const Color(0xffffffff), fontSize: 12.sp, fontFamily: fontFamily),
        backgroundColor: const Color(0xff171717),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBarBgColor,
        actionTextColor: snackBarTextColor,
      ),

      bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xffffffff)),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return const Color(0xff512da8);
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.dragged)) {
            return const Color(0xff512da8);
          }
          return outerSurface;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(width: 0),
        fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.grey;
        }),
      ),
    );
  }
}
