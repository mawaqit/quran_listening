import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../mawaqit_quran_listening.dart';
import '../components/error_widget.dart';
import '../listening_components/surah_list_tile_v3.dart';

class SurahPage extends StatefulWidget {
  const SurahPage({super.key});

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  late RecitorsProvider recitersManager;
  late AudioPlayerProvider audioPlayerProvider;
  late final DownloadController downloadController;
  final searchTextFieldFocusNode = FocusNode();
  List<SurahModel> surahs = [];
  List<SurahModel> likedSurahs = [];
  List<int> likedSurahsIds = [];
  TextEditingController searchController = TextEditingController();
  bool inTextSearch = false;
  bool isDownloaded = false;

  @override
  void initState() {
    super.initState();
    recitersManager = context.read<RecitorsProvider>();
    audioPlayerProvider = context.read<AudioPlayerProvider>();
    downloadController = context.read<DownloadController>();

    // Use WidgetsBinding to ensure this runs after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await downloadController.fetchDownloadedRecitation(reciterId: audioPlayerProvider.currentReciterId.toString());

      // Initialize surahs and load recitations for current reciter
      final recitationsManager = context.read<RecitationsManager>();
      if (recitationsManager.surahs.isEmpty) {
        await recitationsManager.initializeSurahs();
      }
      
      // Ensure we have a valid currentReciterId before loading recitations
      if (audioPlayerProvider.currentReciterId != null) {
        debugPrint('Loading recitations for reciter ID: ${audioPlayerProvider.currentReciterId}');
        await recitationsManager.getRecitations(reciterId: audioPlayerProvider.currentReciterId!);
      } else {
        debugPrint('Warning: currentReciterId is null - cannot load recitations');
        // Try to get the first available reciter if none is selected
        final recitorsProvider = context.read<RecitorsProvider>();
        if (recitorsProvider.reciters.isNotEmpty) {
          final firstReciter = recitorsProvider.reciters.first;
          audioPlayerProvider.changeReciter(firstReciter);
          await recitationsManager.getRecitations(reciterId: firstReciter.id);
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<FavoriteSurah>(context).fetchFavoriteSurahs(audioPlayerProvider.currentReciterId.toString()).then((listFavoriteSurahs) => likedSurahsIds = listFavoriteSurahs);

    // Listen to reciter changes and initialize surahs
    audioPlayerProvider.addListener(_onReciterChanged);
  }

  void _onReciterChanged() {
    if (mounted) {
      // Initialize surahs and load recitations when reciter changes
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final recitationsManager = context.read<RecitationsManager>();
        if (recitationsManager.surahs.isEmpty) {
          await recitationsManager.initializeSurahs();
        }
        // Load recitations for the current reciter
        if (audioPlayerProvider.currentReciterId != null) {
          await recitationsManager.getRecitations(reciterId: audioPlayerProvider.currentReciterId!);
        } else {
          debugPrint('Warning: currentReciterId is null after reciter change');
        }
      });
    }
  }

  @override
  void dispose() {
    audioPlayerProvider.removeListener(_onReciterChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recitationsManager = Provider.of<RecitationsManager>(context);
    Provider.of<RecitorsProvider>(context);
    context.watch<DownloadController>(); // Watch for download changes

    surahs.clear();
    likedSurahs.clear();
    if (context.watch<RecitationsManager>().surahs.isNotEmpty) {
      context.watch<RecitationsManager>().surahs.forEach((chapter) {
        if (likedSurahsIds.contains(chapter.id)) {
          likedSurahs.add(chapter);
        } else {
          final Reciter? reciter = audioPlayerProvider.getCurrentReciterV3(context: context);
          if (reciter != null && reciter.surahsList != null && reciter.surahsList!.contains(chapter.id.toString())) {
            surahs.add(chapter);
          }
        }
      });
    }
    bool isErrorView = recitationsManager.state == RecitationsScreenState.failed;
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        context.read<NavigationControllerV3>().popPage(0);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child:
                recitationsManager.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isErrorView
                    ? ApiErrorWidget(callback: () => recitationsManager.getRecitations(reciterId: audioPlayerProvider.currentReciterId ?? 1, retry: true))
                    : ListView.builder(
                      key: const Key('surah_page_listview'),
                      padding: const EdgeInsets.only(bottom: 30),
                      itemCount: surahs.length,
                      itemBuilder: (context, index) {
                        return SurahListTileV3(
                          chapter: surahs[index],
                          chapters: context.read<RecitationsManager>().surahs,
                          reciter: audioPlayerProvider.getCurrentReciterV3(context: context),
                          playerType: PlayerType.reciterUnLikedSurahs,
                          index: index,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
