import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:haggah/audio/audio_play_handler.dart';
import 'package:haggah/setting/settings_model.dart';

enum TtsPlayingState { playing, paused, stopped }

class TtsState extends ChangeNotifier {
  late AudioPlayHandler _playHandler;
  AudioHandler? _audioHandler;
  late FlutterTts _tts;

  AudioHandler get audioHandler {
    if (_audioHandler == null) {
      throw ErrorDescription("AudioHandler not initialized weee!");
    } else {
      return _audioHandler!;
    }
  }

  Future<void> init() async {
    _tts = FlutterTts();
    _playHandler = AudioPlayHandler(_tts);
    _audioHandler = await AudioService.init(
      builder: () => _playHandler,
      config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.haggah.channel.audio',
          androidNotificationChannelName: '하가 듣기'),
    );
    await _tts.awaitSpeakCompletion(true);
    _tts.setLanguage("ko-KR");
    _tts.setProgressHandler((st1, start, end, st2) {
      _playHandler.updatePosition(start/st1.length);
    });
  }

  void applySettings(AppSettingState setting) {
    _tts.setSpeechRate(setting.speechRate);
    _playHandler.repeatOption = setting.repeatOption;
  }

  void setData(List<String> texts, String name, [double? speed = 1.0]) {
    _playHandler.setTexts(texts);
    _playHandler.setStorageName(name);
    if (speed != null) _playHandler.setSpeedValue(speed);
  }
}
