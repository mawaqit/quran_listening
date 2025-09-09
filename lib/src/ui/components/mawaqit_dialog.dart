import 'package:flutter/material.dart';

class MawaqitDialog extends StatelessWidget {
  final Widget? widgetAboveButtons;
  final IconData? icon;
  final String title;
  final String content;
  final String? cancelText;
  final String okText;
  final String? thirdButtonText;
  final VoidCallback? onCancelPressed;
  final VoidCallback? onOkPressed;
  final VoidCallback? onThirdButtonPressed;

  const MawaqitDialog({
    super.key,
    this.icon,
    required this.title,
    required this.content,
    this.cancelText,
    required this.okText,
    this.onCancelPressed,
    this.onOkPressed,
    this.widgetAboveButtons,
    this.thirdButtonText,
    this.onThirdButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icon == null ? null : Icon(icon),
      title: Text(title),
      content: Text(content),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widgetAboveButtons != null) widgetAboveButtons!,
            Wrap(
              runSpacing: -5,
              alignment: WrapAlignment.end,
              children: [
                if (thirdButtonText != null)
                  TextButton(
                    onPressed: onThirdButtonPressed ?? () => Navigator.pop(context),
                    child: Text(thirdButtonText!, style: const TextStyle(color: Colors.grey)),
                  ),
                if (cancelText != null)
                  TextButton(
                    onPressed: onCancelPressed ?? () => Navigator.pop(context),
                    child: Text(cancelText!, style: const TextStyle(color: Colors.grey)),
                  ),
                TextButton(
                  key: const Key('mawaqit_dialog_on_yes_pressed'),
                  onPressed: onOkPressed ?? () => Navigator.pop(context),
                  child: Text(okText),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
