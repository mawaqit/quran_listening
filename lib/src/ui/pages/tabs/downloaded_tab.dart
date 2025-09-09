import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../mawaqit_quran_listening.dart';
import '../../components/mawaqit_dialog.dart';
import '../../listening_components/downloaded_surah_tile.dart';
import 'package:collection/collection.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:sizer/sizer.dart';

class DownloadedTab extends StatefulWidget {
  const DownloadedTab({super.key});

  @override
  State<DownloadedTab> createState() => _DownloadedTabState();
}

class _DownloadedTabState extends State<DownloadedTab> {
  late DownloadController downloadController;
  late RecitorsProvider recitorsProvider;
  late RecitationsManager recitationsManager;

  void populateDownloadedSurahsLists() {
    downloadController.originalRecitersForDownloadedRecitations.clear();
    downloadController.recitersForDownloadedRecitations.clear();
    downloadController.downloadedRecitations.clear();
    downloadController.originalDownloadedRecitations.clear();
    if (recitorsProvider.reciters.isNotEmpty && recitorsProvider.surahList.isNotEmpty) {
      for (var savedSurah in downloadController.downloadedSurahs) {
        final reciter = recitorsProvider.reciters.firstWhereOrNull(
          (reciter) => reciter.id.toString() == savedSurah[kReciterId],
        );
        final chapter = recitationsManager.surahs.firstWhereOrNull(
          (chap) => chap.id.toString() == savedSurah[kChapterId],
        );
        if (reciter != null && chapter != null) {
          downloadController.originalRecitersForDownloadedRecitations.add(reciter);
          downloadController.recitersForDownloadedRecitations.add(reciter);
          downloadController.downloadedRecitations.add(chapter);
          downloadController.originalDownloadedRecitations.add(chapter);
        }
      }

      int reciterLastIndex = 0;
      List<Reciter> reciterCopyList = [];
      List<SurahModel> chapterCopyList = [];
      List<SurahModel> sortedChapList = [];

      reciterCopyList = List.from(downloadController.recitersForDownloadedRecitations);
      chapterCopyList = List.from(downloadController.downloadedRecitations);

      for (int i = 0; i < reciterCopyList.length;) {
        Reciter element = reciterCopyList[i];
        reciterLastIndex = reciterCopyList.lastIndexOf(element);
        List<SurahModel> tempChapList = [];
        for (int i = 0; i <= reciterLastIndex; i++) {
          tempChapList.add(chapterCopyList[i]);
        }
        tempChapList.sort();
        sortedChapList.addAll(tempChapList);
        reciterCopyList.removeRange(0, reciterLastIndex + 1);
        chapterCopyList.removeRange(0, reciterLastIndex + 1);
      }
      downloadController.downloadedRecitations.clear();
      downloadController.originalDownloadedRecitations.clear();
      downloadController.downloadedRecitations.addAll(sortedChapList);
      downloadController.originalDownloadedRecitations.addAll(sortedChapList);
      downloadController.setCombinedList();
    }
  }

  @override
  void initState() {
    super.initState();
    downloadController = context.read<DownloadController>();
    recitorsProvider = context.read<RecitorsProvider>();
    recitationsManager = context.read<RecitationsManager>();

    // Use WidgetsBinding to ensure this runs after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Store context and provider references before async operations
      final currentContext = context;
      final recitorsProviderRef = currentContext.read<RecitorsProvider>();
      final localeName = currentContext.tr.localeName;

      // Load downloaded recitations first
      await downloadController.loadDownloadedRecitations();
      // Initialize surahs
      await recitationsManager.initializeSurahs();
      // Then get reciters
      await recitorsProviderRef.getReciters(currentContext, language: localeName);
      // Finally populate the lists
      populateDownloadedSurahsLists();
    });

    // Listen to changes in reciters and surahs to repopulate the list
    recitorsProvider.addListener(_onDataChanged);
    recitationsManager.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted && recitorsProvider.reciters.isNotEmpty && recitationsManager.surahs.isNotEmpty) {
      populateDownloadedSurahsLists();
    }
  }

  @override
  void dispose() {
    recitorsProvider.removeListener(_onDataChanged);
    recitationsManager.removeListener(_onDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DownloadController>();
    recitorsProvider = context.watch<RecitorsProvider>();
    final isRTL = context.isArabicLanguage;
    // Show skeleton loading while data is being loaded
    if (downloadController.isLoading) {
      return Expanded(
        child: Skeletonizer(
          enabled: true,
          child: ListView.builder(
            itemCount: 5, // Show 5 skeleton items
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.only(left: isRTL ? 0 : 19, top: 15, bottom: 15, right: isRTL ? 19 : 0),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ibrahim Al-Akdar",
                            maxLines: 2,
                            style: TextStyle(fontSize: 13.sp, color: context.colorScheme.surfaceContainerHighest),
                          ),
                          const SizedBox(height: 2),
                          DefaultTextStyle(
                            style: TextStyle(
                              color: context.colorScheme.secondary.withOpacity(.70),
                              fontSize: 10.sp,
                              fontFamily: context.getFontFamily(),
                            ),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Rewayat Hafs A\'n Aseem- Murattal',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: isRTL ? 3 : 7.0, left: isRTL ? 7.0 : 3.0),
                      child: IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        icon: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.close, color: context.colorScheme.primaryFixed),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    if (downloadController.surahRecitorList.isEmpty && downloadController.originalSurahRecitorList.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            context.tr.no_surah_found,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: Theme.of(context).primaryColor),
          ),
        ),
      );
    }

    return downloadController.surahRecitorList.isEmpty
        ? Expanded(
          child: Center(child: Text(context.tr.not_downloaded_recitation, maxLines: 2, textAlign: TextAlign.center)),
        )
        : Expanded(
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // TODO
                  TextButton(
                    onPressed: () {
                      showDialog(
                        barrierColor: Colors.black.withOpacity(.3),
                        context: context,
                        builder:
                            (context) => MawaqitDialog(
                              title: context.tr.delete_all_downloads,
                              content: context.tr.delete_recitations_message,
                              okText: context.tr.cancel,
                              onOkPressed: () async {
                                Navigator.pop(context);
                              },
                              cancelText: context.tr.continue_to_app,
                              onCancelPressed: () async {
                                Navigator.pop(context);
                                downloadController.deleteAllDownloadedRecitations(context);
                              },
                            ),
                      );
                    },
                    child: Text(context.tr.delete_all),
                  ),
                ],
              ),
              ListView.builder(
                key: const Key('downloaded_tab_listview'),
                itemCount: downloadController.surahRecitorList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return DownloadedSurahTileV3(
                    index: index,
                    key: Key('downloaded_tile_key_$index'),
                    reciter: downloadController.surahRecitorList[index].recitor,
                    chapter: downloadController.surahRecitorList[index].surah,
                    playerType: PlayerType.allSavedSurahs,
                    onDelete: () {
                      downloadController.removeItemFromList(downloadController.surahRecitorList[index].id);
                      // populateDownloadedSurahsLists();
                    },
                  );
                },
              ),
            ],
          ),
        );
  }
}
