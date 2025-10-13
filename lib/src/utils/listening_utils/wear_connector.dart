import 'package:flutter/services.dart';

class WearConnector {
  static const _channel = MethodChannel('com.mawaqit.app/app_group');

  static Future<bool> isWatchConnected() async {
    try {
      final bool connected = await _channel.invokeMethod('isWatchConnected');
      return connected;
    } catch (e) {
      print('Wear check failed: $e');
      return false;
    }
  }
}
