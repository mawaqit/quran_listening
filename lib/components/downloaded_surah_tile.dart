import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../models/reciter.dart';
import '../models/surah_model.dart';

class DownloadedSurahTile extends StatelessWidget {
  const DownloadedSurahTile({
    super.key,
    required this.surah,
    required this.reciter,
    required this.onTap,
    required this.onDelete,
  });

  final SurahModel surah;
  final Reciter reciter;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Text(
            surah.id.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          surah.name ?? 'Surah ${surah.id}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          reciter.reciterName,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
