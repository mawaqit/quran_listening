import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../extensions/device_extensions.dart';
import '../../extensions/semantics_extension.dart';
import '../../extensions/theme_extension.dart';
import '../../models/reciter.dart';
import '../../models/surah_model.dart';
import '../../providers/favorite_reciter.dart';
import '../../providers/reciters_controller.dart';
import '../../utils/helpers/mawaqit_icon_v3_cions.dart';
import '../../utils/listening_utils/surah_availability.dart';
import '../pages/quran_listening_page.dart';
import 'reciter_list_tile.dart';

/// Forward arrow used as a row's trailing icon, mirrored for RTL.
IconData _forwardArrow(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl
        ? ReciterIconV3.arrow_left
        : ReciterIconV3.arrow_right;

/// One-line hint shown above the surah list when a reciter is incomplete.
class MissingSurahsBanner extends StatelessWidget {
  const MissingSurahsBanner({
    super.key,
    required this.reciter,
    required this.onTap,
  });

  final Reciter reciter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Label + numbers kept separate: no placeholders in our i18n pipeline.
    final count = reciter.availableSurahCount;
    final label =
        '${context.tr.surahs_in_this_recitation}: $count/$kTotalQuranSurahs';
    final semanticLabel =
        '${context.semanticTr.surahs_in_this_recitation}: $count '
        '${context.semanticTr.semantic_of} $kTotalQuranSurahs';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: const Key('missing_surahs_banner'),
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: context.colorScheme.primaryFixed,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: (context.isFoldable ? 7 : 11).sp,
                            color: context.colorScheme.onPrimaryContainer
                                .withValues(alpha: .9),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr.missing_surahs_suggestion,
                          style: TextStyle(
                            fontSize: (context.isFoldable ? 6 : 9).sp,
                            color: context.colorScheme.secondary.withValues(
                              alpha: .7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _forwardArrow(context),
                    size: 14.sp,
                    color: context.colorScheme.primaryFixed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ).semanticAction(
        context: context,
        label:
            '$semanticLabel. ${context.semanticTr.missing_surahs_suggestion}',
      ),
    );
  }
}

/// Shows the surahs [reciter] lacks; picking one lists reciters that have it.
/// Pass [initialSurah] to open directly on the reciter list for that surah.
Future<void> showMissingSurahsSheet(
  BuildContext context, {
  required Reciter reciter,
  required List<SurahModel> missingSurahs,
  required void Function(Reciter reciter, SurahModel surah) onReciterSelected,
  SurahModel? initialSurah,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (_) => _MissingSurahsSheet(
          reciter: reciter,
          missingSurahs: missingSurahs,
          initialSurah: initialSurah,
          onReciterSelected: onReciterSelected,
        ),
  );
}

class _MissingSurahsSheet extends StatefulWidget {
  const _MissingSurahsSheet({
    required this.reciter,
    required this.missingSurahs,
    required this.onReciterSelected,
    this.initialSurah,
  });

  final Reciter reciter;
  final List<SurahModel> missingSurahs;
  final SurahModel? initialSurah;
  final void Function(Reciter reciter, SurahModel surah) onReciterSelected;

  @override
  State<_MissingSurahsSheet> createState() => _MissingSurahsSheetState();
}

class _MissingSurahsSheetState extends State<_MissingSurahsSheet> {
  late SurahModel? _selectedSurah = widget.initialSurah;

  /// Back returns to the surah list only if the sheet started there.
  bool get _canGoBack => _selectedSurah != null && widget.initialSurah == null;

  /// Same voice in another recitation first, then favorites, then the rest.
  List<Reciter> _recitersWith(SurahModel surah) {
    final favoriteIds =
        context.read<FavoriteReciter>().favoriteReciterUuids.toSet();
    final mainId = widget.reciter.mainReciterId;
    final seen = <int>{widget.reciter.id};
    final sameVoice = <Reciter>[];
    final favorites = <Reciter>[];
    final others = <Reciter>[];

    for (final r in context.read<RecitorsProvider>().originalReciters) {
      if (!r.hasSurah(surah.id) || !seen.add(r.id)) continue;
      if (mainId != null && r.mainReciterId == mainId) {
        sameVoice.add(r);
      } else if (favoriteIds.contains(r.id.toString())) {
        favorites.add(r);
      } else {
        others.add(r);
      }
    }
    return [...sameVoice, ...favorites, ...others];
  }

  String _surahLabel(SurahModel surah) => '${surah.id} - ${surah.name}'.trim();

  @override
  Widget build(BuildContext context) {
    final surah = _selectedSurah;

    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _selectedSurah = null);
      },
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Column(
            children: [
              _SheetHeader(
                title:
                    surah == null
                        ? context.tr.missing_surahs
                        : _surahLabel(surah),
                onBack:
                    _canGoBack
                        ? () => setState(() => _selectedSurah = null)
                        : null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      surah == null
                          ? _buildSurahList()
                          : _buildReciterList(surah),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      key: const Key('missing_surahs_list'),
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      itemCount: widget.missingSurahs.length,
      itemBuilder: (context, index) {
        final surah = widget.missingSurahs[index];
        final label = _surahLabel(surah);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Material(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              key: Key('missing_surah_tile_${surah.id}'),
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _selectedSurah = surah),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: context.colorScheme.onPrimaryContainer,
                          fontSize: context.isFoldable ? 18 : 13.sp,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _forwardArrow(context),
                      size: 14.sp,
                      color: context.colorScheme.primaryFixed,
                    ),
                  ],
                ),
              ),
            ),
          ).semanticAction(
            context: context,
            label: label,
            hint: context.semanticTr.find_another_reciter,
          ),
        );
      },
    );
  }

  Widget _buildReciterList(SurahModel surah) {
    final reciters = _recitersWith(surah);
    return ListView.builder(
      key: ValueKey('reciters_for_surah_${surah.id}'),
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      itemCount: reciters.length,
      itemBuilder: (context, index) {
        final reciter = reciters[index];
        return RecitorListTile(
          key: Key('alternative_reciter_${reciter.id}'),
          recitor: reciter,
          listeningTab: ListeningTab.allRecitator,
          index: index,
          showTrailingAction: false,
          onTap: () {
            Navigator.of(context).pop();
            widget.onReciterSelected(reciter, surah);
          },
        );
      },
    );
  }
}

/// Mirrors the app's sheet header: back (or spacer), centered title, close.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onBack != null)
          _SheetIconButton(
            icon: isRtl ? ReciterIconV3.arrow_right : ReciterIconV3.arrow_left,
            label: context.semanticTr.back,
            onTap: onBack!,
          )
        else
          const SizedBox(width: 40),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colorScheme.onPrimaryContainer,
              fontSize: context.isFoldable ? 28 : 14.sp,
            ),
          ).semantic(context: context, header: true),
        ),
        _SheetIconButton(
          icon: ReciterIconV3.close,
          label: context.semanticTr.close,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// Same look as the app's MawaqitIconButtonV3: 40px filled circle.
class _SheetIconButton extends StatelessWidget {
  const _SheetIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(
          icon,
          color: context.colorScheme.onPrimaryContainer,
          size: 20,
        ),
      ),
    ).semanticAction(context: context, label: label);
  }
}
