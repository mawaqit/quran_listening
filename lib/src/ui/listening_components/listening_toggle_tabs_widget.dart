import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import '../../extensions/theme_extension.dart';
import '../../providers/listening_toggle_index_provider.dart';
import 'package:provider/provider.dart';
import '../components/svg_image_asset.dart';
import '../pages/quran_listening_page.dart';

class ListeningToggleTabsWidget extends StatefulWidget {
  const ListeningToggleTabsWidget({super.key, required this.onTabChanged});

  final Function(ListeningTab tab) onTabChanged;

  @override
  State<ListeningToggleTabsWidget> createState() => _ListeningToggleTabsWidgetState();
}

class _ListeningToggleTabsWidgetState extends State<ListeningToggleTabsWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ListeningToggleIndexProvider>(
      builder: (context, provider, child) {
        int selectedIndex = provider.selectedIndex;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Align(
            alignment: context.isArabicLanguage ? Alignment.centerRight : Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                key: ValueKey(selectedIndex),
                children: [
                  Container(
                    key: const Key('liked_toggle_key'),
                    child: ListeningToggleButton(
                      title: context.tr.liked,
                      iconPath: 'assets/icons/heart_filled.svg',
                      isSelected: selectedIndex == 0,
                      onTap: () {
                        widget.onTabChanged(ListeningTab.liked);
                        context.read<ListeningToggleIndexProvider>().changeIndex(0);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    key: const Key('recitors_toggle_key'),
                    child: ListeningToggleButton(
                      title: context.tr.all_recitators,
                      iconPath: 'assets/icons/ic_recitator.svg',
                      isSelected: selectedIndex == 1,
                      onTap: () {
                        widget.onTabChanged(ListeningTab.allRecitator);
                        context.read<ListeningToggleIndexProvider>().changeIndex(1);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    key: const Key('downloaded_toggle_key'),
                    child: ListeningToggleButton(
                      title: context.tr.downloaded,
                      iconPath: 'assets/icons/download.svg',
                      isSelected: selectedIndex == 2,
                      onTap: () {
                        widget.onTabChanged(ListeningTab.downloaded);
                        context.read<ListeningToggleIndexProvider>().changeIndex(2);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ListeningToggleButton extends StatelessWidget {
  const ListeningToggleButton({
    super.key,
    required this.iconPath,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String iconPath;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.colorScheme.primary : context.colorScheme.tertiaryContainer.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SvgImageAsset(
              iconPath,
              color: isSelected ? context.colorScheme.onSecondary : context.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: isSelected ? context.colorScheme.onSecondary : context.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
