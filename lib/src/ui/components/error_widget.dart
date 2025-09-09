import 'package:flutter/material.dart';
import 'package:mawaqit_mobile_i18n/mawaqit_localization.dart';

class ApiErrorWidget extends StatelessWidget {
  final String? error;
  final Function? callback;

  const ApiErrorWidget({super.key, this.error, this.callback});

  @override
  Widget build(BuildContext context) {
    const box = SizedBox(height: 32);
    const errorColor = Color(0xffb00020);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.error,
            size: 100,
            color: errorColor,
          ),
          box,
          Text(
            error ?? 'Oops! Something went wrong.',
            style: const TextStyle(
              color: errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          box,
          ElevatedButton(
            child: Text(context.tr.qibla_Error_retry),
            onPressed: () {
              if (callback != null) callback!();
            },
          )
        ],
      ),
    );
  }
}