import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';

class ApiErrorWidget extends StatelessWidget {
  final String? error;
  final Function? callback;

  /// Shows the no-internet message instead of the generic error.
  final bool isOffline;

  const ApiErrorWidget({
    super.key,
    this.error,
    this.callback,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    const box = SizedBox(height: 32);
    const errorColor = Color(0xffb00020);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isOffline) ...[
              Icon(
                Icons.wifi_off_rounded,
                size: 80,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                context.tr.no_internet_connection,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr.msg_internet_connection,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              const Icon(
                Icons.error,
                size: 100,
                color: errorColor,
              ),
              box,
              Text(
                error ?? 'Oops! Something went wrong.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            box,
            ElevatedButton(
              child: Text(context.tr.qibla_Error_retry),
              onPressed: () {
                if (callback != null) callback!();
              },
            )
          ],
        ),
      ),
    );
  }
}
