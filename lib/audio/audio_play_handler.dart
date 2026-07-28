import 'package:audio_service/audio_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:haggah/setting/settings_model.dart';

class AudioPlayHandler extends BaseAudioHandler{
  late final FlutterTts _tts;
  final List<String> _texts = [];
  var _storageName = "";
  var _speed = 1.0;
  var currentIndex = 0;
  var repeatOption = RepeatOption.noRepeat;

  void updatePosition(double fraction) {
    playbackState.add(
      playbackState.value.copyWith(
        bufferedPosition: mediaItem.value?.duration??Duration(milliseconds: 1500),
        updatePosition: Duration(milliseconds: ((mediaItem.value?.duration?.inMilliseconds ?? 1500) * fraction).floor()),
        speed: 1.0
      ),
    );
  }

  void setTexts(List<String> newTexts) {
    _texts.clear();
    _texts.addAll(newTexts);
    currentIndex = 0;
  }

  void setStorageName(String name) {
    _storageName = name;
  }

  void setSpeedValue(double speed) {
    _speed = speed;
  }

  @override
  Future<void> play() async {
    final [text, title] = _texts[currentIndex].split("!!!");

    mediaItem.add(
      MediaItem(id: title, title: title, album: _storageName, duration: Duration(milliseconds: (100 * ( 2 - _speed)).floor() * text.length))
    );

    playbackState.add(
      playbackState.value.copyWith(
        playing: true,
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.pause,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: {
          MediaAction.seek,
        },
        processingState: AudioProcessingState.ready,
      ),
    );
    _tts.speak(text);
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
  Future<void> skipToQueueItem(int index) async {
    currentIndex = index;
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
      if (repeatOption == RepeatOption.repeatOne) {
        play();
      } else if (currentIndex != _texts.length - 1) {
        skipToNext();
      } else if (repeatOption == RepeatOption.repeatAll) {
        rewind();
      } else {
        stop();
      }
    });
  }
}
