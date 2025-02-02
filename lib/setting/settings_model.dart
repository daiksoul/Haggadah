import 'dart:async';

import 'package:flutter/material.dart';

import './local.dart' as local;

class AppSettings {
  ThemeMode themeMode;

  AppSettings({required this.themeMode});

  factory AppSettings.defaultSettings() {
    return AppSettings(themeMode: ThemeMode.system);
  }

  AppSettings copyWith({ThemeMode? themeMode}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  void copyFrom(AppSettings other) {
    themeMode = other.themeMode;
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.toJson(),
      };

  factory AppSettings.fromJson(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: SettingThemeMode.fromString(map['themeMode'] as String),
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

  static ThemeMode fromString(String string) => switch (string) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        'system' || _ => ThemeMode.system,
      };
}
