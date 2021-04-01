import 'dart:async';

import 'package:flutter/services.dart';

/// Class to capture screenshots with native code working on background
class FlutterNativeScreenshot {
  static const MethodChannel _channel = const MethodChannel('flutter_native_screenshot');

  /// Captures everything as is shown in user's device.
  ///
  /// Returns [null] if an error occurs.
  /// Returns a [String] with the path of the screenshot.
  static Future<String?> takeScreenshot() async {
    final String? path = await _channel.invokeMethod('takeScreenshot');
    return path;
  }
}
