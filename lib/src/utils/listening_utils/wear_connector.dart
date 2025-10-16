import 'dart:convert';
import 'package:flutter/services.dart';

class WearConnector {
  static const _channel = MethodChannel('com.mawaqit.app/app_group');

  static Future<Map<String, dynamic>> isWatchConnected() async {
    try {
      final result = await _channel.invokeMethod('isWatchConnected');

      // Ensure result is a Map
      if (result is Map) {
        final bool connected = result['connected'] ?? false;
        final String? deviceName = result['deviceName'];
        return {
          'connected': connected,
          'deviceName': deviceName,
        };
      } else {
        // Fallback if the result isn't what we expect
        return {'connected': false, 'deviceName': null};
      }
    } catch (e) {
      print('Wear check failed: $e');
      return {'connected': false, 'deviceName': null};
    }
  }

  static Future<void> sendRecitorUrl(Map<String, dynamic> payload) async {
    final String jsonString = jsonEncode(payload);
    await _channel.invokeMethod('sendRecitorUrl', {'recitorUrl': jsonString});
  }
}
