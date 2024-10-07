import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAudio(String url) async {
    await _audioPlayer.play(url);
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }
}
