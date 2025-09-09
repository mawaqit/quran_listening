/// Mawaqit Quran Listening Package
///
/// A comprehensive Flutter package for Quran listening functionality including:
/// - Audio playback with multiple reciters
/// - Surah navigation and management
/// - Download and offline capabilities
/// - Favorite reciters and surahs
/// - Search functionality
///
/// This package provides a complete Quran listening experience with a consistent
/// UI that integrates seamlessly with the Mawaqit app theme.

library mawaqit_quran_listening;

// Core exports
export 'src/core/api/quran_api.dart';
export 'src/core/database/hive_manager.dart';
export 'src/core/repository/quran_listening_repository.dart';

// Models
export 'src/models/reciter.dart';
export 'src/models/surah_model.dart';
export 'src/models/recitation.dart';
export 'src/models/quran_audio.dart';
export 'src/models/surah_audio.dart';

// Providers
export 'src/providers/audio_provider.dart';
export 'src/providers/reciters_controller.dart';
export 'src/providers/download_controller.dart';
export 'src/providers/favorite_reciter.dart';
export 'src/providers/favorite_surah.dart';
export 'src/providers/player_screens_controller.dart';
export 'src/providers/listening_toggle_index_provider.dart';
export 'src/providers/play_pause_id_provider.dart';
export 'src/providers/navigation_controller_v3.dart';
export 'src/providers/recitation_controller.dart';



// Pages
export 'src/ui/pages/quran_listening_page.dart';
export 'src/ui/pages/surah_page.dart';

// Tabs
export 'src/ui/pages/tabs/all_recitators_tab.dart';
export 'src/ui/pages/tabs/downloaded_tab.dart';
export 'src/ui/pages/tabs/liked_tab.dart';

// Utils
export 'src/utils/listening_utils/fake_recitors_list.dart';
export 'src/utils/listening_utils/fake_recitors_list_data.dart';

// Extensions
export 'src/extensions/theme_extension.dart';

// Configuration
export 'src/config/package_config.dart';
