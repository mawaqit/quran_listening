import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/reciter.dart';
import '../models/surah_model.dart';

import 'package:provider/provider.dart';

import 'reciters_controller.dart';

enum PlayerType {
  allSavedSurahs,
  reciterLikedSurahs,
  reciterUnLikedSurahs,
  reciterSavedSurahs,
}

class AudioPlayerProvider extends ChangeNotifier {
  AudioPlayer _audioPlayer = AudioPlayer();
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

  void showHideFloatingPlayer(
    bool value, {
    BuildContext? context,
    bool notify = true,
  }) {
    if (value == _isFloating) return;
    _isFloating = value;
    if (_isFloating && context != null) {
      // floatingPlayer = OverlayEntry(builder: (context) {
      //   return const FloatingQuranPlayer();
      // });
      // Overlay.of(context).insert(floatingPlayer!);
    } else if (!_isFloating && floatingPlayer != null) {
      // floatingPlayer?.remove();
    }
    if (notify) notifyListeners();
  }

  set position(Duration value) {
    _position = value;
    // _audioPlayer.seek(value);
    notifyListeners();
  }

  //Shuffle Setter
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
            ? recitersController.reciters.firstWhere(
              (element) => element.id == currentReciterId,
            )
            : null;
    return reciter;
  }

  getCurrentReciterV3({required BuildContext context}) {
    reciter =
        context.read<RecitorsProvider>().reciters.isNotEmpty
            ? context.read<RecitorsProvider>().reciters.firstWhere(
              (element) => element.id == currentReciterId,
            )
            : null;
    return reciter;
  }

  SurahModel? get nextChapter =>
      playingChapterIndex != null && playingChapterIndex! + 1 < chapters.length
          ? chapters[playingChapterIndex! + 1]
          : null;

  Reciter? get currentReciterDetail =>
      playingChapterIndex != null && reciters.length != 1
          ? reciters[playingChapterIndex!]
          : reciters[0];

  // Reciter? get reciter => reciters.isEmpty || playingChapterIndex == null
  //     ? null
  //     : playerType == PlayerType.allSavedSurahs
  //         ? reciters[playingChapterIndex!]
  //         : reciters.first;

  AudioPlayer get audioPlayer => _audioPlayer;

  bool get isPlaying => _isPlaying;

  bool get isFloating => _isFloating;

  Duration get duration => _duration;

  Duration get position => _position;

  bool get isLooping => _isLooping;

  double get playbackSpeed => _playbackSpeed;

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
    // if (!_audioPlayer.playing) {
    //   _audioPlayer.play();
    // }
    /// Load and play the playlist
    await _audioPlayer.setAudioSource(_playlist, initialIndex: index);
    await _audioPlayer.play();
  }

  /// Play specific item from the playlist
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
  Duration _lastNotifiedPosition = Duration.zero;

  void subscribeToStreams() {
    // prevent double subscription
    if (_playerStateSub != null) return;

    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _durationSub = _audioPlayer.durationStream.listen((newDuration) {
      _duration = newDuration ?? Duration.zero;
      notifyListeners();
    });
    _positionSub = _audioPlayer.positionStream.listen((newPosition) {
      _position = newPosition;
      if (_position.inSeconds != _lastNotifiedPosition.inSeconds) {
        _lastNotifiedPosition = _position;
      }
    });

    _indexSub = _audioPlayer.currentIndexStream.listen((event) {
      if (event != null) {
        playingChapterIndex = event;
        playingChapter = chapters[event];
        playingChapterId = playingChapter!.id;
        if (event >= 0 && event < reciters.length) {
          playingRecitor = reciters[event];
        } else {
          playingRecitor = reciters.first;
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
    final currentSurah = reciterController.surahList.firstWhere(
      (element) => element.id == playingChapter!.id,
    );
    return currentSurah;
  }

  void disposePlayer({bool notify = true}) {
    showHideFloatingPlayer(false, notify: false);
    reciters = [];
    chapters = [];
    playingChapter = null;
    playingChapterId = null;
    playingChapterIndex = null;
    _isPlaying = false;
    _isLooping = false;
    _isShuffled = false;

    // cancel stream subs
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

    // create a fresh player
    _audioPlayer = AudioPlayer();

    if (notify) notifyListeners();
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

  // Future<void> seek(Duration position) async {
  //   await _audioPlayer.seek(position);
  // }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    if (_isShuffled) {
      _audioPlayer.setShuffleModeEnabled(true);
    } else {
      _audioPlayer.setShuffleModeEnabled(false);
    }
  }

  // Method to play the current playlist
  void playPlaylist() {
    if (_isShuffled) {
      _audioPlayer.shuffle();
    }
    _audioPlayer.play();
  }

  // Method to play a specific item in the playlist
  //   Future<void> playPlaylistItem(int index) async {
  //     if (_isShuffled) {
  //       _audioPlayer.setssetShuffleOrder(ShuffleOrder.random);
  //     }
  //     await _audioPlayer.seek(Duration.zero, index: index);
  //     _audioPlayer.play();
  //   }

  // Method to play the next item in the playlist
  //   void playNext() {
  //     int nextIndex = _audioPlayer.currentIndex + 1;
  //     if (nextIndex >= _playlist.length) {
  //       nextIndex = 0;
  //     }
  //     playPlaylistItem(nextIndex);
  //   }
  //
  // // Method to play the previous item in the playlist
  //   void playPrevious() {
  //     int previousIndex = _audioPlayer.currentIndex - 1;
  //     if (previousIndex < 0) {
  //       previousIndex = _playlist.length - 1;
  //     }
  //     playPlaylistItem(previousIndex);
  //   }
}

/*class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Reciter>? reciters;
  Reciter? currentReciter;
  Reciter? currentReciterDetail;
  SurahModel? currentSurah;
  SurahModel? playingChapter;
  List<SurahModel> chapters = [];
  PlayerType? playerType;
  bool isFloating = false;
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  int playingChapterIndex = 0;

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<void> playAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    isPlaying = false;
    notifyListeners();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    isPlaying = false;
    notifyListeners();
  }

  void showHideFloatingPlayer(
    bool show, {
    required BuildContext context,
    bool notify = true,
  }) {
    isFloating = show;
    if (notify) {
      notifyListeners();
    }
  }

  Reciter getCurrentReciter({required BuildContext context}) {
    return currentReciter ??
        reciters?.first ??
        Reciter(id: 0, mainReciterId: 0, reciterName: 'Unknown', mushaf: []);
  }

  void setCurrentReciter(Reciter reciter) {
    currentReciter = reciter;
    notifyListeners();
  }

  void setCurrentSurah(SurahModel surah) {
    currentSurah = surah;
    notifyListeners();
  }

  // Additional methods required by the main app
  SurahModel? get nextChapter {
    if (playingChapterIndex < chapters.length - 1) {
      return chapters[playingChapterIndex + 1];
    }
    return null;
  }

  void setPlaylist(
    List<AudioSource> playlist,
    dynamic chapters, // Accept any type of chapters
    dynamic reciters, // Accept any type of reciters
    PlayerType playerType, {
    int index = 0,
  }) {
    // Convert to package models if needed
    this.chapters = chapters is List ? chapters.cast<SurahModel>() : [];
    this.reciters = reciters is List ? reciters.cast<Reciter>() : [];
    this.playerType = playerType;
    this.playingChapterIndex = index;
    this.playingChapter =
        this.chapters.isNotEmpty ? this.chapters[index] : null;
    currentReciterDetail =
        (reciters != null && reciters!.isNotEmpty) ? reciters!.first : null;

    _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: playlist));
    notifyListeners();
  }

  void playIndex({required int index}) {
    if (index < chapters.length) {
      playingChapterIndex = index;
      playingChapter = chapters[index];
      _audioPlayer.seek(Duration.zero, index: index);
      notifyListeners();
    }
  }

  void disposePlayer({bool notify = true}) {
    _audioPlayer.dispose();
    if (notify) {
      notifyListeners();
    }
  }

  void subscribeToStreams() {
    _audioPlayer.positionStream.listen((position) {
      this.position = position;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      this.duration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.playingStream.listen((playing) {
      isPlaying = playing;
      notifyListeners();
    });
  }

  SurahModel? getCurrentPlayingSurah({required BuildContext context}) {
    return playingChapter;
  }

  Reciter? get reciter => currentReciter;
  Reciter? get playingRecitor => currentReciterDetail;

  void setPlayingRecitor(Reciter reciter) {
    currentReciterDetail = reciter;
    notifyListeners();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }
}*/
