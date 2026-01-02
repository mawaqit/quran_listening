import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:mawaqit_quran_listening/src/extensions/device_extensions.dart';
import 'package:provider/provider.dart';

import '../../../mawaqit_quran_listening.dart';
import '../listening_components/listening_search_textfield.dart';
import '../listening_components/listening_toggle_tabs_widget.dart';

enum ListeningTab { liked, allRecitator, downloaded }

class QuranListeningPage extends StatefulWidget {
  const QuranListeningPage({super.key});

  @override
  State<QuranListeningPage> createState() => _QuranListeningPageState();
}

class _QuranListeningPageState extends State<QuranListeningPage> {
  var selectedTab = ListeningTab.allRecitator;

  TextEditingController textEditingControllerOne = TextEditingController();
  TextEditingController textEditingControllerTwo = TextEditingController();
  TextEditingController textEditingControllerThree = TextEditingController();

  late DownloadController downloadController;
  late ListeningToggleIndexProvider listeningToggleIndexProvider;

  String inputOne = '';
  String inputTwo = '';
  String inputThree = '';

  @override
  void initState() {
    super.initState();
    downloadController = context.read<DownloadController>();
    listeningToggleIndexProvider = context.read<ListeningToggleIndexProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListeningToggleIndexProvider>(
      builder: (context, provider, child) {
        if (provider.selectedIndex == 0) {
          selectedTab = ListeningTab.liked;
        } else if (provider.selectedIndex == 1) {
          selectedTab = ListeningTab.allRecitator;
        } else {
          selectedTab = ListeningTab.downloaded;
        }
        return Column(
          children: [
            ListeningToggleTabsWidget(
              onTabChanged:
                  (tab) => setState(() {
                    selectedTab = tab;
                    textEditingControllerOne.clear();
                    textEditingControllerTwo.clear();
                    textEditingControllerThree.clear();
                  }),
            ),
            const SizedBox(height: 16),
            Expanded(child: handleView()),

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
                      audioManager.reciters,
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
                          onPressed: () {
                            audioManager.disposePlayer();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget handleView() {
    if (context.isFoldable) {
      return Column(
        children: [
          if (ListeningTab.allRecitator == selectedTab)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        allReciterSearchField(),
                        SizedBox(height: 16,),
                        AllRecitatorsTab(),
                      ],
                    ),
                  ),
                  SizedBox(width: 16,),
                  Expanded(child: SurahPage(key: const Key("foldable_all_reciters"))),
                ],
              ),
            ),
          if (ListeningTab.liked == selectedTab)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        likedSearchField(),
                        SizedBox(height: 16,),
                        LikedTab(),
                      ],
                    ),
                  ),
                  SizedBox(width: 16,),
                  Expanded(child: Visibility(
                    visible: context.watch<FavoriteReciter>().favoriteReciterUuids.isNotEmpty,
                    child: SurahPage(key: const Key("foldable_liked_tab")),
                  )),
                ],
              ),
            ),
          if (ListeningTab.downloaded == selectedTab)
            Expanded(
              child: Column(
                children: [
                  downloadSearchField(),
                  SizedBox(height: 16,),
                  DownloadedTab(),
                ],
              ),
            ),
        ],
      );
    }

    return Column(
      children: [
        if (selectedTab == ListeningTab.allRecitator) allReciterSearchField(),
        if (selectedTab == ListeningTab.liked) likedSearchField(),
        if (selectedTab == ListeningTab.downloaded) downloadSearchField(),
        if (selectedTab != ListeningTab.downloaded) const SizedBox(height: 16),
        selectedTab == ListeningTab.allRecitator
            ? const AllRecitatorsTab()
            : selectedTab == ListeningTab.downloaded
            ? const DownloadedTab()
            : const LikedTab(),
      ],
    );
  }

  Widget allReciterSearchField() {
    return ListeningSearchTextField(
      hasSuffix: inputOne.isNotEmpty,
      hint: context.tr.search_for_recitator,
      controller: textEditingControllerOne,
      onSubmittedPressed: (value) {},
      onChanged: (value) {
        if (value.length > 3) {
          setState(() {
            inputOne = value;
          });
          context.read<RecitorsProvider>().searchReciters(value);
        }
        if (value.isEmpty) {
          context.read<RecitorsProvider>().resetReciters();
        }
      },
      onSuffixPressed: () {
        textEditingControllerOne.clear();
        setState(() {
          inputOne = '';
        });
        context.read<RecitorsProvider>().resetReciters();
      },
    );
  }

  Widget likedSearchField() {
    return ListeningSearchTextField(
      hasSuffix: inputTwo.isNotEmpty,
      hint: context.tr.search_for_fav_recitator,
      controller: textEditingControllerTwo,
      onSubmittedPressed: (value) {},
      onChanged: (value) {
        if (value.length > 3) {
          setState(() {
            inputTwo = value;
          });
          context.read<RecitorsProvider>().searchFavoriteReciters(value);
        }

        if (value.isEmpty) {
          context.read<RecitorsProvider>().resetFavoriteReciters();
        }
      },
      onSuffixPressed: () {
        textEditingControllerTwo.clear();
        setState(() {
          inputTwo = '';
        });
        context.read<RecitorsProvider>().resetFavoriteReciters();
      },
    );
  }

  Widget downloadSearchField() {
    return ListeningSearchTextField(
      hasSuffix: inputThree.isNotEmpty,
      hint: context.tr.search_for_surah,
      controller: textEditingControllerThree,
      onSubmittedPressed: (value) {},
      onChanged: (value) {
        setState(() {
          inputThree = value;
        });
        context.read<DownloadController>().searchDownloadedSurah(value);
      },
      onSuffixPressed: () {
        textEditingControllerThree.clear();
        setState(() {
          inputThree = '';
        });
        context.read<DownloadController>().resetDownloadedSurahs();
      },
    );
  }
}
