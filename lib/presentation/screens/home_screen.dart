import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recording_provider.dart';
import '../widgets/recording_list.dart';
import '../widgets/recording_controls.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recorder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScheduledRecordingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Current recording status
          if (state.isRecording)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.mic, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text(
                    'Recording...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () => ref.read(recordingProvider.notifier).stopRecording(),
                  ),
                ],
              ),
            ),
          
          // Error message
          if (state.error != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.withOpacity(0.1),
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          
          // Recording controls
          const Expanded(
            child: RecordingControls(),
          ),
          
          // Recordings list
          const Expanded(
            flex: 2,
            child: RecordingList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (state.isRecording) {
            ref.read(recordingProvider.notifier).stopRecording();
          } else {
            ref.read(recordingProvider.notifier).startRecording();
          }
        },
        backgroundColor: state.isRecording ? Colors.red : Colors.blue,
        child: Icon(
          state.isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }
}