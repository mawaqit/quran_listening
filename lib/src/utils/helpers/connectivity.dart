import 'dart:async';
import 'dart:io';

/// Checks for actual internet connectivity by making an HTTP request.
///
/// Unlike DNS lookups, this correctly detects captive portals (hotel WiFi,
/// airport WiFi) where DNS resolves but there is no real internet access.
/// Runs checks in parallel for fast failure when there is no internet.
Future<bool> checkInternetConnection() async {
  final results = await Future.wait([
    _tryConnectivityCheck(
      'https://connectivitycheck.gstatic.com/generate_204',
      expectedStatus: 204,
    ),
    _tryConnectivityCheck(
      'https://captive.apple.com/hotspot-detect.html',
      expectedStatus: 200,
    ),
  ]);
  return results.any((connected) => connected);
}

Future<bool> _tryConnectivityCheck(
  String url, {
  required int expectedStatus,
}) async {
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close().timeout(const Duration(seconds: 3));
    client.close();
    return response.statusCode == expectedStatus;
  } catch (_) {
    return false;
  }
}
