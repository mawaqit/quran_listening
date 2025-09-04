import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/reciters_controller.dart';
import '../../components/reciter_list_tile.dart';

class LikedTab extends StatelessWidget {
  const LikedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecitorsProvider>(
      builder: (context, recitorsProvider, child) {
        if (recitorsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (recitorsProvider.recitersForFavorite.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No favorite reciters',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add reciters to your favorites to see them here',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recitorsProvider.recitersForFavorite.length,
          itemBuilder: (context, index) {
            final reciter = recitorsProvider.recitersForFavorite[index];
            return ReciterListTile(
              reciter: reciter,
              onTap: () {
                // Handle reciter selection
                recitorsProvider.changeReciter(reciter);
              },
            );
          },
        );
      },
    );
  }
}
