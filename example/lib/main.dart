import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';
import 'package:super_converter/converter/converter.dart';
import 'package:super_converter/converter/sub_converters/from_map_converter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter('quran_listening');

  // Initialize JustAudioBackground
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.quran_listening',
    androidNotificationChannelName: 'Quran Listening',
    androidNotificationOngoing: true,
  );

  // Register converters for super_converter package
  SuperConverter.registerConverters([
    FromMapConverter<AudioQuran>(AudioQuran.fromMap),
    FromMapConverter<SurahAudio>(SurahAudio.fromMap),
    FromMapConverter<Reciter>(Reciter.fromMap),
    FromMapConverter<Recitation>(Recitation.fromMap),
  ]);

  // Initialize Quran Listening Package
  await QuranListeningConfig.initialize();

  runApp(const QuranListeningExampleApp());
}

