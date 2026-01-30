import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../mawaqit_quran_listening.dart';
import '../../../mawaqit_quran_listening.dart' as recitor_controller;
import '../../ui/listening_components/reciter_list_tile.dart';
import 'package:provider/provider.dart';

class FakeRecitorsList extends StatelessWidget {
  const FakeRecitorsList({super.key, this.listPadding});

  final EdgeInsetsGeometry? listPadding;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Skeletonizer(
        enabled: true,
        child: ListView.builder(
          key: const Key('recitors_tab_listview'),
          itemCount: fakeReciters.length,
          padding: listPadding,
          itemBuilder: (context, index) {
            return GestureDetector(
              key: Key('recitor_tile_key_$index'),
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.closeKeyboard();
                FocusManager.instance.primaryFocus?.unfocus();
                context.read<AudioPlayerProvider>().reciters =
                    context.read<recitor_controller.RecitorsProvider>().reciters;
                context.read<AudioPlayerProvider>().changeReciter(fakeReciters[index]);
                context.read<PlayerScreensController>().setRecitor(fakeReciters[index]);
                context.read<NavigationControllerV3>().navigateToPage(pageIndex: 1);
              },
              child: RecitorListTile(
                recitor: fakeReciters[index],
                listeningTab: ListeningTab.allRecitator,
                index: index,
              ),
            );
          },
        ),
      ),
    );
  }
}
