// lib/presentation/providers/app_init_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_recorder_app/core/utils/permission_handler.dart';

final appInitProvider = FutureProvider<bool>((ref) async {
  // Initialize app components
  await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
  
  // Check if we have required permissions
  final hasPermissions = await AppPermissionHandler.hasRequiredPermissions();
  
  // You can add other initialization tasks here
  // For example:
  // - Initialize database
  // - Load user settings
  // - Check for updates
  
  return hasPermissions;
});