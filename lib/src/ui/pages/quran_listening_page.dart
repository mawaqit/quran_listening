import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
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
            if (selectedTab == ListeningTab.allRecitator)
              ListeningSearchTextField(
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
              ),
            if (selectedTab == ListeningTab.liked)
              ListeningSearchTextField(
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
              ),
            if (selectedTab == ListeningTab.downloaded)
              ListeningSearchTextField(
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
              ),
            if (selectedTab != ListeningTab.downloaded) const SizedBox(height: 16),
            selectedTab == ListeningTab.allRecitator
                ? const AllRecitatorsTab()
                : selectedTab == ListeningTab.downloaded
                ? const DownloadedTab()
                : const LikedTab(),
          ],
        );
      },
    );
  }
}
