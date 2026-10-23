import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../core/services/voice_recording_service.dart';
import '../../controllers/ai_chat_controller.dart';

/// Records a voice note and sends it.
class VoiceRecorderWidget extends StatefulWidget {
  final VoidCallback onClose;

  const VoiceRecorderWidget({super.key, required this.onClose});

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with WidgetsBindingObserver {
  late final VoiceRecordingService _recordingService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recordingService = context.read<VoiceRecordingService>();
    _recordingService.addListener(_onRecordingServiceChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordingService.startRecording();
    });
  }

  void _onRecordingServiceChanged() {
    final error = _recordingService.errorMessage;
    if (error != null && mounted) {
      AppSnackBar.showError(context, message: error);
      _recordingService.clearError();
      widget.onClose();
      return;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _recordingService.removeListener(_onRecordingServiceChanged);
    WidgetsBinding.instance.removeObserver(this);
    // Leaving the chat must not leave the shared recorder running (CHAT-EC-02).
    if (_recordingService.isActive) _recordingService.cancelRecording();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_recordingService.isActive) _handleCancel();
    }
  }

  void _handleCancel() {
    _recordingService.cancelRecording();
    widget.onClose();
  }

  void _handleSend() async {
    final duration = _recordingService.recorderValueNotifier.value.duration;
    if (duration.inSeconds < 1) {
      _handleCancel();

      return;
    }

    final path = await _recordingService.stopRecording();
    if (!mounted) return;

    if (path != null) {
      final controller = context.read<AiChatController>();
      final durationStr =
          _recordingService.recorderValueNotifier.value.durationString;
      controller.sendAudioMessage(path, durationStr);
    }
    _recordingService.reset();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.globalBackground,
      padding: const EdgeInsets.only(top: 8, bottom: 24, left: 24, right: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _handleCancel,
                    child: const Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  ValueListenableBuilder<RecorderValue>(
                    valueListenable: _recordingService.recorderValueNotifier,
                    builder: (context, value, child) {
                      return Row(
                        children: [
                          AppText.bodyMedium(
                            value.durationString,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: AudioWaveforms(
                              enableGesture: true,
                              size: const Size(double.infinity, 32),
                              recorderController:
                                  _recordingService.recorderController,
                              waveStyle: WaveStyle(
                                waveColor:
                                    AppColors.primary.withValues(alpha: 0.8),
                                extendWaveform: true,
                                showMiddleLine: false,
                                waveThickness: 2.5,
                                spacing: 4.0,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Spacer(),
                  ValueListenableBuilder<RecorderValue>(
                    valueListenable: _recordingService.recorderValueNotifier,
                    builder: (context, value, child) {
                      final isRecording =
                          value.state == RecorderState.recording;
                      final canToggle = !_recordingService.maxDurationReached;
                      return GestureDetector(
                        onTap: canToggle
                            ? () {
                                if (isRecording) {
                                  _recordingService.pauseRecording();
                                } else {
                                  _recordingService.resumeRecording();
                                }
                              }
                            : null,
                        child: Icon(
                          isRecording
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                          color: canToggle
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.3),
                          size: 24,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
