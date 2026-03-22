import 'package:audioplayers/audioplayers.dart';

class TrueAnswerSound {
  static Future<void> play() async {

    final player = AudioPlayer();
    await player.play(
      AssetSource('sounds/true.mp3'),
    );
  }
}
