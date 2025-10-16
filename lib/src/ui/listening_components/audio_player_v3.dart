import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../mawaqit_quran_listening.dart';
import '../components/circular_button.dart';
import '../components/svg_image_asset.dart';
import '../components/watch_playback_confirmation_bottom_sheet.dart';
import 'package:mawaqit_quran_listening/src/utils/listening_utils/wear_connector.dart';

/// 1. Simple Audio Player (Slider updates audio position once)

/// 2. Simple Audio Player (Slider updates audio position continously while dragging)
/// 1. Simple Audio Player (with better slider)
/// - Slider updates audio position once
///
/// 2. Simple Audio Player
/// - Slider updates audio position continously while dragging

/// 1. Simple Audio Player (Slider updates audio position once)

enum QuranPlayerType { surah, ayah }

const double iconSize = 41;
const double iconSplashSize = 25;

class QuranAudioPlayerV3 extends StatefulWidget {
  final SurahModel chapter;
  final List<Reciter> reciters;

  ///At least one reciter
  final List<SurahModel> chapters;
  final PlayerType playerType;

  final Reciter? reciterFromAllSaved;

  const QuranAudioPlayerV3({
    required this.chapter,
    this.reciterFromAllSaved,
    required this.reciters,
    required this.chapters,
    required this.playerType,
    super.key,
  });

  @override
  QuranAudioPlayerV3State createState() => QuranAudioPlayerV3State();
}

class QuranAudioPlayerV3State extends State<QuranAudioPlayerV3> {
  bool isSliderDragged = false;
  late AudioPlayerProvider audioManager;
  double? _lastSliderValue;
  bool _isWatchConnected = false;
  static const double _headerActionWidth = 48;
  final GlobalKey<TooltipState> _watchTooltipKey = GlobalKey<TooltipState>();

  @override
  void initState() {
    super.initState();
    setAudio();
    _checkWatchConnection();
  }

  Future<void> _checkWatchConnection() async {
    final connected = await WearConnector.isWatchConnected();
    if (mounted) {
      setState(() {
        _isWatchConnected = connected;
      });
      if (connected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Slight delay to ensure layout is ready before showing tooltip
          Future.delayed(const Duration(milliseconds: 200), () {
            _watchTooltipKey.currentState?.ensureTooltipVisible();
          });
        });
      }
    }
  }

  Future setAudio() async {
    // Repeat song when completed
    print('audio starts now');
    Future.delayed(const Duration(milliseconds: 900), () async {
      if (!mounted) return;
      final artUri = await _loadAssetIconAsUri();
      audioManager = context.read<AudioPlayerProvider>();
      // final audioPlayer = audioManager;
      if (widget.playerType == audioManager.playerType) {
        if (widget.playerType == PlayerType.allSavedSurahs) {
          if (widget.reciterFromAllSaved?.id ==
                  audioManager.currentReciterDetail?.id &&
              widget.chapter.id == audioManager.playingChapter?.id) {
            ///Already Playing the same Chapter from Same Section
            audioManager.audioPlayer.play();
            audioManager.showHideFloatingPlayer(
              context: context,
              false,
              notify: false,
            );
            return;
          } else {
            ///Playing Other Chapter
            int chapterIndex = audioManager.chapters.indexWhere(
              (element) => element.id == widget.chapter.id,
            );
            if (chapterIndex != -1) {
              final downloadedManager = context.read<DownloadController>();
              List<AudioSource> playlist = [];

              ///Playing Other Surah/Chapter from same section
              for (int ind = 0; ind < widget.chapters.length; ind++) {
                final chap = widget.chapters[ind];
                String? path = downloadedManager.singleSavedRecitation(
                  reciterId: widget.reciters[ind].id,
                  recitationId: chap.id,
                );
                if (path != null) {
                  playlist.add(
                    AudioSource.file(
                      path,
                      tag: MediaItem(
                        id: chap.id.toString(),
                        title: chap.name ?? '',
                        album: widget.reciters[ind].reciterName,
                        artUri: artUri,
                        artist: widget.reciters[ind].reciterName,
                        displaySubtitle: widget.reciters[ind].reciterName,
                      ),
                    ),
                  );
                } else {
                  // Use the proper server URL for non-downloaded recitations
                  final serverUrl = audioManager.reciter?.serverUrl ?? '';
                  if (serverUrl.isNotEmpty) {
                    final audioUrl =
                        '${serverUrl}${chap.id.toString().padLeft(3, '0')}.mp3';
                    playlist.add(
                      AudioSource.uri(
                        Uri.parse(audioUrl),
                        tag: MediaItem(
                          id: chap.id.toString(),
                          title: chap.name ?? '',
                          album: widget.reciters[ind].reciterName,
                          artist: widget.reciters[ind].reciterName,
                          artUri: artUri,
                          displaySubtitle: widget.reciters[ind].reciterName,
                        ),
                      ),
                    );
                  }
                }
              }
              audioManager.setPlaylist(
                playlist,
                widget.chapters,
                widget.reciters,
                widget.playerType,
                index: 0,
              );
              audioManager.audioPlayer.setLoopMode(LoopMode.off);
              audioManager.showHideFloatingPlayer(
                context: context,
                false,
                notify: false,
              );
              return;
            } else {
              ///Play other section
              audioManager.disposePlayer(notify: false);
            }
          }
        } else {
          final reciter = widget.reciters.first;
          final reciterFromManager = audioManager.reciters.first;
          if (reciter.id == reciterFromManager.id) {
            ///When Player Screen is already playing for this reciter
            if (audioManager.playingChapter?.id == widget.chapter.id) {
              ///Already Playing the same Chapter from Same Section
              audioManager.audioPlayer.play();
              audioManager.showHideFloatingPlayer(
                context: context,
                false,
                notify: false,
              );
              return;
            } else {
              ///Playing Other Chapter
              int chapterIndex = audioManager.chapters.indexWhere(
                (element) => element.id == widget.chapter.id,
              );
              if (chapterIndex != -1) {
                ///Playing Other Surah/Chapter from same sectoin
                audioManager.playIndex(index: chapterIndex);
                audioManager.showHideFloatingPlayer(
                  context: context,
                  false,
                  notify: false,
                );
                return;
              } else {
                ///Play other section
                audioManager.disposePlayer(notify: false);
              }
            }
          } else {
            ///Play other section
            audioManager.disposePlayer(notify: false);
          }
        }
      } else {
        ///Play other section
        audioManager.disposePlayer(notify: false);
      }

      final downloadedManager = context.read<DownloadController>();
      List<AudioSource> playlist = [];
      if (widget.playerType == PlayerType.allSavedSurahs) {
        ///Building Playlist for all Saved Surahs
        for (int ind = 0; ind < widget.chapters.length; ind++) {
          final chap = widget.chapters[ind];
          String? path = downloadedManager.singleSavedRecitation(
            reciterId: widget.reciters[ind].id,
            recitationId: chap.id,
          );
          if (path != null) {
            playlist.add(
              AudioSource.file(
                path,
                tag: MediaItem(
                  id: chap.id.toString(),
                  title: chap.name ?? '',
                  album: widget.reciters[ind].reciterName,
                  artUri: artUri,
                  artist: widget.reciters[ind].reciterName,
                  displaySubtitle: widget.reciters[ind].reciterName,
                ),
              ),
            );
          } else {
            // Use the proper server URL for non-downloaded recitations
            final serverUrl = audioManager.reciter?.serverUrl ?? '';
            if (serverUrl.isNotEmpty) {
              final audioUrl =
                  '${serverUrl}${chap.id.toString().padLeft(3, '0')}.mp3';
              playlist.add(
                AudioSource.uri(
                  Uri.parse(audioUrl),
                  tag: MediaItem(
                    id: chap.id.toString(),
                    title: chap.name ?? '',
                    album: widget.reciters[ind].reciterName,
                    artUri: artUri,
                    artist: widget.reciters[ind].reciterName,
                    displaySubtitle: widget.reciters[ind].reciterName,
                  ),
                ),
              );
            }
          }
        }
      } else if (widget.playerType == PlayerType.reciterSavedSurahs) {
        ///Building Playlist for all Saved Surahs
        for (int ind = 0; ind < widget.chapters.length; ind++) {
          final chap = widget.chapters[ind];
          String? path = downloadedManager.singleSavedRecitation(
            reciterId: widget.reciters.first.id,
            recitationId: chap.id,
          );
          if (path != null) {
            playlist.add(
              AudioSource.file(
                path,
                tag: MediaItem(
                  id: chap.id.toString(),
                  title: chap.name ?? '',
                  album: widget.reciters.first.reciterName,
                  artUri: artUri,
                  artist: widget.reciters.first.reciterName,
                  displaySubtitle: widget.reciters.first.reciterName,
                ),
              ),
            );
          }
        }
      } else {
        ///Building Playlist
        final reciter = widget.reciters.first;
        for (int i = 0; i < widget.chapters.length; i++) {
          String? path = downloadedManager.singleSavedRecitation(
            reciterId: reciter.id,
            recitationId: widget.chapters[i].id,
          );
          if (path == null) {
            if (audioManager.reciter != null &&
                audioManager.reciter?.serverUrl != null &&
                (audioManager.reciter?.serverUrl?.isNotEmpty ?? false)) {
              playlist.add(
                AudioSource.uri(
                  Uri.parse(
                    '${audioManager.reciter?.serverUrl ?? ''}${widget.chapters[i].id.toString().padLeft(3, '0')}.mp3',
                  ),
                  tag: MediaItem(
                    id: widget.chapters[i].id.toString(),
                    title: widget.chapters[i].name ?? '',
                    album: reciter.reciterName,
                    artist: reciter.reciterName,
                    artUri: artUri,
                    displaySubtitle: reciter.reciterName,
                  ),
                ),
              );
            }
          } else {
            playlist.add(
              AudioSource.file(
                path,
                tag: MediaItem(
                  id: widget.chapters[i].id.toString(),
                  title: widget.chapters[i].name ?? '',
                  artUri: artUri,
                  artist: reciter.reciterName,
                  displaySubtitle: reciter.reciterName,
                  album: reciter.reciterName,
                ),
              ),
            );
          }
        }
      }

      ///Multiple Items
      if (playlist.isNotEmpty) {
        audioManager.setPlaylist(
          playlist,
          widget.chapters,
          widget.reciters,
          widget.playerType,
          index: 0,
        );

        audioManager.audioPlayer.setLoopMode(LoopMode.off);
        Future.delayed(const Duration(milliseconds: 100));
        audioManager.subscribeToStreams();
      } else {
        debugPrint('No valid audio sources in playlist');
      }
    });

    /// 2. Load audio from File
    /*
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = File(result.files.single.path!);
      audioPlayer.setUrl(file.path, isLocal: true);
    }
    */

    /// 3. Load audio from Assets (assets/audio.mp3)
    /// See docs: https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers/doc/audio_cache.md
    /*
    final player = AudioCache(prefix: 'assets/');
    final url = await player.load('audio.mp3');
    audioPlayer.setUrl(url.path, isLocal: true);
    */
  }

  @override
  void dispose() {
    if (!audioManager.isFloating) {
      audioManager.disposePlayer(notify: false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    audioManager = context.watch<AudioPlayerProvider>();
    final audioPlayer = audioManager.audioPlayer;
    return Container(
      key: const Key('audio_player_bottom_sheet'),
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        color:
            context.isDark
                ? Colors.transparent
                : context.colorScheme.primary.withOpacity(0.04),
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: _headerActionWidth,
                          child: _isWatchConnected
                              ? Tooltip(
                                  key: _watchTooltipKey,
                                  message: 'Play on your connected smartwatch',
                                  waitDuration: const Duration(milliseconds: 200),
                                  showDuration: const Duration(seconds: 2),
                                  child: IconButton(
                                    key: const Key('watch_play_icon'),
                                    icon: Icon(
                                      Icons.watch,
                                      color: context.colorScheme.primaryFixed,
                                    ),
                                    onPressed: () {
                                      // Build current audio URL like elsewhere
                                      final serverUrl = audioManager.reciter?.serverUrl ?? '';
                                      final chapterId = audioManager.playingChapter?.id;
                                      if (serverUrl.isEmpty || chapterId == null) return;
                                      final audioUrl = '$serverUrl${chapterId.toString().padLeft(3, '0')}.mp3';

                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: context.isDark ? const Color(0xff1C1B23) : Colors.white,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                        ),
                                        builder: (ctx) => WatchPlaybackConfirmationBottomSheet(
                                          onPlayOnWatch: () async {
                                            await WearConnector.sendRecitorUrl({
                                              'reciterName': audioManager.playingRecitor?.reciterName,
                                              'mushaf': audioManager.currentReciterDetail?.mainReciterId,
                                              'style': audioManager.currentReciterDetail?.style,
                                              'totalSurah': audioManager.currentReciterDetail?.totalSurah,
                                              'url': audioUrl,
                                            });
                                            Navigator.pop(ctx);
                                          },
                                          onPlayOnPhone: () {
                                            Navigator.pop(ctx);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${audioManager.playingChapter?.id.toString()} - ${audioManager.playingChapter?.name ?? ''}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: context.colorScheme.primaryFixed,
                                ),
                              ),
                              Text(
                                audioManager.reciters.isNotEmpty
                                    ? audioManager
                                            .playingRecitor
                                            ?.reciterName ??
                                        ''
                                    : '',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: context.colorScheme.primaryFixed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: _headerActionWidth,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: CircularButton(
                              icon: Icons.keyboard_arrow_down,
                              iconColor: context.colorScheme.primaryFixed,
                              size: 32,
                              borderColor: context.colorScheme.primaryFixed,
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                audioManager.showHideFloatingPlayer(true, context: context);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SliderTheme(
                      data: SliderThemeData(
                        overlayShape: SliderComponentShape.noThumb,
                        trackShape: CustomTrackShape(),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                      ),
                      child: Slider(
                        min: 0,
                        max: audioManager.duration.inSeconds.toDouble(),
                        value:
                            _lastSliderValue ??
                            (audioManager.position.inSeconds.toDouble() <
                                    audioManager.duration.inSeconds.toDouble()
                                ? audioManager.position.inSeconds.toDouble()
                                : audioManager.duration.inSeconds.toDouble()),
                        activeColor: context.colorScheme.primaryFixed,
                        inactiveColor: context.colorScheme.primaryFixed
                            .withOpacity(0.1),
                        onChanged: (value) {
                          final position = Duration(seconds: value.toInt());
                          setState(() {
                            isSliderDragged = true;
                            audioManager.position = position;
                            _lastSliderValue = value;
                          });
                        },
                        onChangeEnd: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await audioPlayer.seek(position);
                          isSliderDragged = false;
                          _lastSliderValue = null;
                        },
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatTime(audioManager.position),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: context.colorScheme.primaryFixed,
                                    ),
                                  ),
                                  Text(
                                    formatTime(
                                      audioManager.duration -
                                          audioManager.position,
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: context.colorScheme.primaryFixed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Shuffle playlist order (true|false)
                            IconButton(
                              splashRadius: iconSplashSize,
                              icon: SvgImageAsset(
                                'assets/icons/shuffle.svg',
                                color: context.colorScheme.primaryFixed,
                                width: audioPlayer.shuffleModeEnabled ? 30 : 20,
                              ),
                              onPressed: () async {
                                await audioPlayer.setShuffleModeEnabled(
                                  !audioPlayer.shuffleModeEnabled,
                                );
                              },
                            ),

                            /// Skip to the next item
                            Visibility(
                              visible: audioManager.playingChapterIndex != 0,
                              maintainState: true,
                              maintainAnimation: true,
                              maintainSize: true,
                              child: IconButton(
                                splashRadius: iconSplashSize,
                                icon: SvgImageAsset(
                                  context.isArabicLanguage
                                      ? 'assets/icons/ic_next_round.svg'
                                      : 'assets/icons/ic_previous_round.svg',
                                  color: context.colorScheme.primaryFixed,
                                ),
                                onPressed: () async {
                                  await audioPlayer.seekToPrevious();
                                },
                              ),
                            ),

                            ///Play/Pause/RePlay
                            CircularButton(
                              icon:
                                  audioPlayer.processingState ==
                                          ProcessingState.completed
                                      ? Icons.replay_rounded
                                      : audioManager.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                              iconColor: context.colorScheme.primaryFixed,
                              size: 62,
                              iconSize: 40,
                              color: context.colorScheme.primaryFixed
                                  .withOpacity(0.09),
                              borderColor: Colors.transparent,
                              onTap: () async {
                                if (audioPlayer.processingState ==
                                    ProcessingState.completed) {
                                  audioPlayer.seek(Duration.zero, index: 0);
                                } else if (audioManager.isPlaying) {
                                  await audioPlayer.pause();
                                } else {
                                  await audioPlayer.play();
                                }
                              },
                            ),

                            /// Skip to the next item
                            Visibility(
                              visible: audioManager.nextChapter != null,
                              maintainState: true,
                              maintainAnimation: true,
                              maintainSize: true,
                              child: IconButton(
                                splashRadius: iconSplashSize,
                                icon: SvgImageAsset(
                                  context.isArabicLanguage
                                      ? 'assets/icons/ic_previous_round.svg'
                                      : 'assets/icons/ic_next_round.svg',
                                  color: context.colorScheme.primaryFixed,
                                ),
                                onPressed: () async {
                                  await audioPlayer.seekToNext();
                                },
                              ),
                            ),

                            /// Set playlist to loop (off|all|one)
                            IconButton(
                              splashRadius: iconSplashSize,
                              icon: SvgImageAsset(
                                'assets/icons/loop.svg',
                                color: context.colorScheme.primaryFixed,
                                width:
                                    audioPlayer.loopMode == LoopMode.one
                                        ? 30
                                        : 20,
                              ),
                              onPressed: () async {
                                await audioPlayer.setLoopMode(
                                  audioPlayer.loopMode == LoopMode.one
                                      ? LoopMode.off
                                      : LoopMode.one,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Padding(
            key: const Key('player_bottom_sheet_arrow_down'),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CircularButton(
              icon: Icons.keyboard_arrow_down,
              iconColor: context.colorScheme.primaryFixed,
              size: 32,
              borderColor: context.colorScheme.primaryFixed,
              onTap: () {
                FocusScope.of(context).unfocus();
                audioManager.showHideFloatingPlayer(true, context: context);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}

const double kAvatarSize = 27;
const double kSplashRadius = 20;

/// Custom Track Shape
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const trackHeight = 8.0;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

Future<Uri> _loadAssetIconAsUri() async {
  final byteData = await rootBundle.load('assets/icons/media_logo.png');
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/audio_icon.png');
  await file.writeAsBytes(byteData.buffer.asUint8List());
  return file.uri;
}
