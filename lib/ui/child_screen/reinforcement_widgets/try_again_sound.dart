import 'package:audioplayers/audioplayers.dart';

class TryAgainSound {
  static Future<void> play() async {
    print('TRY AGAIN SOUND CALLED');

    final player = AudioPlayer();
    await player.play(
      AssetSource('sounds/try_again.mp3'),
    );
  }
}

