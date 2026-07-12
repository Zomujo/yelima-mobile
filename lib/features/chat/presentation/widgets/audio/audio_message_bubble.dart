import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/services/audio_player_manager.dart';
import '../../../../../injection_container.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../domain/services/audio_cache_manager.dart';

class AudioMessageBubble extends StatefulWidget {
  final String audioUrl;
  final bool isUser;
  final String durationString;
  final String messageId;
  final String? localChatId;

  const AudioMessageBubble({
    super.key,
    required this.audioUrl,
    required this.isUser,
    required this.durationString,
    required this.messageId,
    this.localChatId,
  });

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  late PlayerController _playerController;
  late AudioPlayerManager _playerManager;

  bool _isDownloaded = false;
  bool _isDownloading = false;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _playerManager = sl<AudioPlayerManager>();
    _playerController = PlayerController();

    _checkInitialState();
  }

  @override
  void didUpdateWidget(covariant AudioMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _checkInitialState();
    }
  }

  Future<void> _checkInitialState() async {
    _playerManager.register(_playerController);

    String? cachedPath = await AudioCacheManager().getPath(widget.messageId);
    if (cachedPath == null && widget.localChatId != null) {
      cachedPath = await AudioCacheManager().getPath(widget.localChatId!);
    }

    if (cachedPath != null) {
      _localPath = cachedPath;
      _isDownloaded = true;
      if (mounted) setState(() {});
      await _prepareAudio(_localPath!);
      return;
    }

    if (!widget.audioUrl.startsWith('http')) {
      final file = File(widget.audioUrl);
      if (await file.exists() && await file.length() > 0) {
        _localPath = widget.audioUrl;
        _isDownloaded = true;
        if (mounted) setState(() {});
        await _prepareAudio(_localPath!);
        return;
      }
    }

    _isDownloaded = false;
    if (mounted) setState(() {});
  }

  List<double> _waveformData = [];
  int _maxDurationMs = 0;

  Future<void> _prepareAudio(String path) async {
    try {
      await _playerController.preparePlayer(
        path: path,
        shouldExtractWaveform: false,
        volume: 1.0,
      );
      
      final data = await _playerController.extractWaveformData(
        path: path,
        noOfSamples: const PlayerWaveStyle().getSamplesForWidth(200),
      );
      
      _waveformData = data;
      
      // Delay briefly to allow native platform to parse duration
      await Future.delayed(const Duration(milliseconds: 100));
      final duration = await _playerController.getDuration(DurationType.max);
      if (duration == 0) {
        throw Exception("Invalid audio file: duration is 0 (file might be corrupted HTML/XML).");
      }
      
      _maxDurationMs = duration;
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error preparing audio player: $e");
      // If preparation fails or duration is 0, the file is likely corrupted
      if (widget.audioUrl.startsWith('http') && _localPath != null) {
        final file = File(_localPath!);
        if (await file.exists()) {
          await file.delete();
        }
        if (mounted) {
          setState(() {
            _isDownloaded = false;
          });
        }
      } else if (!widget.audioUrl.startsWith('http')) {
        // If it's a local file and corrupted, just hide it or show error
        if (mounted) {
          setState(() {
            _isDownloaded = false;
          });
        }
      }
    }
  }

  Future<void> _downloadAudio() async {
    if (!widget.audioUrl.startsWith('http')) {
      debugPrint("Cannot download a local file path");
      return;
    }
    
    setState(() {
      _isDownloading = true;
    });
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final safeFileName = 'audio_${widget.audioUrl.hashCode.abs()}.m4a';
      _localPath = '${directory.path}/$safeFileName';
      
      await Dio().download(widget.audioUrl, _localPath!);
      
      await AudioCacheManager().savePath(widget.messageId, _localPath!);
      if (widget.localChatId != null) {
        await AudioCacheManager().savePath(widget.localChatId!, _localPath!);
      }
      
      _isDownloaded = true;
      await _prepareAudio(_localPath!);
    } catch (e) {
      debugPrint("Download error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _playerManager.unregister(_playerController);
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDownloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _isDownloading ? null : _downloadAudio,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.isUser ? Colors.white : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isDownloading
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.isUser ? AppColors.primary : Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.download_rounded,
                      color: widget.isUser ? AppColors.primary : Colors.white,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          AppText.labelMedium(
            "Voice message",
            color: widget.isUser ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(width: 24), // Extra spacing
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _playerManager.play(_playerController),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isUser ? Colors.white : AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: StreamBuilder<PlayerState>(
              stream: _playerController.onPlayerStateChanged,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data == PlayerState.playing;
                return Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                  color: widget.isUser ? AppColors.primary : Colors.white,
                  size: 24,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        StreamBuilder<int>(
          stream: _playerController.onCurrentDurationChanged,
          builder: (context, snapshot) {
            final currentDurationMs = snapshot.data ?? 0;
            
            int displayDurationMs = _maxDurationMs;
            
            if (_playerController.playerState == PlayerState.playing ||
                (_playerController.playerState == PlayerState.paused &&
                    currentDurationMs > 0)) {
              displayDurationMs = currentDurationMs;
            }

            final durationObj = Duration(milliseconds: displayDurationMs);
            final minutes =
                durationObj.inMinutes.remainder(60).toString().padLeft(2, '0');
            final seconds =
                durationObj.inSeconds.remainder(60).toString().padLeft(2, '0');
            final displayTime = "$minutes:$seconds";

            return AppText.labelMedium(
              displayTime,
              color: widget.isUser ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            );
          },
        ),
        const SizedBox(width: 12),
        AudioFileWaveforms(
          size: Size(MediaQuery.of(context).size.width * 0.35, 32),
          playerController: _playerController,
          waveformData: _waveformData,
          waveformType: WaveformType.fitWidth,
          playerWaveStyle: PlayerWaveStyle(
            fixedWaveColor: widget.isUser
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.grey.shade300,
            liveWaveColor: widget.isUser ? Colors.white : AppColors.primary,
            spacing: 4,
            waveThickness: 2.5,
          ),
        ),
      ],
    );
  }
}
