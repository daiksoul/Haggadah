import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haggah/bible/dat.dart';
import 'package:haggah/bible/struct.dart';
import 'package:haggah/custom_selectable_text/custom_selectable_text.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum Answer { right, wrong, pasiv }

class VocalTestPage extends StatefulWidget {
  const VocalTestPage({super.key});

  @override
  State<StatefulWidget> createState() => VocalTestState();
}

class VocalTestState extends State<VocalTestPage> {
  bool _loaded = false;
  final List<MultiVerseTestForm> _list = [];
  final List<MultiVerseTestForm> _unsub = [];
  final List<MultiVerseTestForm> _rigt = [];
  final List<String> _wron = [];
  bool _listening = false;

  int _selectionStart = -1;
  int _selectionEnd = -1;
  final _cursorNode = FocusNode();

  Answer state = Answer.pasiv;

  String _spoken = "";
  String _buffer = "";

  final _bookFinder = RegExp(r'\S*(?=\s*\d+[장편])');
  final _chapFinder = RegExp(r'\d+(?=[장편])');
  final _mvrsFinder = RegExp(r'\d+(?=(절\s*부터\s*))|(?<=(절\s*부터\s*))\d+(?=절)');
  final _svrsFinder = RegExp(r'\d+(?=절)');

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    loadVerses();
  }

  void loadVerses() {
    Future.delayed(Duration.zero, () async {
      _list.clear();
      _rigt.clear();
      _unsub.clear();
      final vc = ModalRoute.of(context)!.settings.arguments as VerseCollection;
      for (final mv in vc.verses) {
        _list.add(await MultiVerseTestForm.getFromMultiVerse(mv));
      }
      _loaded = true;
      setState(() {});
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
    ]);
    _listening = false;
    super.dispose();
  }

  MultiVerseTestForm? _findFromCollection() {
    final init = _spoken.substring(0, _spoken.indexOf("말씀입니다"));
    final bookMatch = _bookFinder.firstMatch(init);
    final chapMatch = _chapFinder.firstMatch(init);
    final mvrsMatch = List.of(_mvrsFinder.allMatches(init));
    final srvsMatch = _svrsFinder.allMatches(init);

    final lst = <int>{};
    while (mvrsMatch.isNotEmpty) {
      for (int i = int.parse(mvrsMatch[0][0].toString());
          i < int.parse(mvrsMatch[1][0].toString());
          i++) {
        lst.add(i);
      }
      mvrsMatch.removeAt(0);
      mvrsMatch.removeAt(0);
    }
    if (srvsMatch.isNotEmpty) {
      for (final match in srvsMatch) {
        lst.add(int.parse(match[0].toString()));
      }
    }
    // print(lst);
    final search = _list.where((element) => element.matchWith(
        Book.findByKor(bookMatch?[0].toString() ?? "창세기"),
        int.parse(chapMatch?[0].toString() ?? "1"),
        lst));
    if (search.isNotEmpty) {
      return search.first;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: (state == Answer.pasiv)
            ? Colors.grey.shade900
            : ((state == Answer.right)
                ? Colors.green.shade300
                : Colors.red.shade300),
        body: (_loaded)
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      width: constraints.maxWidth,
                      child: Stack(
                        children: [
                          if (_list.isNotEmpty && _spoken.isEmpty)
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text("텍스트를 길게 눌러 수정하거나 삭제하세요", style: TextStyle(color: Colors.white.withAlpha(100)),),
                            ),
                          
                          (_list.isNotEmpty)
                              ? Align(
                                  alignment: Alignment.topCenter,
                                  child: CustomSelectableText(
                                    _spoken,
                                    focusNode: _cursorNode,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.center,
                                    onSelectionChanged: (sel, _) {
                                      _selectionStart = sel.start;
                                      _selectionEnd = sel.end;
                                    },
                                    showCursor: true,
                                    items: [
                                      CustomSelectableTextItem.icon(
                                        icon: const Icon(Icons.backspace_outlined),
                                        controlType: SelectionControlType.other,
                                        onPressed: (start, end) {
                                            setState(() {
                                              _spoken = _spoken.replaceRange(start, end, "");
                                            });
                                        },
                                      ),
                                    ],
                                  )
                                )
                              : Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 100),
                                  child: ListView(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text("정답 ${_rigt.length}개",
                                            style: TextStyle(
                                              color: Colors.green.shade300,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                            )),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ...List.generate(
                                          _rigt.length,
                                          (index) => Text(
                                                _rigt[index]
                                                    .multiVerse
                                                    .getShortName(),
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              )),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text("오답 ${_wron.length}회",
                                            style: TextStyle(
                                              color: Colors.red.shade300,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ...List.generate(_wron.length, (index) {
                                        return Text(
                                          '${_wron[index]}\n',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        );
                                      }),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text("미제출 ${_unsub.length}개",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ...List.generate(_unsub.length, (index) {
                                        return Text(
                                            _unsub[index]
                                                .multiVerse
                                                .getShortName(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
      
                          if (_list.isNotEmpty)
                            Align(
                              alignment: AlignmentGeometry.bottomCenter,
                            // Positioned(
                            //   bottom: 400,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusGeometry.circular(5),
                                  color: Color(0x88000000),
                                ),
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.only(bottom: 150),
                                child: Text(
                                    _buffer,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              )
                            ),
      

                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: constraints.maxWidth * 0.6,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  MaterialButton(
                                    onPressed: () {
                                      if (_list.isNotEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            content: const Text("시험을 종료하시겠습니까?"),
                                            actions: [
                                              TextButton(
                                                style: Theme.of(context)
                                                    .textButtonTheme
                                                    .style,
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("취소"),
                                              ),
                                              Consumer<AppSpeechTextState>(
                                                builder: (context, state, _) {
                                                  return TextButton(
                                                    onPressed: () {
                                                      _listening = false;
                                                      state.stop();
                                                      Navigator.pop(context);
                                                      _unsub.addAll(_list);
                                                      _list.clear();
                                                    },
                                                    style: Theme.of(context)
                                                        .textButtonTheme
                                                        .style,
                                                    child: const Text("확인"),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                                    shape: const CircleBorder(),
                                    color: Colors.grey,
                                    height: 75,
                                    minWidth: 75,
                                    child: Icon(
                                      _list.isNotEmpty ? Icons.clear : Icons.arrow_back_ios_new,
                                      size: 37,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (_list.isNotEmpty)
                                    MaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          _spoken = "";
                                          _buffer = "";
                                        });
                                      },
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
                                  if (_list.isNotEmpty)
                                    Consumer<AppSpeechTextState>(
                                      builder: (context, state, _) {
                                        return MaterialButton(
                                          onPressed: () {
                                            if (!_listening) {
                                              setState(() {
                                                _listening = true;
                                              });
                                              Timer.periodic(
                                                const Duration(milliseconds: 1),
                                                    (a) => timerCallback(a, state),
                                              );
                                              state.start((res) {
                                                // print(res.recognizedWords);
                                                setState(() {
                                                  _buffer = res.recognizedWords;
                                                });
                                              });
                                            } else {
                                              setState(() {
                                                _listening = false;
                                              });
                                              state.stop();
                                            }
                                          },
                                          color: _listening ? Colors.redAccent : Colors.grey,
                                          shape: const CircleBorder(),
                                          height: 75,
                                          minWidth: 75,
                                          child: Icon(
                                            _listening ? Icons.mic : Icons.mic_off,
                                            size: 37,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: Stack(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(color: Colors.grey.shade900),
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "구절을 불러오는 중입니다...",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  void timerCallback(Timer timer, AppSpeechTextState state) {
    if (_listening) {
      if (state.speech.lastStatus == 'done') {
        setState(() {
          if (_buffer.isNotEmpty) {
            if ((_selectionStart == -1 && _selectionEnd == -1) || _spoken.isEmpty) {
              _spoken = "${_spoken.trim()} $_buffer";
            } else {
                _spoken = "${_spoken.substring(0, _selectionStart).trim()} $_buffer ${_spoken.substring(_selectionEnd).trim()}";
            }
            _selectionStart = -1;
            _selectionEnd = -1;
            _cursorNode.unfocus();
          }
          _buffer = "";

          if (_spoken.contains("아멘")) {
            final search = _findFromCollection();
            if (search != null) {
              final tmp = _spoken.replaceAll(RegExp(r"\s"), "");
              final submit = tmp
                  .substring(tmp.indexOf("말씀입니다") + "말씀입니다".length)
                  .replaceAll("아멘", "");
              final answerPattern = RegExp(search.getAllVerses());
              if (answerPattern.hasMatch(submit)) {
                if (this.state == Answer.pasiv) {
                  this.state = Answer.right;
                  _rigt.add(search);
                  _list.remove(search);
                  HapticFeedback.lightImpact();
                  if (_list.isEmpty) {
                    _listening = false;
                  }
                }
              } else {
                if (this.state == Answer.pasiv) {
                  this.state = Answer.wrong;
                  _wron.add(_spoken);
                  HapticFeedback.heavyImpact();
                }
              }
              Timer(
                const Duration(milliseconds: 500),
                () => setState(() => this.state = Answer.pasiv),
              );
            }
            _spoken = "";
            _buffer = "";
          }
        });
        state.continu();
      }
    } else {
      timer.cancel();
    }
  }
}

class AppSpeechTextState extends ChangeNotifier {
  SpeechToText speech = SpeechToText();
  void Function(SpeechRecognitionResult)? callback;

  void init() async {
    await speech.initialize(debugLogging: false);
    notifyListeners();
  }

  void continu() async {
    await speech.listen(onResult: callback);
    notifyListeners();
  }

  void start(void Function(SpeechRecognitionResult)? callback) async {
    this.callback = callback;
    await speech.listen(onResult: callback);
    notifyListeners();
  }

  void stop() async {
    await speech.stop();
    notifyListeners();
  }
}

class MultiVerseTestForm {
  late List<VerseTestForm> list = [];
  final MultiVerse multiVerse;
  MultiVerseTestForm(this.multiVerse, this.list);

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

  String getAllVerseReadable() {
    return list.map((e) => e.content).join(" ");
  }

  static Future<MultiVerseTestForm> getFromMultiVerse(MultiVerse mul) async {
    final lst = <VerseTestForm>[];
    for (final v in mul.verse) {
      lst.add(await VerseTestForm.getFromVerse(v));
    }
    return MultiVerseTestForm(mul, lst);
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
  toReturn = toReturn.replaceAll(RegExp('[,.\\-\\+\\\'\\"?~!\\s]'), '');
  toReturn = toReturn.replaceAll(RegExp('(\\[.*\\]|\\(.*\\))'), '');
  toReturn = toReturn.characters.toList().join(".*");
  return toReturn;
}
