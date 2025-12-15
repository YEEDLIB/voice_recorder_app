import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/recording_model.dart';
import '../../data/repositories/recording_repository.dart';

final recordingProvider = StateNotifierProvider<RecordingNotifier, RecordingState>(
  (ref) => RecordingNotifier(ref.read(recordingRepositoryProvider)),
);

class RecordingNotifier extends StateNotifier<RecordingState> {
  final RecordingRepository _repository;
  
  RecordingNotifier(this._repository) : super(RecordingState.initial());
  
  Future<void> startRecording() async {
    // Check permissions
    final status = await Permission.microphone.request();
    final notificationStatus = await Permission.notification.request();
    
    if (!status.isGranted) {
      state = state.copyWith(
        error: 'Microphone permission denied',
      );
      return;
    }
    
    try {
      state = state.copyWith(
        isRecording: true,
        error: null,
      );
      
      final recording = await _repository.startRecording();
      
      state = state.copyWith(
        isRecording: false,
        currentRecording: recording,
      );
      
      // Load updated list
      await loadRecordings();
      
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> stopRecording() async {
    try {
      await _repository.stopRecording();
      state = state.copyWith(
        isRecording: false,
      );
      
      await loadRecordings();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }
  
  Future<void> loadRecordings() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final recordings = await _repository.getAllRecordings();
      state = state.copyWith(
        recordings: recordings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> deleteRecording(String id) async {
    try {
      await _repository.deleteRecording(id);
      await loadRecordings();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }
  
  Future<void> scheduleRecording(DateTime dateTime, Duration duration) async {
    try {
      await _repository.scheduleRecording(dateTime, duration);
      await loadScheduledRecordings();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }
  
  Future<void> loadScheduledRecordings() async {
    final scheduled = await _repository.getScheduledRecordings();
    state = state.copyWith(scheduledRecordings: scheduled);
  }
}

class RecordingState {
  final bool isRecording;
  final bool isLoading;
  final String? error;
  final Recording? currentRecording;
  final List<Recording> recordings;
  final List<Recording> scheduledRecordings;
  
  RecordingState({
    required this.isRecording,
    required this.isLoading,
    this.error,
    this.currentRecording,
    required this.recordings,
    required this.scheduledRecordings,
  });
  
  factory RecordingState.initial() {
    return RecordingState(
      isRecording: false,
      isLoading: false,
      recordings: [],
      scheduledRecordings: [],
    );
  }
  
  RecordingState copyWith({
    bool? isRecording,
    bool? isLoading,
    String? error,
    Recording? currentRecording,
    List<Recording>? recordings,
    List<Recording>? scheduledRecordings,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentRecording: currentRecording ?? this.currentRecording,
      recordings: recordings ?? this.recordings,
      scheduledRecordings: scheduledRecordings ?? this.scheduledRecordings,
    );
  }
}