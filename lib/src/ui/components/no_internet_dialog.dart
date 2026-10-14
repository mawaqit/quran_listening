import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';

import 'mawaqit_dialog.dart';

/// Tells the user a surah can't be streamed because the device is offline.
Future<void> showNoInternetDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .3),
    builder: (dialogContext) => MawaqitDialog(
      icon: Icons.wifi_off_rounded,
      title: context.tr.no_internet_connection,
      content: context.tr.msg_internet_connection,
      okText: context.tr.ok,
    ),
  );
}
