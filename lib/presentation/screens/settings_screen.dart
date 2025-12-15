// lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/services/android_service_handler.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Battery Optimization Section
          _buildBatteryOptimizationCard(context),
          
          // Permissions Section
          _buildPermissionsCard(context),
          
          // Audio Settings
          _buildAudioSettingsCard(),
          
          // Storage Settings
          _buildStorageSettingsCard(),
        ],
      ),
    );
  }

  Widget _buildBatteryOptimizationCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Battery Optimization',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'For reliable background and scheduled recordings, '
              'please disable battery optimization for this app.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: AndroidServiceHandler.isIgnoringBatteryOptimizations(),
              builder: (context, snapshot) {
                final isIgnoring = snapshot.data ?? false;
                
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Battery Optimization Status',
                          style: TextStyle(
                            color: isIgnoring ? Colors.green : Colors.orange,
                          ),
                        ),
                        Icon(
                          isIgnoring ? Icons.check_circle : Icons.warning,
                          color: isIgnoring ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _checkAndRequestBatteryOptimization(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isIgnoring ? Colors.green : Colors.orange,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(
                        isIgnoring ? 'Optimization Disabled ✓' : 'Disable Optimization',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permissions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Microphone Permission
            FutureBuilder<PermissionStatus>(
              future: Permission.microphone.status,
              builder: (context, snapshot) {
                final status = snapshot.data ?? PermissionStatus.denied;
                return _buildPermissionRow(
                  icon: Icons.mic,
                  title: 'Microphone Access',
                  description: 'Required for voice recording',
                  status: status,
                  onTap: () async {
                    await Permission.microphone.request();
                  },
                );
              },
            ),
            
            const Divider(),
            
            // Notification Permission (Android 13+)
            FutureBuilder<PermissionStatus>(
              future: Permission.notification.status,
              builder: (context, snapshot) {
                final status = snapshot.data ?? PermissionStatus.denied;
                return _buildPermissionRow(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  description: 'Show recording notifications',
                  status: status,
                  onTap: () async {
                    await Permission.notification.request();
                  },
                );
              },
            ),
            
            const Divider(),
            
            // Exact Alarm Permission (Android 12+)
            FutureBuilder<bool>(
              future: _checkExactAlarmPermission(),
              builder: (context, snapshot) {
                final hasPermission = snapshot.data ?? false;
                return _buildPermissionRow(
                  icon: Icons.alarm,
                  title: 'Exact Alarms',
                  description: 'Required for scheduled recordings',
                  status: hasPermission ? PermissionStatus.granted : PermissionStatus.denied,
                  onTap: () async {
                    await Permission.scheduleExactAlarm.request();
                  },
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () async {
                final success = await _requestAllPermissions();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All permissions granted')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Some permissions were denied')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'Request All Permissions',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSettingsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audio Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Add your audio quality settings here
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSettingsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Storage Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Add your storage settings here
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow({
    required IconData icon,
    required String title,
    required String description,
    required PermissionStatus status,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(description),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(status),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getStatusText(status),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Color _getStatusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      default:
        return 'Unknown';
    }
  }

  Future<bool> _checkExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isGranted) {
      return true;
    }
    return false;
  }

  Future<void> _checkAndRequestBatteryOptimization(BuildContext context) async {
    final isIgnoring = await AndroidServiceHandler.isIgnoringBatteryOptimizations();
    
    if (!isIgnoring) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Battery Optimization'),
          content: const Text(
            'For reliable background recording, please disable battery optimization '
            'for this app. This ensures scheduled recordings work properly.\n\n'
            'You will be taken to the battery optimization settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                AndroidServiceHandler.requestIgnoreBatteryOptimizations();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Battery optimization is already disabled for this app'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<bool> _requestAllPermissions() async {
    // Request microphone permission
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return false;
    
    // Request notification permission (Android 13+)
    final notificationStatus = await Permission.notification.request();
    
    // Request exact alarm permission (Android 12+)
    final alarmStatus = await Permission.scheduleExactAlarm.request();
    
    return micStatus.isGranted && 
           (notificationStatus.isGranted || notificationStatus.isLimited) &&
           (alarmStatus.isGranted || alarmStatus.isLimited);
  }
}