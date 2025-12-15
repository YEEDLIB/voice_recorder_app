import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  
  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
  });
  
  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration? _duration;
  Duration? _position;
  
  @override
  void initState() {
    super.initState();
    _initAudioSession();
    _loadAudio();
  }
  
  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }
  
  Future<void> _loadAudio() async {
    try {
      setState(() => _isLoading = true);
      await _audioPlayer.setFilePath(widget.audioPath);
      
      _audioPlayer.durationStream.listen((duration) {
        setState(() => _duration = duration);
      });
      
      _audioPlayer.positionStream.listen((position) {
        setState(() => _position = position);
      });
      
      _audioPlayer.playerStateStream.listen((state) {
        if (state.playing) {
          setState(() => _isPlaying = true);
        } else {
          setState(() => _isPlaying = false);
        }
      });
      
    } catch (e) {
      print('Error loading audio: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        if (_duration != null && _position != null)
          Slider(
            value: _position!.inMilliseconds.toDouble(),
            min: 0,
            max: _duration!.inMilliseconds.toDouble(),
            onChanged: (value) {
              _audioPlayer.seek(Duration(milliseconds: value.toInt()));
            },
          ),
        
        // Time display
        if (_duration != null && _position != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position!)),
                Text(_formatDuration(_duration!)),
              ],
            ),
          ),
        
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: () {
                _audioPlayer.seek(Duration.zero);
              },
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () async {
                if (_isPlaying) {
                  await _audioPlayer.pause();
                } else {
                  await _audioPlayer.play();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                _audioPlayer.stop();
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () {
                // Implement next track if you have a playlist
              },
            ),
          ],
        ),
      ],
    );
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}