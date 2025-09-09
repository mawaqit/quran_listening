import '../core/database/hive_manager.dart';

/// Configuration class for the Quran Listening package
/// This class handles initialization and setup of the package
class QuranListeningConfig {
  static bool _isInitialized = false;
  static ReciterHiveManager? _hiveManager;

  /// Initialize the package with required dependencies
  static Future<void> initialize({ReciterHiveManager? hiveManager}) async {
    if (_isInitialized) return;

    _hiveManager = hiveManager ?? ReciterHiveManager();
    await _hiveManager!.init();

    _isInitialized = true;
  }

  /// Get the initialized HiveManager instance
  static ReciterHiveManager get hiveManager {
    if (!_isInitialized || _hiveManager == null) {
      throw Exception(
        'QuranListeningConfig not initialized. Call initialize() first.',
      );
    }
    return _hiveManager!;
  }

  /// Check if the package is initialized
  static bool get isInitialized => _isInitialized;

  /// Reset the configuration (useful for testing)
  static void reset() {
    _isInitialized = false;
    _hiveManager = null;
  }
}
