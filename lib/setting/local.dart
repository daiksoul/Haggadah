import 'dart:convert';
import 'dart:io';

import 'package:haggah/setting/settings_model.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<AppSettings> loadSettings() async {
  final path = await _localPath;
  final file = File('$path/settings.json');

  if (!(await file.exists())) {
    await file.create();
    return AppSettings.defaultSettings();
  }

  return AppSettings.fromJson(jsonDecode(await file.readAsString()));
}

Future<void> writeSettings(AppSettings setting) async {
  final path = await _localPath;
  final file = File('$path/settings.json');

  if (!(await file.exists())) {
    await file.create();
  }

  await file.writeAsString(jsonEncode(setting.toJson()));
}
