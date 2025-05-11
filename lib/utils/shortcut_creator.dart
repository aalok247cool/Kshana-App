import 'package:flutter/services.dart';

class ShortcutCreator {
  static const MethodChannel _channel = MethodChannel('com.kshana.app/shortcuts');

  static Future<bool> createShortcut({
    required String shortcutId,
    required String shortcutName,
    required String iconResourceName,
    required String deepLink,
  }) async {
    try {
      final bool result = await _channel.invokeMethod('createShortcut', {
        'shortcutId': shortcutId,
        'shortcutName': shortcutName,
        'iconResourceName': iconResourceName,
        'deepLink': deepLink,
      });
      return result;
    } on PlatformException catch (e) {
      print('Error creating shortcut: ${e.message}');
      return false;
    }
  }
}