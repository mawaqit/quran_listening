import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';

import 'mawaqit_dialog.dart';

/// Tells the user a surah can't be streamed because the device is offline.
///
/// When [waitingForNetwork] is given, the dialog closes by itself as soon as
/// it turns false (connection restored).
Future<void> showNoInternetDialog(
  BuildContext context, {
  ValueListenable<bool>? waitingForNetwork,
}) async {
  BuildContext? dialogContext;
  void closeWhenOnline() {
    final openDialog = dialogContext;
    if (waitingForNetwork!.value || openDialog == null || !openDialog.mounted) return;
    dialogContext = null;
    Navigator.of(openDialog).pop();
  }

  waitingForNetwork?.addListener(closeWhenOnline);
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .3),
    builder: (context) {
      dialogContext = context;
      return MawaqitDialog(
        icon: Icons.wifi_off_rounded,
        title: context.tr.no_internet_connection,
        content: context.tr.msg_internet_connection,
        okText: context.tr.ok,
      );
    },
  );
  dialogContext = null;
  waitingForNetwork?.removeListener(closeWhenOnline);
}
