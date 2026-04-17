import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mawaqit_quran_listening/src/extensions/device_extensions.dart';
import 'package:provider/provider.dart';
import '../../../../mawaqit_quran_listening.dart';
import '../../listening_components/reciter_list_tile.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:sizer/sizer.dart';

class AllRecitatorsTab extends StatefulWidget {
  const AllRecitatorsTab({super.key, required this.listPadding});

  final EdgeInsetsGeometry? listPadding;

  @override
  State<AllRecitatorsTab> createState() => _AllRecitatorsTabState();
}

class _AllRecitatorsTabState extends State<AllRecitatorsTab> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      context.read<RecitorsProvider>().getReciters(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerProvider = context.read<AudioPlayerProvider>();
    return Consumer<RecitorsProvider>(
      builder: (context, provider, child) {
        if (provider.state == RecitersScreenState.loading) {
          return FakeRecitorsList(listPadding: widget.listPadding,);
        }
        if (provider.reciters.isEmpty && provider.originalReciters.isNotEmpty) {
          return Expanded(
            child: Center(
              child: Text(
                context.tr.no_recitator_found,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        }

        if (provider.reciters.isEmpty){
          return Expanded(
            child: Center(
              child: Text(
                context.tr.not_downloaded_recitation,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        }

        return Expanded(
          child: ListView.builder(
            key: const Key('recitors_tab_listview'),
            itemCount: provider.reciters.length,
            padding: widget.listPadding,
            itemBuilder: (context, index) {
              return RecitorListTile(
                key: Key('recitor_tile_key_$index'),
                recitor: provider.reciters[index],
                listeningTab: ListeningTab.allRecitator,
                index: index,
                onTap: () {
                  context.closeKeyboard();
                  FocusManager.instance.primaryFocus?.unfocus();

                  final selectedReciter = provider.reciters[index];

                  // Set reciters list in audio provider
                  audioPlayerProvider.reciters = provider.originalReciters;

                  // Change reciter (this sets currentReciterId)
                  audioPlayerProvider.changeReciter(selectedReciter);

                  // Set reciter in player screens controller
                  context.read<PlayerScreensController>().setRecitor(
                    selectedReciter,
                  );

                  // Navigate to page 1 (Surah page)
                  if (!context.isFoldable) {
                    context.read<NavigationControllerV3>().navigateToPage(
                      pageIndex: 1,
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
