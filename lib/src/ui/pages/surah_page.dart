import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:provider/provider.dart';

import '../../../mawaqit_quran_listening.dart';
import '../../extensions/device_extensions.dart';
import '../../utils/helpers/mawaqit_icon_v3_cions.dart';
import '../listening_components/listening_search_textfield.dart';
import '../listening_components/surah_list_tile_v3.dart';

class SurahPage extends StatefulWidget {
  const SurahPage({super.key, this.listPadding});
  final EdgeInsetsGeometry? listPadding;

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  late RecitorsProvider recitersManager;
  late AudioPlayerProvider audioPlayerProvider;
  late final DownloadController downloadController;
  final searchTextFieldFocusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  List<int> likedSurahsIds = [];
  bool _isInitialized = false;
  bool _listenerAttached = false;
  int? _lastLoadedReciterId;
  int? _lastFavoriteReciterId;
  int? _lastDownloadedReciterId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    recitersManager = context.read<RecitorsProvider>();
    audioPlayerProvider = context.read<AudioPlayerProvider>();
    downloadController = context.read<DownloadController>();

    // Use WidgetsBinding to ensure this runs after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _isInitialized) return;
      _isInitialized = true;
      await _initializePageState();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only attach listener once to prevent multiple calls
    if (!_listenerAttached) {
      _listenerAttached = true;
      audioPlayerProvider.addListener(_onReciterChanged);
    }
  }

  void _onReciterChanged() {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadCurrentReciterData();
    });
  }

  Future<void> _initializePageState() async {
    final recitationsManager = context.read<RecitationsManager>();
    final recitorsProvider = context.read<RecitorsProvider>();
    if (recitationsManager.surahs.isEmpty) {
      await recitationsManager.initializeSurahs();
    }

    if (audioPlayerProvider.currentReciterId == null) {
      if (recitorsProvider.reciters.isNotEmpty) {
        audioPlayerProvider.changeReciter(recitorsProvider.reciters.first);
      }
    }

    await _loadCurrentReciterData();
  }

  Future<void> _loadCurrentReciterData() async {
    final reciterId = audioPlayerProvider.currentReciterId;
    final favoriteSurahProvider = context.read<FavoriteSurah>();
    if (reciterId == null) return;

    final recitationsManager = context.read<RecitationsManager>();
    if (_lastLoadedReciterId != reciterId) {
      _lastLoadedReciterId = reciterId;
      await recitationsManager.getRecitations(reciterId: reciterId);
    }

    if (_lastDownloadedReciterId != reciterId) {
      _lastDownloadedReciterId = reciterId;
      await downloadController.fetchDownloadedRecitation(
        reciterId: reciterId.toString(),
      );
    }

    if (_lastFavoriteReciterId != reciterId) {
      _lastFavoriteReciterId = reciterId;
      final listFavoriteSurahs = await favoriteSurahProvider
          .fetchFavoriteSurahs(reciterId.toString());

      if (!mounted) return;
      setState(() {
        likedSurahsIds = listFavoriteSurahs;
      });
    }
  }

  bool _matchesSearch(SurahModel chapter) {
    if (_searchQuery.isEmpty) return true;

    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final normalizedName = (chapter.name ?? '').trim().toLowerCase();

    return chapter.id.toString().contains(normalizedQuery) ||
        normalizedName.contains(normalizedQuery);
  }

  @override
  void dispose() {
    audioPlayerProvider.removeListener(_onReciterChanged);
    searchController.dispose();
    searchTextFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recitationsManager = Provider.of<RecitationsManager>(context);
    Provider.of<RecitorsProvider>(context);
    context.watch<DownloadController>(); // Watch for download changes
    final Reciter? currentReciter = audioPlayerProvider.getCurrentReciterV3(
      context: context,
    );
    final List<SurahModel> surahs =
        recitationsManager.surahs
            .where((chapter) {
              if (likedSurahsIds.contains(chapter.id)) return false;

              return currentReciter?.surahsList?.contains(
                    chapter.id.toString(),
                  ) ??
                  false;
            })
            .where(_matchesSearch)
            .toList();
    final List<SurahModel> downloadableSurahs =
        currentReciter == null
            ? const []
            : surahs.where((chapter) {
              final reciterId = currentReciter.id;
              final chapterId = chapter.id;
              return downloadController.singleSavedRecitation(
                        reciterId: reciterId,
                        recitationId: chapterId,
                      ) ==
                      null &&
                  !downloadController.isQueued(
                    reciterId: reciterId.toString(),
                    chapterId: chapterId.toString(),
                  ) &&
                  !(downloadController.inProgressSurahs[reciterId.toString()]
                          ?.containsKey(chapterId.toString()) ??
                      false);
            }).toList();

    bool isErrorView =
        recitationsManager.state == RecitationsScreenState.failed;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        context.read<NavigationControllerV3>().popPage(0);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ListeningSearchTextField(
                  hasSuffix: _searchQuery.isNotEmpty,
                  hint: context.tr.search_for_surah,
                  controller: searchController,
                  onSubmittedPressed: (_) {},
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSuffixPressed: () {
                    searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Opacity(
                opacity:
                    currentReciter == null || downloadableSurahs.isEmpty
                        ? 0.45
                        : 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Color(0xff4925c1),
                        Color(0xffc496fd),
                      ],
                    ),
                  ),
                  child: SizedBox(
                    height: 48,
                    width: 48,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: currentReciter == null || downloadableSurahs.isEmpty
                                ? null
                                : () async {
                                  await downloadController.queueBulkDownloads(
                                    context: context,
                                    reciter: currentReciter,
                                    surahs: downloadableSurahs,
                                  );
                                },
                        child: const Tooltip(
                          message: 'Download all surahs',
                          child: Center(
                            child: Icon(
                              ReciterIconV3.download,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.isFoldable ? 12 : 16),
          Expanded(
            child:
                recitationsManager.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isErrorView
                    ? ApiErrorWidget(
                      callback:
                          () => recitationsManager.getRecitations(
                            reciterId:
                                audioPlayerProvider.currentReciterId ?? 1,
                            retry: true,
                          ),
                    )
                    : surahs.isEmpty
                    ? Center(
                      child: Text(
                        context.tr.no_surah_found,
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.builder(
                      key: const Key('surah_page_listview'),
                      padding: widget.listPadding,
                      itemCount: surahs.length,
                      itemBuilder: (context, index) {
                        return SurahListTileV3(
                          chapter: surahs[index],
                          chapters: context.read<RecitationsManager>().surahs,
                          reciter: audioPlayerProvider.getCurrentReciterV3(
                            context: context,
                          ),
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
