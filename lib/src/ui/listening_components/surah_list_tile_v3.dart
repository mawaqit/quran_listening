import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:mawaqit_quran_listening/src/extensions/device_extensions.dart';
import 'package:mawaqit_quran_listening/src/utils/helpers/mawaqit_icon_v3_cions.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../extensions/theme_extension.dart';
import '../../models/reciter.dart';
import '../../models/surah_model.dart';
import '../../providers/audio_provider.dart';
import '../../providers/download_controller.dart';
import '../../providers/play_pause_id_provider.dart';
import '../../providers/player_screens_controller.dart';

class SurahListTileV3 extends StatefulWidget {
  final SurahModel chapter;
  final Reciter reciter;
  final List<int> favSurahsList;
  final List<SurahModel> chapters;
  final PlayerType playerType;
  final int index;

  const SurahListTileV3({
    required this.chapter,
    required this.reciter,
    required this.chapters,
    required this.playerType,
    required this.index,
    this.favSurahsList = const [],
    super.key,
  });

  @override
  State<SurahListTileV3> createState() => _SurahListTileV3State();
}

class _SurahListTileV3State extends State<SurahListTileV3> {
  late DownloadController downloadController;
  late AudioPlayerProvider audioManager;

  @override
  Widget build(BuildContext context) {
    audioManager = context.watch<AudioPlayerProvider>();
    downloadController = context.watch<DownloadController>();

    bool isDownloaded =
        downloadController.singleSavedRecitation(
          reciterId: widget.reciter.id,
          recitationId: widget.chapter.id,
        ) !=
        null;
    bool isDownloading =
        downloadController.inProgressSurahs[widget.reciter.id.toString()]
            ?.containsKey(widget.chapter.id.toString()) ??
        false;
    double progress =
        downloadController.inProgressSurahs[widget.reciter.id
            .toString()]?[widget.chapter.id.toString()] ??
        0.0;
    const greyColor = Colors.grey;

    bool isPlaying =
        audioManager.isPlaying && (widget.index == audioManager.playingChapterIndex) &&
            widget.reciter.id == audioManager.playingRecitor?.id;


    return GestureDetector(
      key: Key('surah_tile_key_${widget.index}'),
      onTap: () {
        context.closeKeyboard();
        // bool connected = await WearConnector.isWatchConnected();
        FocusManager.instance.primaryFocus?.unfocus();
        List<SurahModel> selectedChapters = [];
        List<Reciter> selectedReciters = [];
        // For Liked/All Recitators tabs: pass ALL 114 surahs from selected reciter
        selectedChapters.addAll(widget.chapters);
        selectedReciters.addAll([widget.reciter]);

        /// ------------------------------------ open v3 bottom sheet for player ------------------------------------
        context.read<AudioPlayerProvider>().disposePlayer();
        context.read<AudioPlayerProvider>().setPlayingRecitor(widget.reciter);
        context.read<PlayerScreensController>().navigateToPlayerScreenV3(
          context,
          selectedReciters,
          widget.chapter,
          selectedChapters,
          widget.playerType,
        );
        FocusScope.of(context).unfocus();
      },
      child: Container(
        padding: const EdgeInsets.only(left: 5, top: 15, bottom: 15, right: 5),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              key: Key('play_button_key_${widget.index}'),
              onPressed: () {
                context.read<AudioPlayerProvider>().disposePlayer();
                if (!isPlaying) {
                  List<SurahModel> selectedChapters = [];
                  List<Reciter> selectedReciters = [];
                  // For Liked/All Recitators tabs: pass ALL 114 surahs from selected reciter
                  selectedChapters.addAll(widget.chapters);
                  selectedReciters.addAll([widget.reciter]);

                  /// ------------------------------------ open v3 bottom sheet for player ------------------------------------
                  context.read<AudioPlayerProvider>().setPlayingRecitor(
                    widget.reciter,
                  );
                  context
                      .read<PlayerScreensController>()
                      .navigateToPlayerScreenV3(
                    context,
                    selectedReciters,
                    widget.chapter,
                    selectedChapters,
                    widget.playerType,
                  );
                  FocusScope.of(context).unfocus();
                } else {
                  final audioManager = context.read<AudioPlayerProvider>();
                  final audioPlayer = audioManager.audioPlayer;
                  audioPlayer.pause();
                }
              },
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                color: context.colorScheme.primaryFixed,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.chapter.id} - ${widget.chapter.name}'.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: (context.isFoldable ? 8 : 13).sp,
                      color: context.colorScheme.onPrimaryContainer.withOpacity(.9),
                    ),
                  ),
                  Text(
                    widget.reciter.reciterName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: greyColor, fontSize: (context.isFoldable ? 6 : 10).sp),
                  ),
                ],
              ),
            ),
            isDownloading
                ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await downloadController.cancelDownload(
                      reciterId: widget.reciter.id.toString(),
                      chapterId: widget.chapter.id.toString(),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: null,
                        icon: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 2,
                            backgroundColor: greyColor,
                          ),
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: null,
                        icon: SizedBox(
                          child: Icon(
                            size: 14,
                            ReciterIconV3.close,
                            color: context.colorScheme.primaryFixed,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon:
                      isDownloaded
                          ? Icon(
                            key: Key(
                              'downloaded_completed_key_${widget.index}',
                            ),
                            ReciterIconV3.close,
                            color: context.colorScheme.primaryFixed,
                          )
                          : Icon(
                            key: Key('download_button_key_${widget.index}'),
                            ReciterIconV3.download,
                            color: context.colorScheme.primaryFixed,
                            size: 22,
                          ),
                  onPressed: () async {
                    if (isDownloaded) {
                      final result = await downloadController
                          .removeDownloadedRecitationPath(
                            context: context,
                            reciterId: widget.reciter.id.toString(),
                            chapterId: widget.chapter.id.toString(),
                          );
                      await downloadController.fetchDownloadedRecitation(
                        reciterId: widget.reciter.id.toString(),
                      );

                      debugPrint('Deleted : $result');
                    } else if (downloadController.canDownload()) {
                      await downloadController.downloadRecite(
                        context: context,
                        url:
                            '${audioManager.reciter!.serverUrl!}${widget.chapter.id.toString().padLeft(3, '0')}.mp3',
                        reciterId: widget.reciter.id.toString(),
                        chapterId: widget.chapter.id.toString(),
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: context.tr.cant_download_more_than_3,
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    }
                  },
                ),
          ],
        ),
      ),
    );
  }
}
