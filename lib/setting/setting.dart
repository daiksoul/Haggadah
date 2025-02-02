import 'package:flutter/material.dart';
import 'package:haggah/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("설정"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('테마'),
                Row(
                  children: [
                    Column(
                      children: [
                        Text('시스템'),
                        Radio<ThemeMode>(
                          groupValue: MyApp.of(context).myThemeMode,
                          value: ThemeMode.system,
                          onChanged: (v) {
                            setState(() {
                              MyApp.of(context).changeTheme(v);
                            });
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('아침'),
                        Radio<ThemeMode>(
                          groupValue: MyApp.of(context).myThemeMode,
                          value: ThemeMode.light,
                          onChanged: (v) {
                            setState(() {
                              MyApp.of(context).changeTheme(v);
                            });
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('저녁'),
                        Radio<ThemeMode>(
                          groupValue: MyApp.of(context).myThemeMode,
                          value: ThemeMode.dark,
                          onChanged: (v) {
                            setState(() {
                              MyApp.of(context).changeTheme(v);
                            });
                          },
                        ),
                      ],
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AppSettingState extends ChangeNotifier {
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
}
