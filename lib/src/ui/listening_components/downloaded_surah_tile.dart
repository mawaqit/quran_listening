import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sizer/sizer.dart';
import '../../../mawaqit_quran_listening.dart';
import 'package:provider/provider.dart';
import '../../providers/player_screens_controller.dart';

import '../../utils/helpers/mawaqit_icon_v3_cions.dart';

class DownloadedSurahTileV3 extends StatelessWidget {
  final SurahModel chapter;
  final Reciter? reciter;
  final PlayerType playerType;
  final VoidCallback onDelete;
  final int index;

  const DownloadedSurahTileV3({
    required this.chapter,
    required this.reciter,
    required this.playerType,
    required this.onDelete,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const greyColor = Colors.grey;
    final DownloadController downloadController =
        context.read<DownloadController>();
    final RecitationsManager recitationsManager =
        context.read<RecitationsManager>();
    final audioManager = Provider.of<AudioPlayerProvider>(context);

    return Consumer<DownloadController>(
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: () {
            context.closeKeyboard();
            FocusManager.instance.primaryFocus?.unfocus();
            context
                .read<DownloadedPagePlayPauseIndexProvider>()
                .setCurrentSurahIndex(index);

            List<SurahModel> chapters = [];
            List<Reciter> reciters = [];

            List<SurahModel> selectedChaptersByReciter = [];
            List<Reciter> selectedRecitersByReciter = [];

            List<SurahModel> selectedChaptersByChapter = [];
            List<Reciter> selectedRecitersChapter = [];

            if (playerType == PlayerType.allSavedSurahs) {
              chapters = downloadController.downloadedRecitations;
              reciters = downloadController.recitersForDownloadedRecitations;
              audioManager.setPlayingRecitor(reciter!);

              int subListBasesOnReciter = reciters.indexOf(reciter!);
              selectedChaptersByReciter.addAll(
                chapters.sublist(subListBasesOnReciter),
              );
              selectedRecitersByReciter.addAll(
                reciters.sublist(subListBasesOnReciter),
              );

              int subListBasesOnChapter = selectedChaptersByReciter.indexWhere(
                (element) => element.id == chapter.id,
              );
              selectedChaptersByChapter.addAll(
                selectedChaptersByReciter.sublist(subListBasesOnChapter),
              );
              selectedRecitersChapter.addAll(
                selectedRecitersByReciter.sublist(subListBasesOnChapter),
              );

              navigateToPlayer(
                context: context,
                reciters: selectedRecitersChapter,
                chapters: selectedChaptersByChapter,
                chapter: chapter,
                reciter: reciter,
                playerType: playerType,
              );
            } else {
              reciters = [reciter!];
              downloadController.downloadedSurahsForSpecificReciter.forEach((
                key,
                value,
              ) {
                chapters.add(
                  recitationsManager.surahs.firstWhere(
                    (element) => element.id.toString() == key,
                  ),
                );
              });

              int selectedIndex = chapters.indexWhere(
                (element) => element.id == chapter.id,
              );
              selectedChaptersByReciter.addAll(chapters.sublist(selectedIndex));
              selectedRecitersByReciter.addAll(reciters);
              audioManager.setPlayingRecitor(reciter!);
              navigateToPlayer(
                context: context,
                reciters: selectedRecitersByReciter,
                chapters: selectedChaptersByReciter,
                chapter: chapter,
                reciter: reciter,
                playerType: playerType,
              );
            }
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: const EdgeInsets.only(
              left: 5,
              top: 15,
              bottom: 15,
              right: 5,
            ),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) {
                    var audioManager = context.watch<AudioPlayerProvider>();
                    var playPauseIndexProvider =
                        context.watch<DownloadedPagePlayPauseIndexProvider>();
                    bool isPlaying =
                        audioManager.isPlaying &&
                        (index ==
                            playPauseIndexProvider.currentPlayingSurahIndex);
                    return IconButton(
                      onPressed: () {
                        if (!isPlaying) {
                          context.closeKeyboard();
                          FocusManager.instance.primaryFocus?.unfocus();
                          context
                              .read<DownloadedPagePlayPauseIndexProvider>()
                              .setCurrentSurahIndex(index);
                          List<SurahModel> chapters = [];
                          List<Reciter> reciters = [];

                          List<SurahModel> selectedChaptersByReciter = [];
                          List<Reciter> selectedRecitersByReciter = [];

                          List<SurahModel> selectedChaptersByChapter = [];
                          List<Reciter> selectedRecitersChapter = [];

                          if (playerType == PlayerType.allSavedSurahs) {
                            chapters = downloadController.downloadedRecitations;
                            reciters =
                                downloadController
                                    .recitersForDownloadedRecitations;
                            audioManager.setPlayingRecitor(reciter!);
                            int subListBasesOnReciter = reciters.indexOf(
                              reciter!,
                            );
                            selectedChaptersByReciter.addAll(
                              chapters.sublist(subListBasesOnReciter),
                            );
                            selectedRecitersByReciter.addAll(
                              reciters.sublist(subListBasesOnReciter),
                            );

                            int subListBasesOnChapter =
                                selectedChaptersByReciter.indexWhere(
                                  (element) => element.id == chapter.id,
                                );
                            selectedChaptersByChapter.addAll(
                              selectedChaptersByReciter.sublist(
                                subListBasesOnChapter,
                              ),
                            );
                            selectedRecitersChapter.addAll(
                              selectedRecitersByReciter.sublist(
                                subListBasesOnChapter,
                              ),
                            );

                            navigateToPlayer(
                              context: context,
                              reciters: selectedRecitersChapter,
                              chapters: selectedChaptersByChapter,
                              chapter: chapter,
                              reciter: reciter,
                              playerType: playerType,
                            );
                          } else {
                            reciters = [reciter!];
                            downloadController
                                .downloadedSurahsForSpecificReciter
                                .forEach((key, value) {
                                  chapters.add(
                                    recitationsManager.surahs.firstWhere(
                                      (element) => element.id.toString() == key,
                                    ),
                                  );
                                });

                            int selectedIndex = chapters.indexWhere(
                              (element) => element.id == chapter.id,
                            );
                            selectedChaptersByReciter.addAll(
                              chapters.sublist(selectedIndex),
                            );
                            selectedRecitersByReciter.addAll(reciters);
                            audioManager.setPlayingRecitor(reciter!);
                            navigateToPlayer(
                              context: context,
                              reciters: selectedRecitersByReciter,
                              chapters: selectedChaptersByReciter,
                              chapter: chapter,
                              reciter: reciter,
                              playerType: playerType,
                            );
                          }
                          FocusScope.of(context).unfocus();
                        } else {
                          final audioManager =
                              context.read<AudioPlayerProvider>();
                          final audioPlayer = audioManager.audioPlayer;
                          audioPlayer.pause();
                        }
                      },
                      icon: Icon(
                        isPlaying ? ReciterIconV3.pause : ReciterIconV3.play,
                        color: context.colorScheme.primaryFixed,
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${chapter.id} - ${chapter.name}'.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: context.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 2),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.closeKeyboard();
                          FocusManager.instance.primaryFocus?.unfocus();
                          context.read<AudioPlayerProvider>().reciters =
                              context.read<RecitorsProvider>().reciters;
                          context.read<AudioPlayerProvider>().changeReciter(
                            reciter!,
                          );
                          context.read<PlayerScreensController>().setRecitor(
                            reciter!,
                          );
                          context
                              .read<NavigationControllerV3>()
                              .navigateToPage();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reciter!.reciterName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: greyColor,
                                fontSize: 10.sp,
                                decoration: TextDecoration.underline,
                                decorationColor: greyColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: Key('delete_downloaded_surah_key_$index'),
                  icon: Icon(
                    Icons.close,
                    color: context.colorScheme.primaryFixed,
                  ),
                  onPressed: () async {
                    await ReciterHiveManager().removeDownloadedRecitationPath(
                      context: context,
                      reciterId: reciter!.id.toString(),
                      chapterId: chapter.id.toString(),
                    );
                    await downloadController.fetchDownloadedRecitation(
                      reciterId: reciter!.id.toString(),
                    );
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  navigateToPlayer({
    BuildContext? context,
    List<Reciter>? reciters,
    List<SurahModel>? chapters,
    SurahModel? chapter,
    Reciter? reciter,
    PlayerType? playerType,
  }) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (context != null &&
          context.mounted &&
          reciters != null &&
          chapters != null &&
          chapter != null &&
          reciter != null &&
          playerType != null) {
        final audioManager = context.read<AudioPlayerProvider>();
        final downloadController = context.read<DownloadController>();

        // Set up the playlist for downloaded surahs
        List<AudioSource> playlist = [];
        for (int ind = 0; ind < chapters.length; ind++) {
          final chap = chapters[ind];
          String? path = downloadController.singleSavedRecitation(
            reciterId: reciter.id.toString(),
            recitationId: chap.id,
          );
          if (path != null) {
            playlist.add(
              AudioSource.file(
                path,
                tag: MediaItem(
                  id: chap.id.toString(),
                  title: chap.name ?? '',
                  album: reciter.reciterName,
                ),
              ),
            );
          }
        }

        // Find the index of the current chapter
        int chapterIndex = chapters.indexWhere(
          (element) => element.id == chapter.id,
        );

        // Set up and start playback
        audioManager.setPlaylist(
          playlist,
          chapters,
          [reciter],
          playerType,
          index: chapterIndex,
        );
        // Subscribe to audio state changes to keep UI in sync
        audioManager.subscribeToStreams();

        // Show full player sheet first, then floating player after user closes it
        context.read<PlayerScreensController>().navigateToPlayerScreenV3(
          context,
          [reciter],
          chapter,
          chapters,
          playerType,
          reciterFromAllSaved: reciter,
        );
      }
    });
  }
}

class DownloadedSurahTile extends StatelessWidget {
  final SurahModel surah;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isPlaying;
  final int index;

  const DownloadedSurahTile({
    super.key,
    required this.surah,
    required this.index,
    this.onTap,
    this.onDelete,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('downloaded_surah_tile_key_${index}'),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 5, top: 15, bottom: 15, right: 5),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Play button
            IconButton(
              key: Key('play_button_key_${index}'),
              onPressed: onTap,
              icon: Icon(
                isPlaying ? ReciterIconV3.pause : ReciterIconV3.play,
                color: context.colorScheme.primaryFixed,
              ),
            ),
            // Surah info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${surah.id} - ${surah.name}'.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        ReciterIconV3.downloaded,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Downloaded',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (onDelete != null)
              IconButton(
                key: Key('delete_button_key_${index}'),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: Icon(Icons.delete, color: Colors.red, size: 22),
                onPressed: onDelete,
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
