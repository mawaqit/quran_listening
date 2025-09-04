import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/listening_search_textfield.dart';
import '../components/listening_toggle_tabs_widget.dart';
import '../providers/reciters_controller.dart';
import '../providers/download_controller.dart';
import 'tabs/all_recitators_tab.dart';
import 'tabs/downloaded_tab.dart';
import 'tabs/liked_tab.dart';

class QuranListeningPageWidget extends StatefulWidget {
  const QuranListeningPageWidget({super.key});

  @override
  State<QuranListeningPageWidget> createState() =>
      _QuranListeningPageWidgetState();
}

class _QuranListeningPageWidgetState extends State<QuranListeningPageWidget> {
  var selectedTab = ListeningTab.allRecitator;

  TextEditingController textEditingControllerOne = TextEditingController();
  TextEditingController textEditingControllerTwo = TextEditingController();
  TextEditingController textEditingControllerThree = TextEditingController();

  late DownloadController downloadController;
  late RecitorsProvider recitorsProvider;

  String inputOne = '';
  String inputTwo = '';
  String inputThree = '';

  @override
  void initState() {
    super.initState();
    downloadController = context.read<DownloadController>();
    recitorsProvider = context.read<RecitorsProvider>();
  }

  @override
  Widget build(BuildContext context) {
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
            hint: 'Search for recitator',
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
            hint: 'Search for favorite recitator',
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
            hint: 'Search for surah',
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
  }
}
