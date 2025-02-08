import 'package:audio_service/audio_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioPlayHandler extends BaseAudioHandler {
  late final FlutterTts _tts;
  final List<String> _texts = [];
  var currentIndex = 0;
  var repeat = false;

  void setTexts(List<String> newTexts) {
    _texts.clear();
    _texts.addAll(newTexts);
    currentIndex = 0;
  }

  @override
  Future<void> play() async {
    playbackState.add(
      playbackState.value.copyWith(
        playing: true,
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.pause,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        processingState: AudioProcessingState.ready,
      ),
    );
    _tts.speak(_texts[currentIndex]);
  }

  @override
  Future<void> stop() async {
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        controls: [MediaControl.skipToPrevious, MediaControl.rewind],
      ),
    );
    _tts.stop();
  }

  @override
  Future<void> pause() async {
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
      ),
    );
    _tts.pause();
  }

  @override
  Future<void> skipToNext() async {
    currentIndex = (currentIndex + 1) % _texts.length;
    _tts.stop();
    play();
  }

  @override
  Future<void> skipToPrevious() async {
    currentIndex = (currentIndex - 1) % _texts.length;
    _tts.stop();
    play();
  }

  @override
  Future<void> rewind() async {
    currentIndex = 0;
    _tts.stop();
    play();
  }

  AudioPlayHandler(FlutterTts tts) {
    _tts = tts;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        processingState: AudioProcessingState.idle,
      ),
    );
    _tts.setCompletionHandler(() {
      if (currentIndex != _texts.length - 1) {
        skipToNext();
      } else if (repeat) {
        rewind();
      } else {
        stop();
      }
    });
  }
}
