/// 1. Simple Audio Player (with better slider)
/// - Slider updates audio position once
///
/// 2. Simple Audio Player
/// - Slider updates audio position continously while dragging
library;

import 'dart:async';

/// 1. Simple Audio Player (Slider updates audio position once)

/// 2. Simple Audio Player (Slider updates audio position continously while dragging)
/// 1. Simple Audio Player (with better slider)
/// - Slider updates audio position once
///
/// 2. Simple Audio Player
/// - Slider updates audio position continously while dragging

/// 1. Simple Audio Player (Slider updates audio position once)

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';
import 'package:mawaqit_quran_listening/src/ui/components/circular_button.dart';
import 'package:mawaqit_quran_listening/src/ui/components/svg_image_asset.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

const double iconSize = 41;
const double iconSplashSize = 25;

class QuranAudioPlayer extends StatefulWidget {
  final SurahModel chapter;
  final List<Reciter> reciters;

  ///At least one reciter
  final List<SurahModel> chapters;
  final PlayerType playerType;

  final Reciter? reciterFromAllSaved;

  const QuranAudioPlayer({
    required this.chapter,
    this.reciterFromAllSaved,
    required this.reciters,
    required this.chapters,
    required this.playerType,
    super.key,
  });

  @override
  QuranAudioPlayerState createState() => QuranAudioPlayerState();
}

class QuranAudioPlayerState extends State<QuranAudioPlayer> {
  bool isSliderDragged = false;
  late AudioPlayerProvider audioManager;
  double? _lastSliderValue;

  @override
  void initState() {
    super.initState();
    setAudio();
  }

  Future setAudio() async {
    // Repeat song when completed
    print('audio starts now');
    Future.delayed(const Duration(milliseconds: 900), () async {
      if (!mounted) return;
      audioManager = context.read<AudioPlayerProvider>();
      final audioPlayer = audioManager.audioPlayer;

      if (widget.playerType == audioManager.playerType) {
        if (widget.playerType == PlayerType.allSavedSurahs) {
          if (widget.reciterFromAllSaved?.id ==
                  audioManager.currentReciterDetail?.id &&
              widget.chapter.id == audioManager.playingChapter?.id) {
            ///Already Playing the same Chapter from Same Section
            audioPlayer.play();
            audioManager.showHideFloatingPlayer(
              false,
              context: context,
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
                      ),
                    ),
                  );
                } else {
                  playlist.add(
                    AudioSource.uri(
                      Uri.parse(chap.id.toString()),
                      tag: MediaItem(
                        id: chap.id.toString(),
                        title: chap.name ?? '',
                        album: widget.reciters[ind].reciterName,
                      ),
                    ),
                  );
                }
              }
              audioManager.setPlaylist(
                playlist,
                widget.chapters,
                widget.reciters,
                widget.playerType,
                index: 0,
              );
              audioPlayer.setLoopMode(LoopMode.off);
              audioManager.showHideFloatingPlayer(
                false,
                context: context,
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
              audioPlayer.play();
              audioManager.showHideFloatingPlayer(
                false,
                context: context,
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
                  false,
                  context: context,
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
                ),
              ),
            );
          } else {
            playlist.add(
              AudioSource.uri(
                Uri.parse(chap.id.toString()),
                tag: MediaItem(
                  id: chap.id.toString(),
                  title: chap.name ?? '',
                  album: widget.reciters[ind].reciterName,
                ),
              ),
            );
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
                  album: reciter.reciterName,
                ),
              ),
            );
          }
        }
      }

      ///Multiple Items
      audioManager.setPlaylist(
        playlist,
        widget.chapters,
        widget.reciters,
        widget.playerType,
        index: 0,
      );

      audioPlayer.setLoopMode(LoopMode.off);
      Future.delayed(const Duration(milliseconds: 100));
      audioManager.subscribeToStreams();
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
    // if (!audioManager.isFloating) {
    //   audioManager.disposePlayer(notify: false);
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    audioManager = context.watch<AudioPlayerProvider>();
    final audioPlayer = audioManager.audioPlayer;
    Color whiteColor = Colors.white;
    final reciterController = context.watch<RecitorsProvider>();
    final isSpanish =
        context.tr.localeName == 'es' ||
        context.tr.localeName == 'tr' ||
        context.tr.localeName == 'de' ||
        context.tr.localeName == 'ru';
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff490094), Color(0xff6E4BA1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircularButton(
                      icon: Icons.keyboard_arrow_down,
                      iconColor: whiteColor,
                      size: iconSize,
                      borderColor: whiteColor.withOpacity(0.2),
                      onTap: () {
                        audioManager.showHideFloatingPlayer(
                          true,
                          context: context,
                        );
                        Navigator.pop(context);
                      },
                    ),

                    ///Close Player Screen Button
                    // CircularButton(
                    //   icon: Icons.keyboard_arrow_left,
                    //   iconColor: whiteColor,
                    //   size: iconSize,
                    //   onTap: () {
                    //     final playerScreensManager = context.read<PlayerScreensController>();
                    //     playerScreensManager.popScreen(playerScreensManager.reciter == null? 0 : 2);
                    //     audioManager.disposePlayer(notify: false);
                    //     Navigator.pop(context);
                    //   },
                    // ),
                    if (audioManager.nextChapter != null)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff6E4BA1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            SvgImageAsset(
                              'assets/icons/star.svg',
                              height: 15,
                              color: whiteColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Next: ${audioManager.nextChapter?.name ?? ''}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: whiteColor,
                                height: context.isRtl || isSpanish ? 0.8 : null,
                                fontFamily: 'Mulish',
                              ),
                            ),
                          ],
                        ),
                      ),
                    Visibility(
                      visible: false,
                      maintainState: true,
                      maintainAnimation: true,
                      maintainSize: true,
                      child: CircularButton(
                        icon: Icons.search,
                        iconColor: whiteColor,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                alignment: Alignment.center,
                child:
                    audioManager.reciters.isNotEmpty
                        ? ClipOval(
                          child: reciterController.getImage(
                            'assets/reciters/reciter_${audioManager.currentReciterDetail?.mainReciterId ?? ''}.jpg',
                            height: 55.w,
                            width: 55.w,
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                audioManager.playingChapter?.name ?? '',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: whiteColor,
                                  fontFamily: 'SpaceGrotesk',
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                audioManager.reciters.isNotEmpty
                                    ? audioManager
                                            .currentReciterDetail
                                            ?.reciterName ??
                                        ''
                                    : '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: whiteColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // CircularButton(
                        //   icon: CupertinoIcons.arrow_down_to_line,
                        //   size: iconSize,
                        //   iconColor: whiteColor,
                        //   onTap: () async {
                        //   },
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Slider(
                    min: 0,
                    max: audioManager.duration.inSeconds.toDouble(),
                    value:
                        _lastSliderValue ??
                        (audioManager.position.inSeconds.toDouble() <
                                audioManager.duration.inSeconds.toDouble()
                            ? audioManager.position.inSeconds.toDouble()
                            : audioManager.duration.inSeconds.toDouble()),
                    activeColor: whiteColor,
                    inactiveColor: whiteColor,
                    onChanged: (value) async {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
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
                                        fontSize: 12,
                                        color: whiteColor,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text(
                                      formatTime(
                                        audioManager.duration -
                                            audioManager.position,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: whiteColor,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Shuffle playlist order (true|false)
                            IconButton(
                              splashRadius: iconSplashSize,
                              icon: SvgImageAsset(
                                'assets/icons/shuffle.svg',
                                color: whiteColor,
                                width: audioPlayer.shuffleModeEnabled ? 30 : 20,
                              ),
                              onPressed: () {
                                audioPlayer.setShuffleModeEnabled(
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
                                icon: Icon(
                                  context.isRtl
                                      ? Icons.skip_next_rounded
                                      : Icons.skip_previous_rounded,
                                  color: whiteColor,
                                  size: 34,
                                ),
                                onPressed: () {
                                  audioPlayer.seekToPrevious();
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
                              iconColor: whiteColor,
                              size: 60,
                              iconSize: 34,
                              borderColor: whiteColor.withOpacity(0.2),
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
                                icon: Icon(
                                  context.isRtl
                                      ? Icons.skip_previous_rounded
                                      : Icons.skip_next_rounded,
                                  color: whiteColor,
                                  size: 34,
                                ),
                                onPressed: () {
                                  audioPlayer.seekToNext();
                                },
                              ),
                            ),

                            /// Set playlist to loop (off|all|one)
                            IconButton(
                              splashRadius: iconSplashSize,
                              icon: SvgImageAsset(
                                'assets/icons/loop.svg',
                                color: whiteColor,
                                width:
                                    audioPlayer.loopMode == LoopMode.one
                                        ? 30
                                        : 20,
                              ),
                              onPressed: () {
                                audioPlayer.setLoopMode(
                                  audioPlayer.loopMode == LoopMode.one
                                      ? LoopMode.off
                                      : LoopMode.one,
                                );
                              },
                            ),
                          ],
                        ),
                        // const SizedBox(
                        //   height: 50,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

class FloatingQuranPlayer extends StatelessWidget {
  const FloatingQuranPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioPlayerProvider>();
    final audioPlayer = audioManager.audioPlayer;
    final isRTL =
        context.tr.localeName == 'ar' || context.tr.localeName == 'ur';
    final isSpanish =
        context.tr.localeName == 'es' ||
        context.tr.localeName == 'tr' ||
        context.tr.localeName == 'de' ||
        context.tr.localeName == 'ru';
    final reciterController = context.watch<RecitorsProvider>();
    Color whiteColor = Colors.white;
    const appColor = Color(0xff4E2B81);
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        IgnorePointer(child: Container(color: Colors.transparent)),
        audioManager.isFloating
            ? DraggableArea(
              child: Container(
                height: 55,
                width: MediaQuery.of(context).size.width - 40,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: appColor,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      const SizedBox(width: 15),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            context
                                .read<PlayerScreensController>()
                                .navigateToPlayerScreen(
                                  context,
                                  audioManager.reciters,
                                  audioManager.playingChapter!,
                                  audioManager.chapters,
                                  audioManager.playerType!,
                                  reciterFromAllSaved:
                                      audioManager.currentReciterDetail,
                                );
                          },
                          child: Row(
                            children: [
                              Container(
                                height: kAvatarSize,
                                width: kAvatarSize,
                                decoration: BoxDecoration(
                                  border: Border.all(color: whiteColor),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: reciterController.getImage(
                                    'assets/reciters/reciter_${audioManager.currentReciterDetail?.mainReciterId}.jpg',
                                    height: 55.w,
                                    width: 55.w,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: SizedBox(
                                  height: isRTL || isSpanish ? 23 : null,
                                  child: Text(
                                    audioManager
                                            .getCurrentPlayingSurah(
                                              context: context,
                                            )
                                            ?.name ??
                                        '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: whiteColor,
                                      overflow: TextOverflow.ellipsis,
                                      // height: isRTL || isSpanish ? 0.8 : null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// Skip to the next item
                      Visibility(
                        visible: audioManager.playingChapterIndex != 0,
                        maintainState: true,
                        maintainAnimation: true,
                        maintainSize: true,
                        child: IconButton(
                          splashRadius: kSplashRadius,
                          icon: Icon(
                            context.isRtl
                                ? Icons.skip_next_rounded
                                : Icons.skip_previous_rounded,
                            color: whiteColor,
                          ),
                          onPressed: () {
                            audioPlayer.seekToPrevious();
                          },
                        ),
                      ),

                      ///Play/Pause/RePlay
                      IconButton(
                        splashRadius: kSplashRadius,
                        icon: Icon(
                          audioPlayer.processingState ==
                                  ProcessingState.completed
                              ? Icons.replay_rounded
                              : audioManager.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: whiteColor,
                        ),
                        onPressed: () async {
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
                          splashRadius: kSplashRadius,
                          icon: Icon(
                            context.isRtl
                                ? Icons.skip_previous_rounded
                                : Icons.skip_next_rounded,
                            color: whiteColor,
                          ),
                          onPressed: () {
                            audioPlayer.seekToNext();
                          },
                        ),
                      ),
                      IconButton(
                        splashRadius: kSplashRadius,
                        icon: Icon(Icons.clear, color: whiteColor, size: 22),
                        onPressed: () {
                          audioManager.disposePlayer();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
            : const SizedBox(),
      ],
    );
  }
}

class DraggableArea extends StatefulWidget {
  final Widget child;

  const DraggableArea({super.key, required this.child});

  @override
  DragAreaStateStateful createState() => DragAreaStateStateful();
}

class DragAreaStateStateful extends State<DraggableArea> {
  Offset position = const Offset(100, 100);
  double prevScale = 1;
  double scale = 1;
  bool initialPosition = true;

  void updateScale(double zoom) => setState(() => scale = prevScale * zoom);

  void commitScale() => setState(() => prevScale = scale);

  void updatePosition(Offset newPosition) => setState(() {
    double deviceHeight = MediaQuery.of(context).size.height - 150;
    double dy =
        newPosition.dy < 50
            ? 50
            : newPosition.dy > deviceHeight
            ? deviceHeight
            : newPosition.dy;
    position = Offset(0, dy);
    initialPosition = false;
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) => updateScale(details.scale),
      onScaleEnd: (_) => commitScale(),
      child: Stack(
        children: [
          Positioned(
            left: initialPosition ? null : position.dx,
            top: initialPosition ? null : position.dy,
            bottom: initialPosition ? position.dy : null,
            child: Draggable(
              maxSimultaneousDrags: 1,
              feedback: widget.child,
              childWhenDragging: Opacity(opacity: .3, child: widget.child),
              onDragEnd: (details) => updatePosition(details.offset),
              child: Transform.scale(scale: scale, child: widget.child),
            ),
          ),
        ],
      ),
    );
  }
}
