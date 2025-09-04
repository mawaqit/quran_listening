import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/reciter.dart';
import '../models/surah_model.dart';

enum PlayerType {
  allSavedSurahs,
  reciterLikedSurahs,
  reciterUnLikedSurahs,
  reciterSavedSurahs,
}

class AudioPlayerProvider extends ChangeNotifier {
  AudioPlayer _audioPlayer = AudioPlayer();
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

  SurahModel? get nextChapter =>
      playingChapterIndex != null && playingChapterIndex! + 1 < chapters.length
          ? chapters[playingChapterIndex! + 1]
          : null;

  Reciter? get currentReciterDetail =>
      playingChapterIndex != null && reciters.length != 1
          ? reciters[playingChapterIndex!]
          : reciters[0];

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
    await _audioPlayer.stop();
    playerType = playerType1;
    chapters = chaptersList;
    reciters = reciter1;
    playingChapterIndex = index ?? 0;
    if (playingChapterIndex! >= chaptersList.length) {
      playingChapterIndex = 0;
    }
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
    audioPlayer.playerStateStream.listen((state) {
      _isPlaying = audioPlayer.playerState.playing;
      notifyListeners();
    });

    audioPlayer.durationStream.listen((newDuration) {
      _duration = newDuration ?? Duration.zero;
      notifyListeners();
    });

    audioPlayer.positionStream.listen((newPosition) {
      _position = newPosition;
      notifyListeners();
    });

    audioPlayer.currentIndexStream.listen((event) {
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

    audioPlayer.loopModeStream.listen((event) {
      _loopMode = event;
      notifyListeners();
    });

    audioPlayer.shuffleModeEnabledStream.listen((event) {
      _isShuffled = event;
      notifyListeners();
    });
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
    audioPlayer.dispose();
    playerType = null;
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
}
