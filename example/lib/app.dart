import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/gen_l10n/app_localizations.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'l10n.dart';
import 'pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Main app widget that sets up providers and theme
class QuranListeningExampleApp extends StatelessWidget {
  const QuranListeningExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Sizer(
          builder: (context, orientation, deviceType) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (context) => RecitorsProvider(
                    QuranListeningRepository(QuranListeningConfig.hiveManager),
                  ),
                ),
                ChangeNotifierProvider(
                  create: (context) => ListeningToggleIndexProvider(),
                ),
                ChangeNotifierProvider(
                  create: (context) => AudioPlayerProvider(),
                ),
                ChangeNotifierProvider(
                  create: (context) => DownloadController(reciterId: ''),
                ),
                ChangeNotifierProvider(
                  create: (context) => FavoriteReciter(),
                ),
                ChangeNotifierProvider(
                  create: (context) => FavoriteSurah(),
                ),
                ChangeNotifierProvider(
                  create: (context) => RecitationsManager(),
                ),
                ChangeNotifierProvider(
                  create: (context) => PlayerScreensController(),
                ),
                ChangeNotifierProvider(
                  create: (context) => NavigationControllerV3(),
                ),
                ChangeNotifierProvider(
                  create: (context) => SurahPagePlayPauseIndexProvider(),
                ),
                ChangeNotifierProvider(
                  create: (context) => DownloadedPagePlayPauseIndexProvider(),
                ),
              ],
              child: MaterialApp(
                title: 'Quran Listening Example',
                debugShowCheckedModeBanner: false,
                locale: Locale('en'),
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  useMaterial3: true,
                ),
                supportedLocales: const [
                  Locale('en', ''),
                  Locale('ar', ''),
                  Locale('fr', ''),
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  FallbackMaterialLocalizationsDelegate(),
                  FallbackCupertinoLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                themeMode: ThemeMode.system,
                home: const HomePage(),
              ),
            );
          }
        );
      }
    );
  }
}

