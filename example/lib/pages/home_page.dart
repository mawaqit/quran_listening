import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';
import 'package:provider/provider.dart';

/// Home page that demonstrates different features of the package
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final playerScreensController = context.read<NavigationControllerV3>();
    final pageController = playerScreensController.pageController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Listening Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) {},
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const QuranListeningPage();
                    } else if (index == 1 && context.read<PlayerScreensController>().reciter != null) {
                      return const SurahPage();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              if (context.watch<AudioPlayerProvider>().isFloating)
                Builder(builder: (context) {
                  final audioManager = context.watch<AudioPlayerProvider>();
                  final audioPlayer = audioManager.audioPlayer;

                  final surah = audioManager.getCurrentPlayingSurah(context: context);
                  if (surah == null) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      context.read<PlayerScreensController>().navigateToPlayerScreenV3(
                        context,
                        audioManager.reciters ?? [],
                        audioManager.playingChapter!,
                        audioManager.chapters,
                        audioManager.playerType!,
                        reciterFromAllSaved: audioManager.currentReciterDetail,
                      );
                    },
                    child: Container(
                      key: const Key('bottom_sticky_player'),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: context.isDark ? context.colorScheme.primary : context.colorScheme.primary,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr.listen_to_quran,
                                    style:
                                    TextStyle(color: Colors.white, fontSize: 8),
                                  ),
                                  Text(
                                    '${surah.id}. ${surah.name}- ${audioManager.playingRecitor?.reciterName}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          ///Play/Pause/RePlay
                          IconButton(
                            splashRadius: 20,
                            icon: Icon(
                              audioPlayer.processingState == ProcessingState.completed
                                  ? Icons.replay_rounded
                                  : audioManager.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              if (audioPlayer.processingState == ProcessingState.completed) {
                                audioPlayer.seek(Duration.zero, index: 0);
                              } else if (audioManager.isPlaying) {
                                await audioPlayer.pause();
                              } else {
                                await audioPlayer.play();
                              }
                            },
                          ),
                          IconButton(
                            key: const Key('close_sticky_player'),
                            splashRadius: 20,
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: audioManager.disposePlayer,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

