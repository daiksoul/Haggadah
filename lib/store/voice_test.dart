import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haggah/bible/dat.dart';
import 'package:haggah/bible/verse.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VocalTestPage extends StatefulWidget {
  const VocalTestPage({super.key});

  @override
  State<StatefulWidget> createState() => VocalTestState();
}

class VocalTestState extends State<VocalTestPage> {
  final List<MultiVerseTestForm> _list = [];
  bool _listening = false;
  String _buffer = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      _buffer,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Consumer<AppSpeechTextState>(
                      builder: (context,state,_){
                        return MaterialButton(
                          onPressed: (!_listening)? () {
                            setState((){
                              _listening = true;
                            });
                            state.start(
                                (res){
                                  setState((){
                                    _buffer = res.recognizedWords;
                                  });
                                }
                            );
                          } :(){
                            setState(() {
                              _listening = false;
                            });
                            state.stop();
                          },
                          color: Colors.redAccent,
                          shape: const CircleBorder(),
                          height: 100,
                          minWidth: 100,
                          child: Icon(
                            _listening? Icons.mic:Icons.mic_off,
                            size: 50,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: constraints.maxWidth*0.6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: const Text("시험을 종료하시겠습니까?"),
                                  actions: [
                                    TextButton(
                                      child: const Text("취소"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("확인"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                ),
                              );
                            },
                            shape: const CircleBorder(),
                            color: Colors.grey,
                            height: 75,
                            minWidth: 75,
                            child: const Icon(
                              Icons.clear,
                              size: 37,
                              color: Colors.white,
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {},
                            shape: const CircleBorder(),
                            color: Colors.grey,
                            height: 75,
                            minWidth: 75,
                            child: const Icon(
                              Icons.refresh,
                              size: 37,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppSpeechTextState extends ChangeNotifier{
  SpeechToText speech = SpeechToText();
  void init()async{
    await speech.initialize();
    notifyListeners();
  }

  void start(void Function(SpeechRecognitionResult)? callback)async{
    await speech.listen(onResult: callback);
    notifyListeners();
  }

  void stop()async{
    await speech.stop();
    notifyListeners();
  }
}

class MultiVerseTestForm {
  final List<VerseTestForm> list = [];
  bool matchWith(Book book, int chapter, Iterable<int> verses) {
    final set1 = list.map((e) => e.verse).toSet();
    final set2 = set1.toSet();
    set2.addAll(verses);
    return book == list.first.book &&
        chapter == list.first.chapter &&
        set1.length == verses.length &&
        set1.length == set2.length;
  }

  String getAllVerses() {
    return getTestVerse(list.map((e) => e.content).join(""));
  }
}

class VerseTestForm {
  final Book book;
  final int chapter;
  final int verse;
  final String content;

  VerseTestForm(this.book, this.chapter, this.verse, this.content);

  static Future<VerseTestForm> getFromVerse(Verse verse) async {
    final content = (await verse.getVerse())["ZVERSE_CONTENT"] as String;
    return VerseTestForm(verse.book, verse.chapter, verse.verse, content);
  }
}

String getTestVerse(String verse) {
  String toReturn = verse;
  toReturn = toReturn.replaceAll(RegExp('[,.\\-\\+\\\'\\"?~! ]'), '');
  toReturn = toReturn.replaceAll(RegExp('(\\[.*\\]|\\(.*\\))'), '');
  return toReturn;
}
