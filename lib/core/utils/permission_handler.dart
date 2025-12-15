// lib/core/utils/permission_handler.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AppPermissionHandler {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  /// Check and request all required permissions for the app
  static Future<Map<String, PermissionStatus>> requestAllPermissions() async {
    final results = <String, PermissionStatus>{};

    // Microphone Permission (Required)
    results['microphone'] = await Permission.microphone.request();

    // Notification Permission (Android 13+)
    final androidInfo = await deviceInfoPlugin.androidInfo;
    if (androidInfo.version.sdkInt >= 33) { // Android 13
      results['notification'] = await Permission.notification.request();
    }

    // Exact Alarm Permission (Android 12+)
    if (androidInfo.version.sdkInt >= 31) { // Android 12
      results['scheduleExactAlarm'] = 
          await Permission.scheduleExactAlarm.request();
    }

    // Optional: Storage permission for accessing recordings
    if (androidInfo.version.sdkInt <= 32) { // Before Android 13
      results['storage'] = await Permission.storage.request();
    }

    return results;
  }

  /// Check if all required permissions are granted
  static Future<bool> hasRequiredPermissions() async {
    final micGranted = await Permission.microphone.isGranted;
    if (!micGranted) return false;

    final androidInfo = await deviceInfoPlugin.androidInfo;
    
    // Check notification permission for Android 13+
    if (androidInfo.version.sdkInt >= 33) {
      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted && !notificationStatus.isLimited) {
        return false;
      }
    }

    // Check exact alarm permission for Android 12+
    if (androidInfo.version.sdkInt >= 31) {
      final alarmStatus = await Permission.scheduleExactAlarm.status;
      if (!alarmStatus.isGranted && !alarmStatus.isLimited) {
        return false;
      }
    }

    return true;
  }

  /// Get detailed permission status
  static Future<Map<String, String>> getPermissionStatus() async {
    final status = <String, String>{};
    
    // Microphone
    final micStatus = await Permission.microphone.status;
    status['microphone'] = _permissionStatusToString(micStatus);

    // Notifications
    final notificationStatus = await Permission.notification.status;
    status['notification'] = _permissionStatusToString(notificationStatus);

    // Exact Alarms
    final alarmStatus = await Permission.scheduleExactAlarm.status;
    status['exact_alarm'] = _permissionStatusToString(alarmStatus);

    // Storage
    final storageStatus = await Permission.storage.status;
    status['storage'] = _permissionStatusToString(storageStatus);

    return status;
  }

  /// Open app settings for manual permission configuration
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Show permission rationale dialog
  static Future<bool> showPermissionRationale({
    required String permissionName,
    required String reason,
  }) async {
    // You would implement a dialog here
    return true;
  }

  static String _permissionStatusToString(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.restricted:
        return 'Restricted';
      default:
        return 'Unknown';
    }
  }
}