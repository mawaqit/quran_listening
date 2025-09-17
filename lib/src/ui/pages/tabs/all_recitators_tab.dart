import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../mawaqit_quran_listening.dart';
import '../../../../mawaqit_quran_listening.dart' as recitor_controller;
import '../../listening_components/reciter_list_tile.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:sizer/sizer.dart';

class AllRecitatorsTab extends StatefulWidget {
  const AllRecitatorsTab({super.key});

  @override
  State<AllRecitatorsTab> createState() => _AllRecitatorsTabState();
}

class _AllRecitatorsTabState extends State<AllRecitatorsTab> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      context.read<RecitorsProvider>().getReciters(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecitorsProvider>(
      builder: (context, provider, child) {
        if (provider.state == RecitersScreenState.loading) {
          return const FakeRecitorsList();
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

        return provider.reciters.isEmpty
            ? Expanded(
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
            )
            : Expanded(
              child: ListView.builder(
                key: const Key('recitors_tab_listview'),
                itemCount: provider.reciters.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    key: Key('recitor_tile_key_$index'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      context.closeKeyboard();
                      FocusManager.instance.primaryFocus?.unfocus();
                      
                      final selectedReciter = provider.reciters[index];
                      
                      // Set reciters list in audio provider
                      context.read<AudioPlayerProvider>().reciters =
                          context
                              .read<recitor_controller.RecitorsProvider>()
                              .reciters;
                      
                      // Change reciter (this sets currentReciterId)
                      context.read<AudioPlayerProvider>().changeReciter(
                        selectedReciter,
                      );
                      
                      // Set reciter in player screens controller
                      context.read<PlayerScreensController>().setRecitor(
                        selectedReciter,
                      );
                      
                      // Navigate to page 1 (Surah page)
                      context.read<NavigationControllerV3>().navigateToPage(
                        pageIndex: 1,
                      );
                    },
                    child: RecitorListTile(
                      recitor: provider.reciters[index],
                      listeningTab: ListeningTab.allRecitator,
                      index: index,
                    ),
                  );
                },
              ),
            );
      },
    );
  }
}
