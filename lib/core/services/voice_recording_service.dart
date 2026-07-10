import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecordingService extends ChangeNotifier {
  late RecorderController _recorderController;
  final ValueNotifier<RecorderValue> _recorderValue =
      ValueNotifier<RecorderValue>(RecorderValue());

  VoiceRecordingService() {
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100
      ..bitRate = 1024 * 64
      ..overrideAudioSession = true;

    _recorderController.addListener(_handleRecordingListener);
  }

  ValueNotifier<RecorderValue> get recorderValueNotifier => _recorderValue;
  RecorderController get recorderController => _recorderController;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  void clearError() => _errorMessage = null;

  bool _maxDurationReached = false;
  bool get maxDurationReached => _maxDurationReached;

  void _handleRecordingListener() {
    if (_recorderController.elapsedDuration.inMinutes >= 5) {
      _maxDurationReached = true;
      stopRecording();
      notifyListeners();
      return;
    }

    final oldState = _recorderValue.value;
    if (oldState.state != _recorderController.recorderState ||
        oldState.duration != _recorderController.elapsedDuration) {
      _recorderValue.value = oldState.copyWith(
        state: _recorderController.recorderState,
        duration: _recorderController.elapsedDuration,
      );
    }
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    _errorMessage = null;
    _maxDurationReached = false;
    try {
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        throw Exception("Microphone permission is required to record a voice message.");
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final draftPath = '${directory.path}/draft_audio_$timestamp.m4a';
      await _recorderController.record(path: draftPath);
    } catch (e) {
      AppLogger.logMap({"Error": e}, title: "Record Failure");
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> pauseRecording() async {
    try {
      await _recorderController.pause();
    } catch (e) {
      AppLogger.logMap({"Error": e}, title: "Pause Failure");
    }
  }

  Future<void> resumeRecording() async {
    if (_maxDurationReached) return; // Recording was already finalized at the cap
    try {
      await _recorderController.record();
    } catch (e) {
      AppLogger.logMap({"Error": e}, title: "Resume Failure");
    }
  }

  Future<String?> stopRecording() async {
    final audioPath = await _recorderController.stop();

    final oldState = _recorderValue.value;
    _recorderValue.value = RecorderValue(
      audioPath: audioPath,
      duration: oldState.duration,
      state: RecorderState.stopped,
    );

    return audioPath;
  }

  Future<void> cancelRecording() async {
    final path = await _recorderController.stop();
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
    _recorderValue.value = RecorderValue(); // Reset to initial state
    _maxDurationReached = false;
  }

  void reset() {
    _recorderValue.value = RecorderValue();
    _maxDurationReached = false;
  }

  @override
  void dispose() {
    _recorderController.removeListener(_handleRecordingListener);
    _recorderController.dispose();
    _recorderValue.dispose();
    super.dispose();
  }
}

class RecorderValue {
  final String? audioPath;
  final Duration duration;
  final RecorderState state;

  RecorderValue({
    this.audioPath,
    this.duration = Duration.zero,
    this.state = RecorderState.stopped,
  });

  String get durationString {
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, "0");
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, "0");

    return '$minutes:$seconds';
  }

  RecorderValue copyWith({
    String? audioPath,
    Duration? duration,
    RecorderState? state,
  }) {
    return RecorderValue(
      audioPath: audioPath ?? this.audioPath,
      state: state ?? this.state,
      duration: duration ?? this.duration,
    );
  }

  @override
  String toString() =>
      'RecorderValue( duration: $duration, audioPath: $audioPath, state: $state)';
}
