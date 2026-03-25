import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Central audio service. Uses a pool of players so sounds can overlap.
class AudioService extends ChangeNotifier {
  // Separate players so correct + confetti sounds don't cancel each other
  final AudioPlayer _correct = AudioPlayer();
  final AudioPlayer _wrong   = AudioPlayer();
  final AudioPlayer _ui      = AudioPlayer();
  final AudioPlayer _reward  = AudioPlayer();

  static const double _vol = 0.75;

  Future<void> playCorrect()      => _playOn(_correct, 'correct.mp3');
  Future<void> playWrong()        => _playOn(_wrong,   'wrong.mp3');
  Future<void> playBrickCollect() => _playOn(_reward,  'brick.mp3');
  Future<void> playBingo()        => _playOn(_reward,  'bingo.mp3');
  Future<void> playUnlock()       => _playOn(_reward,  'unlock.mp3');
  Future<void> playTap()          => _playOn(_ui,      'tap.mp3');

  Future<void> _playOn(AudioPlayer player, String file) async {
    try {
      await player.stop();
      await player.setVolume(_vol);
      await player.play(AssetSource('audio/$file'));
    } catch (_) {
      // Silently fail — app works without sound
    }
  }

  void dispose() {
    _correct.dispose();
    _wrong.dispose();
    _ui.dispose();
    _reward.dispose();
  }
}
