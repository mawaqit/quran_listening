import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../models/reciter.dart';
import '../models/surah_model.dart';
import 'reciters_controller.dart';

enum PlayerType {
  allSavedSurahs,
  reciterLikedSurahs,
  reciterUnLikedSurahs,
  reciterSavedSurahs,
}

class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // stream subs
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<LoopMode>? _loopModeSub;
  StreamSubscription<bool>? _shuffleSub;

  OverlayEntry? floatingPlayer;
  PlayerType? playerType;

  List<Reciter> reciters = [];
  Reciter? reciter;
  Reciter? playingRecitor;
  int? currentReciterId;
  late List<SurahModel> chapters;
  late ConcatenatingAudioSource _playlist;

  SurahModel? playingChapter;
  int? playingChapterIndex;
  int? playingChapterId;

  bool _isPlaying = false;
  bool _isFloating = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isShuffled = false;
  LoopMode _loopMode = LoopMode.off;
  bool _isLooping = false;
  double _playbackSpeed = 1.0;

  // to avoid spam from position
  Duration _lastNotifiedPosition = Duration.zero;

  // ===== getters =====
  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  bool get isFloating => _isFloating;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isLooping => _isLooping;
  double get playbackSpeed => _playbackSpeed;

  SurahModel? get nextChapter =>
      playingChapterIndex != null && playingChapterIndex! + 1 < chapters.length
          ? chapters[playingChapterIndex! + 1]
          : null;

  Reciter? get currentReciterDetail {
    if (reciters.isEmpty) return null;
    if (playingChapterIndex != null &&
        playingChapterIndex! >= 0 &&
        playingChapterIndex! < reciters.length &&
        reciters.length != 1) {
      return reciters[playingChapterIndex!];
    }
    return reciters.first;
  }

  void showHideFloatingPlayer(
      bool value, {
        BuildContext? context,
        bool notify = true,
      }) {
    if (value == _isFloating) return;
    _isFloating = value;
    if (notify) notifyListeners();
  }

  set position(Duration value) {
    _position = value;
    notifyListeners();
  }

  set loopMode(LoopMode value) {
    _loopMode = value;
    _audioPlayer.setLoopMode(_loopMode);
    notifyListeners();
  }

  set isLooping(bool value) {
    _isLooping = value;
    _audioPlayer.setLoopMode(value ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  set playbackSpeed(double value) {
    _playbackSpeed = value;
    _audioPlayer.setSpeed(value);
    notifyListeners();
  }

  changeReciter(Reciter newReciter) {
    reciter = newReciter;
    currentReciterId = newReciter.id;
    notifyListeners();
  }

  void setPlayingRecitor(Reciter recitor) {
    playingRecitor = recitor;
    notifyListeners();
  }

  getCurrentReciter({required BuildContext context}) {
    final recitersController = Provider.of<RecitorsProvider>(
      context,
      listen: false,
    );
    reciter =
    recitersController.reciters.isNotEmpty
        ? recitersController.reciters
        .firstWhere((element) => element.id == currentReciterId)
        : null;
    return reciter;
  }

  getCurrentReciterV3({required BuildContext context}) {
    reciter =
    context.read<RecitorsProvider>().reciters.isNotEmpty
        ? context
        .read<RecitorsProvider>()
        .reciters
        .firstWhere((element) => element.id == currentReciterId)
        : null;
    return reciter;
  }

  Future<void> setPlaylist(
      List<AudioSource> playlist,
      List<SurahModel> chaptersList,
      List<Reciter> reciter1,
      PlayerType playerType1, {
        int? index,
      }) async {
    playerType = playerType1;
    chapters = chaptersList;
    reciters = reciter1;
    playingChapterIndex = index ?? 0;
    playingChapter = chapters[playingChapterIndex!];
    playingChapterId = playingChapter!.id;
    notifyListeners();

    _playlist = ConcatenatingAudioSource(children: playlist);
    await _audioPlayer.setAudioSource(_playlist, initialIndex: index);
    await _audioPlayer.play();
  }

  Future<void> playIndex({int? index}) async {
    if (index != null) {
      await _audioPlayer.seek(Duration.zero, index: index);
      _audioPlayer.play();
    }
  }

  Future<void> setAudioSource(String url) async {
    await _audioPlayer.setAudioSource(
      AudioSource.uri(Uri.parse(url)),
      initialPosition: Duration.zero,
      preload: true,
    );
  }

  void subscribeToStreams() {
    if (_playerStateSub != null) return;

    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _durationSub = _audioPlayer.durationStream.listen((newDuration) {
      _duration = newDuration ?? Duration.zero;
      notifyListeners();
    });

    // high-frequency → no notify here
    _positionSub = _audioPlayer.positionStream.listen((newPosition) {
      _position = newPosition;
      if (_position.inSeconds != _lastNotifiedPosition.inSeconds) {
        _lastNotifiedPosition = _position;
      }
    });

    _indexSub = _audioPlayer.currentIndexStream.listen((event) {
      if (event != null) {
        playingChapterIndex = event;
        if (chapters.isNotEmpty && event < chapters.length) {
          playingChapter = chapters[event];
          playingChapterId = playingChapter!.id;
        } else {
          playingChapter = null;
          playingChapterId = null;
        }

        if (reciters.isNotEmpty) {
          if (event >= 0 && event < reciters.length) {
            playingRecitor = reciters[event];
          } else {
            playingRecitor = reciters.first;
          }
        } else {
          playingRecitor = null;
        }

        notifyListeners();
      }
    });

    _loopModeSub = _audioPlayer.loopModeStream.listen((event) {
      _loopMode = event;
      notifyListeners();
    });

    _shuffleSub = _audioPlayer.shuffleModeEnabledStream.listen((event) {
      _isShuffled = event;
      notifyListeners();
    });
  }

  getCurrentPlayingSurah({required BuildContext context}) {
    final reciterController = Provider.of<RecitorsProvider>(
      context,
      listen: false,
    );
    if (playingChapter == null) return;
    final currentSurah = reciterController.surahList
        .firstWhere((element) => element.id == playingChapter!.id);
    return currentSurah;
  }

  // 🔹 SOFT dispose: what your UI calls when switching surahs
  void disposePlayer({bool notify = true}) {
    showHideFloatingPlayer(false, notify: false);

    _isPlaying = false;
    _isLooping = false;
    _isShuffled = false;

    // just stop current audio, keep player and streams
    _audioPlayer.stop();

    if (notify) notifyListeners();
  }

  // 🔹 HARD dispose: called only when provider itself is destroyed
  void _hardDisposePlayer() {
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _indexSub?.cancel();
    _loopModeSub?.cancel();
    _shuffleSub?.cancel();

    _playerStateSub = null;
    _durationSub = null;
    _positionSub = null;
    _indexSub = null;
    _loopModeSub = null;
    _shuffleSub = null;

    _audioPlayer.dispose();
  }

  void toggleIsPlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  Future<void> play() async {
    try {
      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      notifyListeners();
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _audioPlayer.seek(_audioPlayer.position);
      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      debugPrint('Error resuming audio: $e');
    }
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    if (_isShuffled) {
      _audioPlayer.setShuffleModeEnabled(true);
    } else {
      _audioPlayer.setShuffleModeEnabled(false);
    }
  }

  void playPlaylist() {
    if (_isShuffled) {
      _audioPlayer.shuffle();
    }
    _audioPlayer.play();
  }

  /// Safely seek to next track, handling shuffle mode
  Future<void> seekToNextSafe() async {
    try {
      final sequenceState = _audioPlayer.sequenceState;
      if (sequenceState == null) return;

      final currentIndex = sequenceState.currentIndex;
      final sequenceLength = sequenceState.sequence.length;
      final indexBefore = currentIndex;

      if (_audioPlayer.shuffleModeEnabled) {
        await _audioPlayer.seekToNext();
        
        final newSequenceState = _audioPlayer.sequenceState;
        final indexAfter = newSequenceState.currentIndex;
        
        if (indexAfter == indexBefore) {
          await _audioPlayer.shuffle();
          await _audioPlayer.seekToNext();
        }
      } else {
        if (currentIndex != null && currentIndex < sequenceLength - 1) {
          await _audioPlayer.seekToNext();
        }
      }
    } catch (e) {
      debugPrint('Error seeking to next: $e');
    }
  }

  /// Safely seek to previous track, handling shuffle mode
  Future<void> seekToPreviousSafe() async {
    try {
      final sequenceState = _audioPlayer.sequenceState;
      if (sequenceState == null) return;

      final currentIndex = sequenceState.currentIndex;
      final indexBefore = currentIndex;

      if (_audioPlayer.shuffleModeEnabled) {
        if (currentIndex == 0) {
          await _audioPlayer.shuffle();
          final sequenceLength = sequenceState.sequence.length;
          if (sequenceLength > 1) {
            await _audioPlayer.seek(Duration.zero, index: sequenceLength - 1);
          }
        } else {
          await _audioPlayer.seekToPrevious();
          
          final newSequenceState = _audioPlayer.sequenceState;
          final indexAfter = newSequenceState.currentIndex;
          
          if (indexAfter == indexBefore) {
            await _audioPlayer.shuffle();
            await _audioPlayer.seekToPrevious();
          }
        }
      } else {
        if (currentIndex != null && currentIndex > 0) {
          await _audioPlayer.seekToPrevious();
        }
      }
    } catch (e) {
      debugPrint('Error seeking to previous: $e');
    }
  }

  @override
  void dispose() {
    _hardDisposePlayer();
    super.dispose();
  }
}
