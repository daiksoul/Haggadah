import 'dart:async';

import 'package:flutter/material.dart';

import './local.dart' as local;

enum RepeatOption {
  noRepeat('no_repeat'),
  repeatAll('repeat_all'),
  repeatOne('repeat_one');

  final String string;

  const RepeatOption(this.string);

  static RepeatOption fromString(String? string) {
    return RepeatOption.values.firstWhere(
      (e) => e.string == string,
      orElse: () => RepeatOption.noRepeat,
    );
  }
}

class AppSettings {
  ThemeMode themeMode;
  double speechRate;
  RepeatOption repeatOption;
  bool expandByDefault;

  AppSettings(
      {required this.themeMode,
      required this.speechRate,
      required this.repeatOption,
      required this.expandByDefault});

  factory AppSettings.defaultSettings() {
    return AppSettings(
        themeMode: ThemeMode.system,
        speechRate: 1,
        repeatOption: RepeatOption.noRepeat,
        expandByDefault: true);
  }

  AppSettings copyWith(
      {ThemeMode? themeMode,
      double? speechRate,
      RepeatOption? repeatOption,
      bool? expandByDefault}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      speechRate: speechRate ?? this.speechRate,
      repeatOption: repeatOption ?? this.repeatOption,
      expandByDefault: expandByDefault ?? this.expandByDefault,
    );
  }

  void copyFrom(AppSettings other) {
    themeMode = other.themeMode;
    speechRate = other.speechRate;
    repeatOption = other.repeatOption;
    expandByDefault = other.expandByDefault;
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.toJson(),
        'speechRate': speechRate,
        'repeatOption': repeatOption.string,
        'expandByDefault': expandByDefault,
      };

  factory AppSettings.fromJson(Map<String, dynamic> map) {
    final setting = AppSettings.defaultSettings();
    return setting.copyWith(
      themeMode: SettingThemeMode.fromString(map['themeMode'] as String?),
      speechRate: (map['speechRate'] as num?)?.toDouble(),
      repeatOption: RepeatOption.fromString(map['repeatOption'] as String?),
      expandByDefault: map['expandByDefault'] as bool?,
    );
  }
}

class AppSettingState extends ChangeNotifier {
  Timer? task;

  void debounceSettings() {
    if (task != null) {
      task!.cancel();
    }
    task = Timer(const Duration(seconds: 1), () {
      saveSettings();
      print('Wrote!');
      task = null;
    });
  }

  final AppSettings _settings = AppSettings.defaultSettings();

  bool _noVerseNumber = false;

  bool get noVerseNumber => _noVerseNumber;
  set noVerseNumber(val) {
    _noVerseNumber = val;
    notifyListeners();
  }

  ThemeMode get themeMode => _settings.themeMode;
  set themeMode(ThemeMode v) {
    _settings.themeMode = v;
    notifyListeners();
    debounceSettings();
  }

  double get speechRate => _settings.speechRate;
  set speechRate(double v) {
    _settings.speechRate = v;
    notifyListeners();
    debounceSettings();
  }

  RepeatOption get repeatOption => _settings.repeatOption;
  set repeatOption(RepeatOption o) {
    _settings.repeatOption = o;
    notifyListeners();
    debounceSettings();
  }

  bool get expandByDefault => _settings.expandByDefault;
  set expandByDefault(bool b) {
    _settings.expandByDefault = b;
    notifyListeners();
    debounceSettings();
  }

  Future<void> loadSettings() async {
    _settings.copyFrom(await local.loadSettings());
    notifyListeners();
  }

  Future<void> saveSettings() async {
    await local.writeSettings(_settings);
  }
}

extension SettingThemeMode on ThemeMode {
  String toJson() => switch (this) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system'
      };

  static ThemeMode fromString(String? string) => switch (string) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        'system' || _ => ThemeMode.system,
      };
}
