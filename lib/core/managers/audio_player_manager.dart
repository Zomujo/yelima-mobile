import 'package:flutter/widgets.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class AudioPlayerManager with WidgetsBindingObserver {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() {
    return _instance;
  }
  AudioPlayerManager._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  final List<PlayerController> _controllers = [];

  void register(PlayerController controller) {
    if (!_controllers.contains(controller)) {
      _controllers.add(controller);
    }
  }

  void unregister(PlayerController controller) {
    _controllers.remove(controller);
  }

  Future<void> play(PlayerController controller) async {
    if (controller.playerState == PlayerState.playing) {
      await controller.pausePlayer();
      return;
    }

    for (var c in _controllers) {
      if (c != controller && c.playerState == PlayerState.playing) {
        await c.pausePlayer();
      }
    }
    await controller.startPlayer(finishMode: FinishMode.pause);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      for (var c in _controllers) {
        if (c.playerState == PlayerState.playing) {
          c.pausePlayer();
        }
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}

