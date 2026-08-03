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
  final _ttsVoices = <Map<String,String>>[];

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
    _ttsVoices.clear();
    _ttsVoices.addAll( List.of(await _tts.getVoices).map((e) => Map.of(e).map((k,v) => MapEntry(k.toString(),v.toString())) ) );
    _tts.setProgressHandler((st1, start, end, st2) {
      _playHandler.updatePosition(start/st1.length);
    });
  }

  void applySettings(AppSettingState setting) {
    _tts.setSpeechRate(setting.speechRate);
    _tts.setPitch(setting.voicePitch);
    _tts.setVoice({"name": setting.ttsVoice, "locale": "ko-KR" });
    _playHandler.repeatOption = setting.repeatOption;
  }

  void setData(List<String> texts, String name, [double? speed = 1.0]) {
    _playHandler.setTexts(texts);
    _playHandler.setStorageName(name);
    if (speed != null) _playHandler.setSpeedValue(speed);
  }

  List<String> getVoices() {
    return _ttsVoices.where((g) =>
    g["locale"] == "ko-KR" && g["network_required"] == "0").map((
        a) => a["name"]??"ko-kr-x-ism-local").toList()..sort();
  }
}
