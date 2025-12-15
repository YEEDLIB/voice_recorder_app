// lib/presentation/screens/recordings_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_recorder_app/presentation/providers/recording_provider.dart';

class RecordingsListScreen extends ConsumerWidget {
  const RecordingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recordings'),
      ),
      body: recordingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : recordingState.recordings.isEmpty
              ? const Center(child: Text('No recordings yet'))
              : ListView.builder(
                  itemCount: recordingState.recordings.length,
                  itemBuilder: (context, index) {
                    final recording = recordingState.recordings[index];
                    return ListTile(
                      leading: const Icon(Icons.audio_file),
                      title: Text(recording.fileName),
                      subtitle: Text('Duration: ${_formatDuration(recording.duration)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref.read(recordingProvider.notifier).deleteRecording(recording.id);
                        },
                      ),
                      onTap: () {
                        // TODO: Implement playback screen
                      },
                    );
                  },
                ),
    );
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}