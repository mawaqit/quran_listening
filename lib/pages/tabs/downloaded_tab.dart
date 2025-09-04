import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/download_controller.dart';
import '../../components/downloaded_surah_tile.dart';

class DownloadedTab extends StatelessWidget {
  const DownloadedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadController>(
      builder: (context, provider, child) {
        if (provider.surahRecitorList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.download_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No downloaded surahs',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Download surahs to listen offline',
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
          itemCount: provider.surahRecitorList.length,
          itemBuilder: (context, index) {
            final item = provider.surahRecitorList[index];
            return DownloadedSurahTile(
              surah: item.surah,
              reciter: item.recitor,
              onTap: () {
                // Handle downloaded surah selection
              },
              onDelete: () {
                provider.removeItemFromList(item.id);
              },
            );
          },
        );
      },
    );
  }
}
