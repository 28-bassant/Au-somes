import 'package:audioplayers/audioplayers.dart';

class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playSuccess() async {
    await _player.play(
      AssetSource('sounds/success.mp3'),
      volume: 1.0,
    );
  }
}

