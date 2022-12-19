import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget{
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<SettingsPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("설정"),
        leading: IconButton(
          icon: const Icon( Icons.arrow_back_ios_new ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class AppSettingState extends ChangeNotifier{
  bool _noVerseNumber = false;

  bool get noVerseNumber => _noVerseNumber;
  set noVerseNumber(val) {
    _noVerseNumber = val;
    notifyListeners();
  }

  
}