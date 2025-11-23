import 'package:audioplayers/audioplayers.dart';

class SoundUtil {
  SoundUtil._();

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> _playSound(String fileName) async {
    try {
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      // Sound playback failed, silently ignore
    }
  }

  static Future<void> playBlockDrop() async {
    await _playSound('block_drop.mp3');
  }

  static Future<void> playSuccess() async {
    await _playSound('success.mp3');
  }

  static Future<void> playLevelUp() async {
    await _playSound('level_up.mp3');
  }

  static Future<void> playClick() async {
    await _playSound('click.mp3');
  }

  static Future<void> playStreakBonus() async {
    await _playSound('streak_bonus.mp3');
  }

  static void dispose() {
    _player.dispose();
  }
}
