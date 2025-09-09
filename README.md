# Mawaqit Quran Listening

A comprehensive Flutter package that provides Quran listening functionality, enabling easy access, display, and navigation of Surahs and Ayahs with advanced audio playback capabilities.

## Features

### 🎵 Audio Playback
- **Multiple Reciters**: Access to various Quran reciters with different styles
- **High-Quality Audio**: Stream and download high-quality Quran recitations
- **Background Playback**: Continue listening while using other apps
- **Audio Controls**: Play, pause, seek, shuffle, and loop functionality
- **Playback Speed**: Adjustable playback speed (0.5x to 2.0x)

### 📱 User Interface
- **Modern UI Components**: Beautiful, responsive UI components
- **Tabbed Navigation**: Organized tabs for different listening modes
- **Search Functionality**: Search for reciters and surahs
- **Floating Player**: Minimizable audio player for continuous listening
- **Dark/Light Theme**: Supports both dark and light themes

### 💾 Offline Capabilities
- **Download Management**: Download surahs for offline listening
- **Storage Management**: Efficient local storage with Hive database
- **Download Progress**: Real-time download progress tracking
- **Offline Playback**: Play downloaded content without internet

### ⭐ Personalization
- **Favorite Reciters**: Mark and manage favorite reciters
- **Favorite Surahs**: Save frequently listened surahs
- **Playlist Management**: Create and manage custom playlists
- **Listening History**: Track listening progress and history

### 🔍 Advanced Features
- **Smart Search**: Search across reciters, surahs, and content
- **Recitation Management**: Organize recitations by different criteria
- **Audio Quality Selection**: Choose between different audio qualities
- **Progress Tracking**: Save and resume listening progress

## Installation

Add this package to your `pubspec.yaml` file:

```yaml
dependencies:
  mawaqit_quran_listening:
    path: packages/quran_listening  # For local development
    # OR
    # git:
    #   url: https://github.com/your-repo/mawaqit_quran_listening.git
    #   ref: main
```

Then run:
```bash
flutter pub get
```

### Required Dependencies

The package automatically includes these dependencies:
- `provider` - State management
- `just_audio` - Audio playback
- `hive` - Local storage
- `dio` - HTTP requests
- `flutter_svg` - SVG support
- `sizer` - Responsive design

## Usage

### 1. Basic Setup

First, initialize the package in your `main.dart`:

```dart
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the package
  await QuranListeningConfig.initialize();
  
  runApp(MyApp());
}
```

### 2. Provider Setup

Add the required providers to your app's provider tree:

```dart
import 'package:provider/provider.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core providers
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
        home: MyHomePage(),
      ),
    );
  }
}
```

### 3. Basic Usage

#### Display the Quran Listening Page

```dart
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quran Listening')),
      body: QuranListeningPage(),
    );
  }
}
```

#### Play Audio Programmatically

```dart
class AudioController {
  final AudioPlayerProvider audioProvider;
  
  AudioController(this.audioProvider);
  
  Future<void> playSurah(Reciter reciter, SurahModel surah) async {
    await audioProvider.playSurah(
      reciter: reciter,
      surah: surah,
      context: context,
    );
  }
  
  Future<void> pauseAudio() async {
    await audioProvider.pause();
  }
  
  Future<void> resumeAudio() async {
    await audioProvider.play();
  }
}
```

#### Download Surahs for Offline Use

```dart
class DownloadManager {
  final DownloadController downloadController;
  
  DownloadManager(this.downloadController);
  
  Future<void> downloadSurah(Reciter reciter, SurahModel surah) async {
    await downloadController.downloadSurah(
      reciterId: reciter.id.toString(),
      surahId: surah.id,
    );
  }
  
  List<SurahAudio> getDownloadedSurahs() {
    return downloadController.downloadedSurahs;
  }
}
```

## Configuration

### Package Configuration

The package requires minimal configuration. The main configuration is handled through the `QuranListeningConfig` class:

```dart
// Initialize with custom Hive manager
await QuranListeningConfig.initialize(
  hiveManager: CustomHiveManager(),
);

// Check if initialized
if (QuranListeningConfig.isInitialized) {
  // Package is ready to use
}

// Get the Hive manager instance
final hiveManager = QuranListeningConfig.hiveManager;
```

### Audio Configuration

Configure audio settings through the `AudioPlayerProvider`:

```dart
final audioProvider = context.read<AudioPlayerProvider>();

// Set playback speed
audioProvider.setPlaybackSpeed(1.5);

// Set loop mode
audioProvider.setLoopMode(LoopMode.one);

// Enable shuffle
audioProvider.setShuffle(true);
```

### Download Configuration

Configure download settings through the `DownloadController`:

```dart
final downloadController = context.read<DownloadController>();

// Set download quality
downloadController.setDownloadQuality(AudioQuality.high);

// Set maximum concurrent downloads
downloadController.setMaxConcurrentDownloads(3);
```
## Roadmap

### Planned Features

#### 🎵 Enhanced Audio Features
- **Playlist Support**: Create and manage custom playlists
- **Crossfade**: Smooth transitions between tracks
- **Audio Effects**: Equalizer and audio enhancement options
- **Sleep Timer**: Auto-stop playback after specified time

#### 📱 UI/UX Improvements
- **Custom Themes**: More theme customization options
- **Gesture Controls**: Swipe gestures for navigation
- **Accessibility**: Enhanced accessibility features
- **Animations**: Smooth transitions and micro-interactions

#### 💾 Advanced Offline Features
- **Batch Downloads**: Download multiple surahs at once
- **Smart Downloads**: Automatic download based on usage patterns
- **Cloud Sync**: Sync favorites and playlists across devices
- **Storage Optimization**: Better storage management and cleanup

#### 🔍 Enhanced Search & Discovery
- **Voice Search**: Search using voice commands
- **Recommendations**: AI-powered content recommendations
- **Categories**: Organize reciters by style, region, etc.
- **Recently Played**: Quick access to recently played content

#### 🌐 Integration Features
- **Widget Support**: Home screen widgets for quick access
- **Notification Controls**: Enhanced notification player controls
- **CarPlay/Android Auto**: In-car audio integration
- **Wearable Support**: Smartwatch companion app

#### 📊 Analytics & Insights
- **Listening Statistics**: Track listening habits and progress
- **Progress Tracking**: Detailed progress tracking per surah
- **Achievements**: Gamification elements for consistent listening
- **Export Data**: Export listening data and statistics

### Version History

- **v1.0.0** - Initial release with core functionality
- **v1.1.0** - Added download management and offline playback
- **v1.2.0** - Enhanced UI components and search functionality
- **v1.3.0** - Added floating player and background playback
- **v2.0.0** - Major UI overhaul and performance improvements

### Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to contribute to this project.

### License

This package is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

### Support

For support and questions:
- Create an issue on GitHub
- Contact the development team
- Check the documentation wiki

---

**Made with ❤️ by the Mawaqit Team**
