class AppConstants {
  static const String appName = 'Voice Recorder';
  static const String recordingChannel = 'recording_channel';
  static const String notificationTitle = 'Recording in progress';
  static const String notificationBody = 'Voice recorder is recording audio';
  
  // Audio formats
  static const String audioFormatAAC = 'aac';
  static const String audioFormatWAV = 'wav';
  
  // Storage
  static const String recordingsFolder = 'Recordings';
  
  // Method channels
  static const String methodChannel = 'com.voice_recorder.app/channel';
  static const String recordingServiceChannel = 'recording_service';
  
  // Shared preferences keys
  static const String scheduledRecordingsKey = 'scheduled_recordings';
  static const String audioQualityKey = 'audio_quality';
  static const String audioFormatKey = 'audio_format';
}