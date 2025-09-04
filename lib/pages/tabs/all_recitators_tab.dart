import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/reciters_controller.dart';
import '../../components/reciter_list_tile.dart';

class AllRecitatorsTab extends StatelessWidget {
  const AllRecitatorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecitorsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.isError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load reciters',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    provider.getReciters(context);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.reciters.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No reciters found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.reciters.length,
          itemBuilder: (context, index) {
            final reciter = provider.reciters[index];
            return ReciterListTile(
              reciter: reciter,
              onTap: () {
                // Handle reciter selection
                provider.changeReciter(reciter);
              },
            );
          },
        );
      },
    );
  }
}
