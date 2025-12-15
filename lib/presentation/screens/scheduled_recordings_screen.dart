// lib/presentation/screens/scheduled_recordings_screen.dart
import 'package:flutter/material.dart';

class ScheduledRecordingsScreen extends StatelessWidget {
  const ScheduledRecordingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Recordings'),
      ),
      body: const Center(
        child: Text('Scheduled recordings will appear here'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement schedule recording dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}