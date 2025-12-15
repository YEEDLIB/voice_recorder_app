import 'package:flutter/services.dart';

class AndroidServiceHandler {
  static const MethodChannel _channel = 
      MethodChannel('com.voice_recorder.app/service');
  
  static Future<void> startForegroundService({
    required String filePath,
    int duration = 0,
  }) async {
    try {
      await _channel.invokeMethod('startForegroundService', {
        'filePath': filePath,
        'duration': duration,
      });
    } on PlatformException catch (e) {
      print('Failed to start service: ${e.message}');
    }
  }
  
  static Future<void> stopForegroundService() async {
    try {
      await _channel.invokeMethod('stopForegroundService');
    } on PlatformException catch (e) {
      print('Failed to stop service: ${e.message}');
    }
  }
  
  static Future<bool> checkBatteryOptimization() async {
    try {
      final result = await _channel.invokeMethod('checkBatteryOptimization');
      return result as bool;
    } on PlatformException {
      return false;
    }
  }
  
  static Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } on PlatformException catch (e) {
      print('Failed to request battery optimization: ${e.message}');
    }
  }
  
  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final result = await _channel.invokeMethod('isIgnoringBatteryOptimizations');
      return result as bool;
    } on PlatformException {
      return false;
    }
  }
}