import 'dart:async';

import 'package:flutter/material.dart';

import './local.dart' as local;

class AppSettings {
  ThemeMode themeMode;
  double speechRate;
  bool expandByDefault;

  AppSettings(
      {required this.themeMode,
      required this.speechRate,
      required this.expandByDefault});

  factory AppSettings.defaultSettings() {
    return AppSettings(
        themeMode: ThemeMode.system, speechRate: 1, expandByDefault: true);
  }

  AppSettings copyWith(
      {ThemeMode? themeMode, double? speechRate, bool? expandByDefault}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      speechRate: speechRate ?? this.speechRate,
      expandByDefault: expandByDefault ?? this.expandByDefault,
    );
  }

  void copyFrom(AppSettings other) {
    themeMode = other.themeMode;
    speechRate = other.speechRate;
    expandByDefault = other.expandByDefault;
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.toJson(),
        'speechRate': speechRate,
        'expandByDefault': expandByDefault,
      };

  factory AppSettings.fromJson(Map<String, dynamic> map) {
    final setting = AppSettings.defaultSettings();
    return setting.copyWith(
      themeMode: SettingThemeMode.fromString(map['themeMode'] as String?),
      speechRate: (map['speechRate'] as num?)?.toDouble(),
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

  bool _expandVerse = false;

  bool get expandVerse => _expandVerse;
  set expandVerse(val) {
    _expandVerse = val;
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
