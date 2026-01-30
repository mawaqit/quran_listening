import 'package:flutter/material.dart';
import 'package:mawaqit_quran_listening/src/extensions/device_extensions.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../../mawaqit_quran_listening.dart';
import '../../../../mawaqit_quran_listening.dart' as recitor_controller;
import '../../listening_components/reciter_list_tile.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';

/// Liked/Favorite Recitators

class LikedTab extends StatefulWidget {
  const LikedTab({super.key, required this.listPadding});
  final EdgeInsetsGeometry? listPadding;

  @override
  State<LikedTab> createState() => _LikedTabState();
}

class _LikedTabState extends State<LikedTab> {
  late FavoriteReciter favoriteReciter;
  late RecitorsProvider recitorsProvider;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((callback){
      context.read<RecitorsProvider>().getReciters(context);
    });
    favoriteReciter = context.read<FavoriteReciter>();
    recitorsProvider = context.read<RecitorsProvider>();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FavoriteReciter>();
    return Consumer<RecitorsProvider>(
      builder: (context, provider, child) {
        return (favoriteReciter.favoriteReciterUuids.isEmpty)
            ? Expanded(
              child: Center(child: Text(context.tr.not_favorite_reciter)),
            )
            : recitorsProvider.recitersForFavorite.isEmpty
            ? Expanded(
              child: Center(child: Text(context.tr.no_favorite_recitor_found)),
            )
            : Expanded(
              child: ListView.builder(
                key: const Key('favorite_tab_listview'),
                itemCount: recitorsProvider.recitersForFavorite.length,
                padding: widget.listPadding,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  if (favoriteReciter.favoriteReciterUuids.contains(
                    recitorsProvider.recitersForFavorite[index].id.toString(),
                  )) {
                    return GestureDetector(
                      key: Key('favorite_tile_key_$index'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        context.closeKeyboard();
                        FocusManager.instance.primaryFocus?.unfocus();
                        context.read<AudioPlayerProvider>().reciters =
                            context
                                .read<recitor_controller.RecitorsProvider>()
                                .reciters;
                        context.read<AudioPlayerProvider>().changeReciter(
                          provider.reciters[index],
                        );
                        context.read<PlayerScreensController>().setRecitor(
                          provider.reciters[index],
                        );
                        if (!context.isFoldable){
                          context.read<NavigationControllerV3>().navigateToPage(
                            pageIndex: 1,
                          );
                        }
                      },
                      child: RecitorListTile(
                        recitor: recitorsProvider.recitersForFavorite[index],
                        listeningTab: ListeningTab.downloaded,
                        index: index,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            );
      },
    );
  }
}
