import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';
import 'package:mawaqit_quran_listening/src/utils/helpers/mawaqit_icons_icons.dart';

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // The app's colorScheme surface colours don't follow light/dark mode,
    // so pick dark text on light themes and light text on dark themes.
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isOffline) ...[
              Icon(
                MawaqitIcons.wifi_off,
                size: 80,
                color: subtitleColor,
              ),
              const SizedBox(height: 16),
              Text(
                context.tr.no_internet_connection,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr.msg_internet_connection,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: subtitleColor,
                ),
              ),
            ] else ...[
              const Icon(
                MawaqitIcons.alert,
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
