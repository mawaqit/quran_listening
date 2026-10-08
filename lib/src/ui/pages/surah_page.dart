import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:mawaqit_quran_listening/src/ui/listening_components/all_surah_download_widget.dart';
import 'package:provider/provider.dart';

import '../../../mawaqit_quran_listening.dart';
import '../../extensions/device_extensions.dart';
import '../../utils/listening_utils/surah_availability.dart';
import '../listening_components/listening_search_textfield.dart';
import '../listening_components/missing_surahs_sheet.dart';
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

    final normalizedQuery = _normalizeSearchValue(_searchQuery);
    final searchableNames = <String>[
      chapter.name ?? '',
      chapter.englishName ?? '',
      chapter.frenchName ?? '',
      chapter.arabicName ?? '',
    ];

    return chapter.id.toString().contains(normalizedQuery) ||
        searchableNames.any(
          (name) => _normalizeSearchValue(name).contains(normalizedQuery),
        );
  }

  String _normalizeSearchValue(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('\u0640', '');
  }

  void _showMissingSurahs(
    Reciter reciter,
    List<SurahModel> missingSurahs, {
    SurahModel? initialSurah,
  }) {
    FocusScope.of(context).unfocus();
    showMissingSurahsSheet(
      context,
      reciter: reciter,
      missingSurahs: missingSurahs,
      initialSurah: initialSurah,
      onReciterSelected: (otherReciter, surah) {
        if (!mounted) return;
        openSurahPlayer(
          context,
          reciter: otherReciter,
          chapter: surah,
          chapters: context.read<RecitationsManager>().surahs,
        );
      },
    );
  }

  Widget _buildMissingSearchResult(
    Reciter reciter,
    List<SurahModel> missingSurahs,
    List<SurahModel> matches,
  ) {
    final single = matches.length == 1 ? matches.first : null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (single != null) ...[
              Text(
                '${single.id} - ${single.name}'.trim(),
                textAlign: TextAlign.center,
                style: TextTheme.of(context).titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              context.tr.not_available_from_reciter,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('find_another_reciter_button'),
              onPressed:
                  () => _showMissingSurahs(
                    reciter,
                    single == null ? matches : missingSurahs,
                    initialSurah: single,
                  ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: context.colorScheme.primaryContainer,
                foregroundColor: context.colorScheme.onPrimaryContainer,
              ),
              child: Text(context.tr.find_another_reciter),
            ),
          ],
        ),
      ),
    );
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
    final List<SurahModel> reciterSurahs =
        recitationsManager.surahs.where((chapter) {
          if (likedSurahsIds.contains(chapter.id)) return false;

          return currentReciter?.surahsList?.contains(chapter.id.toString()) ??
              false;
        }).toList();
    final List<SurahModel> surahs =
        reciterSurahs.where(_matchesSearch).toList();
    final List<SurahModel> missingSurahs =
        currentReciter != null && currentReciter.hasMissingSurahs
            ? recitationsManager.surahs
                .where((chapter) => !currentReciter.hasSurah(chapter.id))
                .toList()
            : const [];
    final List<SurahModel> missingMatches =
        _searchQuery.isEmpty || surahs.isNotEmpty
            ? const []
            : missingSurahs.where(_matchesSearch).toList();
    final bool showMissingBanner =
        missingSurahs.isNotEmpty && _searchQuery.isEmpty;
    final List<SurahModel> downloadableSurahs =
        currentReciter == null
            ? const []
            : reciterSurahs.where((chapter) {
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
    final bulkStatus =
        currentReciter == null
            ? null
            : downloadController.bulkDownloadStatus(
              currentReciter.id.toString(),
            );
    final totalSurahCount =
        currentReciter?.totalSurah ?? currentReciter?.surahsList?.length ?? 0;
    final bool hasRemainingBulkDownloads =
        bulkStatus == null
            ? downloadableSurahs.isNotEmpty
            : bulkStatus.downloadedCount < totalSurahCount;

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
          ListeningSearchTextField(
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
              FocusScope.of(context).unfocus();
            },
          ),
          SizedBox(height: context.isFoldable ? 10 : 12),
          AllSurahDownloadWidget(
            bulkStatus: bulkStatus,
            isEnabled: currentReciter != null && hasRemainingBulkDownloads,
            onDownloadAll: () async {
              if (currentReciter == null) return;
              await downloadController.queueBulkDownloads(
                context: context,
                reciter: currentReciter,
                surahs: downloadableSurahs,
              );
            },
            onCancel: (reciterId) async {
              await downloadController.cancelBulkDownloads(
                reciterId: reciterId,
              );
            },
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
                    : missingMatches.isNotEmpty
                    ? _buildMissingSearchResult(
                      currentReciter!,
                      missingSurahs,
                      missingMatches,
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
                      itemCount: surahs.length + (showMissingBanner ? 1 : 0),
                      itemBuilder: (context, position) {
                        if (showMissingBanner && position == 0) {
                          return MissingSurahsBanner(
                            reciter: currentReciter!,
                            onTap:
                                () => _showMissingSurahs(
                                  currentReciter,
                                  missingSurahs,
                                ),
                          );
                        }
                        final index =
                            showMissingBanner ? position - 1 : position;
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
