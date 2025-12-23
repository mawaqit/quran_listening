import 'package:flutter/material.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QuranListeningConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Quran Listening Package Providers
        ChangeNotifierProvider(create: (_) => RecitorsProvider(
            QuranListeningRepository(QuranListeningConfig.hiveManager)
        )),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        ChangeNotifierProvider(create: (_) => DownloadController(reciterId: '')),
        ChangeNotifierProvider(create: (_) => FavoriteReciter()),
        ChangeNotifierProvider(create: (_) => FavoriteSurah()),
        ChangeNotifierProvider(create: (_) => RecitationsManager()),
        ChangeNotifierProvider(create: (_) => PlayerScreensController()),
        ChangeNotifierProvider(create: (_) => NavigationControllerV3()),
        ChangeNotifierProvider(create: (_) => ListeningToggleIndexProvider()),
        ChangeNotifierProvider(create: (_) => SurahPagePlayPauseIndexProvider()),
        ChangeNotifierProvider(create: (_) => DownloadedPagePlayPauseIndexProvider()),
      ],
      child: MaterialApp(
        title: 'Quran Listening',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MyHomePage(title: 'Quran listening'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: QuranListeningPage());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecitorsProvider>().cacheReciters();
    });
  }
}
