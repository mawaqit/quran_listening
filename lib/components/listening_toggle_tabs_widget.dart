import 'package:flutter/material.dart';

enum ListeningTab { liked, allRecitator, downloaded }

class ListeningToggleTabsWidget extends StatefulWidget {
  const ListeningToggleTabsWidget({super.key, required this.onTabChanged});

  final Function(ListeningTab tab) onTabChanged;

  @override
  State<ListeningToggleTabsWidget> createState() =>
      _ListeningToggleTabsWidgetState();
}

class _ListeningToggleTabsWidgetState extends State<ListeningToggleTabsWidget> {
  int selectedIndex = 1; // Default to all recitators

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            key: ValueKey(selectedIndex),
            children: [
              Container(
                key: const Key('liked_toggle_key'),
                child: ListeningToggleButton(
                  title: 'Liked',
                  icon: Icons.favorite,
                  isSelected: selectedIndex == 0,
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                    widget.onTabChanged(ListeningTab.liked);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Container(
                key: const Key('recitors_toggle_key'),
                child: ListeningToggleButton(
                  title: 'All Recitators',
                  icon: Icons.person,
                  isSelected: selectedIndex == 1,
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                    widget.onTabChanged(ListeningTab.allRecitator);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Container(
                key: const Key('downloaded_toggle_key'),
                child: ListeningToggleButton(
                  title: 'Downloaded',
                  icon: Icons.download,
                  isSelected: selectedIndex == 2,
                  onTap: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                    widget.onTabChanged(ListeningTab.downloaded);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListeningToggleButton extends StatelessWidget {
  const ListeningToggleButton({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
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
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
