import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart';
import '../../core/constants/app_constants.dart';

class LocalRecordingDataSource {
  final Record _audioRecorder;
  final Uuid _uuid;
  
  LocalRecordingDataSource()
      : _audioRecorder = Record(),
        _uuid = Uuid();
  
  Future<String> getRecordingsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory('${directory.path}/${AppConstants.recordingsFolder}');
    
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    
    return recordingsDir.path;
  }
  
  Future<String> generateRecordingFilePath(String format) async {
    final timestamp = DateTime.now();
    final fileName = 'record_${timestamp.year}_'
        '${timestamp.month.toString().padLeft(2, '0')}_'
        '${timestamp.day.toString().padLeft(2, '0')}_'
        '${timestamp.hour.toString().padLeft(2, '0')}_'
        '${timestamp.minute.toString().padLeft(2, '0')}_'
        '${timestamp.second.toString().padLeft(2, '0')}.$format';
    
    final dir = await getRecordingsDirectory();
    return '$dir/$fileName';
  }
  
  Future<void> startRecording({
    required String filePath,
    AudioEncoder encoder = AudioEncoder.aacLc,
    int bitRate = 128000,
    int sampleRate = 44100,
    int numChannels = 2,
  }) async {
    await _audioRecorder.start(
      path: filePath,
      encoder: encoder,
      bitRate: bitRate,
      sampleRate: sampleRate,
      numChannels: numChannels,
    );
  }
  
  Future<String?> stopRecording() async {
    return await _audioRecorder.stop();
  }
  
  Future<void> pauseRecording() async {
    await _audioRecorder.pause();
  }
  
  Future<void> resumeRecording() async {
    await _audioRecorder.resume();
  }
  
  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }
  
  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }
  
  Future<List<Recording>> getAllRecordings() async {
    final dir = await getRecordingsDirectory();
    final directory = Directory(dir);
    
    if (!await directory.exists()) {
      return [];
    }
    
    final files = await directory.list().where((file) {
      return file is File && 
          (file.path.endsWith('.aac') || 
           file.path.endsWith('.wav') ||
           file.path.endsWith('.m4a'));
    }).toList();
    
    final recordings = <Recording>[];
    
    for (final file in files) {
      final fileStat = await (file as File).stat();
      final fileName = file.path.split('/').last;
      
      recordings.add(Recording(
        id: _uuid.v4(),
        filePath: file.path,
        fileName: fileName,
        createdAt: fileStat.modified,
        duration: Duration.zero, // You'll need to extract this from audio metadata
        fileSize: fileStat.size,
        format: fileName.split('.').last,
        isScheduled: false,
      ));
    }
    
    recordings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recordings;
  }
  
  Future<void> deleteRecording(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}