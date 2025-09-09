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

### Step 1: Initialize the Package

Add this to your `main.dart` file:

```dart
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the package
  await QuranListeningConfig.initialize();
  
  runApp(MyApp());
}
```

### Step 2: Add Required Providers

Add these providers to your app's provider tree (usually in your main app widget):

```dart
import 'package:provider/provider.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';

class MyApp extends StatelessWidget {
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
        home: MyHomePage(),
      ),
    );
  }
}
```

### Step 3: Use the Package

Simply add the `QuranListeningPage` widget to your app:

```dart
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quran Listening')),
      body: QuranListeningPage(), // This is all you need!
    );
  }
}
```

That's it! The package will handle all the audio playback, downloads, favorites, and UI automatically.

## Configuration

### Automatic Configuration

**Good news!** The package handles all configuration automatically. You don't need to configure anything manually.

The package comes with sensible defaults for:
- ✅ Audio quality and playback settings
- ✅ Download management and storage
- ✅ UI themes and styling
- ✅ Database setup and management
- ✅ API endpoints and caching

### Optional Customization (Advanced Users Only)

If you need to customize the package behavior, you can access these settings:

```dart
// Audio settings (optional)
final audioProvider = context.read<AudioPlayerProvider>();
audioProvider.setPlaybackSpeed(1.5);  // Change playback speed
audioProvider.setLoopMode(LoopMode.one);  // Set loop mode

// Download settings (optional)
final downloadController = context.read<DownloadController>();
// Download quality and concurrent downloads are handled automatically
```

**For most users:** Just follow the 3 steps in the Usage section above - no additional configuration needed!
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


**Made with ❤️ by the Mawaqit Team**
