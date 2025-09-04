import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../models/reciter.dart';

class ReciterListTile extends StatelessWidget {
  const ReciterListTile({
    super.key,
    required this.reciter,
    required this.onTap,
  });

  final Reciter reciter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            reciter.reciterName.isNotEmpty ? reciter.reciterName[0].toUpperCase() : 'R',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          reciter.reciterName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          reciter.style ?? 'Reciter',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.play_arrow,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: onTap,
      ),
    );
  }
}
