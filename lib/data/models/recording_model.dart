class Recording {
  final String id;
  final String filePath;
  final String fileName;
  final DateTime createdAt;
  final Duration duration;
  final int fileSize;
  final String format;
  final bool isScheduled;
  final DateTime? scheduledTime;
  final RecordingStatus status;
  
  Recording({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.createdAt,
    required this.duration,
    required this.fileSize,
    required this.format,
    this.isScheduled = false,
    this.scheduledTime,
    this.status = RecordingStatus.idle,
  });
  
  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      id: json['id'],
      filePath: json['filePath'],
      fileName: json['fileName'],
      createdAt: DateTime.parse(json['createdAt']),
      duration: Duration(milliseconds: json['duration']),
      fileSize: json['fileSize'],
      format: json['format'],
      isScheduled: json['isScheduled'] ?? false,
      scheduledTime: json['scheduledTime'] != null 
          ? DateTime.parse(json['scheduledTime']) 
          : null,
      status: RecordingStatus.values[json['status']],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration.inMilliseconds,
      'fileSize': fileSize,
      'format': format,
      'isScheduled': isScheduled,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'status': status.index,
    };
  }
}

enum RecordingStatus {
  idle,
  recording,
  paused,
  scheduled,
  completed,
  failed,
}