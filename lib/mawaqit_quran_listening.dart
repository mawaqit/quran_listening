library;

import 'package:flutter/material.dart';

class CustomAlertBox {
  static Future showCustomAlertBox({required BuildContext context, required Widget willDisplayWidget}) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              willDisplayWidget,
              MaterialButton(
                color: Colors.white30,
                child: Text('close alert'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          elevation: 10,
        );
      },
    );
  }
}

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}
