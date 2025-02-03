import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:haggah/bible/struct.dart';
import 'package:haggah/main.dart';
import 'package:haggah/setting/settings_model.dart';
import 'package:haggah/store/storage.dart';
import 'package:haggah/util/theme.dart';
import 'package:haggah/util/verse_data.dart';
import 'package:provider/provider.dart';

import '../custom_selectable_text/src/custom_selectable_text.dart';
import '../custom_selectable_text/src/model/custom_selectable_text_item.dart';

class VerseCardPage extends StatefulWidget {
  const VerseCardPage({super.key});

  @override
  State<StatefulWidget> createState() => VerseCardState();
}

class VerseCardState extends State<VerseCardPage> {
  late VerseCollection _collect;
  late AppStorageState _stor;
  late ApplicationState _app;

  final List<List> _verseList = [];

  late List<bool> _expansion;

  final List<String> _colors = [
    'fbf719',
    '2ba727',
    '3aafdc',
    'ea5a79',
    '85569c',
  ];

  @override
  void dispose() {
    Future.delayed(Duration.zero, () {
      _stor.update2(_app.isSignedIn, _collect);
    });
    if (_playing) _tts.stop();
    super.dispose();
  }

  @override
  void initState() {
    ttsSetting();
    super.initState();

    Future.delayed(Duration.zero, () {
      _stor = Provider.of<AppStorageState>(context, listen: false);
      _app = Provider.of<ApplicationState>(context, listen: false);
      _collect = ModalRoute.of(context)!.settings.arguments as VerseCollection;
      final dExpansion =
          Provider.of<AppSettingState>(context, listen: false).expandByDefault;
      _expansion = List.generate(_collect.verses.length, (index) => dExpansion);
      _verseList.clear();
      _verseList.addAll(List.generate(_collect.verses.length, (index) => []));
      for (int j = 0; j < _collect.verses.length; j++) {
        _collect.verses[j].getAllVerses().then(
          (val) {
            _verseList[j] = val;
            setState(() {});
          },
        );
      }
    });
  }

  TextSpan _generateSpan(int index) {
    var mulVerse = _collect.verses[index];
    var text = List.generate(
      _verseList[index].length,
      (index2) => parseVerseData(
        _verseList[index][index2]["ZVERSE_CONTENT"].toString(),
      ),
    ).join("\n");

    if (text.isEmpty) {
      return const TextSpan(text: '로딩중...');
    }

    var lst = <TextSpan>[];

    int indexCut = 0;
    for (var light in mulVerse.comment) {
      lst.addAll([
        if (light.start > 0)
          TextSpan(text: text.substring(indexCut, light.start)),
        TextSpan(
            text: text.substring(light.start, light.end),
            style: TextStyle(
              backgroundColor: HexColor(light.color),
            )),
      ]);
      if (light.end <= text.length) {
        indexCut = light.end;
      }
    }

    lst.add(TextSpan(text: text.substring(indexCut)));

    var toRet = TextSpan(children: lst);

    return toRet;
  }

  var _playing = false;
  final _tts = FlutterTts();

  String getTTSString() {
    final lst = [];
    for (int i = 0; i < _collect.verses.length; i++) {
      lst.add(_collect.verses[i].getName());
      lst.addAll(
        List.generate(
          _verseList[i].length,
          (j) =>
              parseVerseDataMin(_verseList[i][j]["ZVERSE_CONTENT"].toString()),
        ),
      );
    }
    return lst.join('\n');
  }

  void ttsSetting() async {
    final rate =
        Provider.of<AppSettingState>(context, listen: false).speechRate;
    await _tts.awaitSpeakCompletion(true);
    _tts.setSpeechRate(rate);
    _tts.setLanguage("ko-KR");
    // _tts.setVoice(
    //   {
    //     "name": "ko-KR-default",
    //     "locale": "kor-default",
    //   },
    // );

    // final voices = await _tts.getVoices as List<Object?>;
    // final jsonVoices = voices.map((e) => jsonEncode(e)).toList();
    // final availableVoices = jsonVoices.map((e) => jsonDecode(e)).toList();
    // for (final m in jsonVoices) {
    //   print(m);
    // }
  }

  @override
  Widget build(BuildContext context) {
    _collect = ModalRoute.of(context)!.settings.arguments as VerseCollection;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return PopScope(
      onPopInvokedWithResult: (val, _) {},
      child: Scaffold(
        appBar: AppBar(
          title: Text(_collect.title),
          actions: [
            IconButton(
              icon: Icon(!_playing
                  ? Icons.play_circle_outline
                  : Icons.stop_circle_outlined),
              onPressed: !_playing
                  ? () async {
                      _tts.speak(getTTSString()).then((_) {
                        setState(() {
                          _playing = false;
                        });
                      });
                      setState(() {
                        _playing = true;
                      });
                    }
                  : () {
                      _tts.pause();
                      setState(() {
                        _playing = false;
                      });
                    },
            ),
            PopupMenuButton<int>(
              position: PopupMenuPosition.under,
              onSelected: (value) {
                if (value == 0) {
                  Navigator.pushNamed(context, "/practice",
                      arguments: _collect);
                } else {
                  Navigator.pushNamed(context, "/test", arguments: _collect);
                }
              },
              icon: const Icon(Icons.checklist),
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  value: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.record_voice_over),
                      SizedBox(
                        width: 5,
                      ),
                      Text("수동 검사")
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.mic),
                      SizedBox(
                        width: 5,
                      ),
                      Text("자동 검사"),
                    ],
                  ),
                ),
              ],
            ),
            // IconButton(
            //   icon: Icon(
            //       _cExpaneded ? Icons.close_fullscreen : Icons.open_in_full),
            //   onPressed: () {
            //     setState(() {
            //       _cExpaneded = !_cExpaneded;
            //       for (var i = 0; i < _verseList.length; i++) {
            //         _expansion[i] = _cExpaneded;
            //       }
            //     });
            //     // _listkey.currentState?.setState(() {});
            //   },
            // ),
            IconButton(
              icon: const Icon(
                Icons.edit,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      final controller = TextEditingController();
                      final formKey = GlobalKey<FormState>();
                      controller.text = _collect.title;
                      return AlertDialog(
                        title: const Text("이름 변경하기"),
                        content: Form(
                          key: formKey,
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: "새로운 이름"),
                            controller: controller,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "이름을 입력해야 합니다.";
                              }
                              return null;
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("취소"),
                          ),
                          Consumer<AppStorageState>(
                            builder: (context, state, _) {
                              return TextButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    Navigator.pop(context);
                                    setState(() {
                                      _collect.title = controller.text;
                                      state.update(context, _collect);
                                    });
                                  }
                                },
                                child: const Text("저장"),
                              );
                            },
                          ),
                        ],
                      );
                    });
              },
            )
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context, _collect);
            },
          ),
        ),
        body: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ReorderableListView.builder(
            itemBuilder: (context, i) => Padding(
              key: PageStorageKey(_collect.verses[i].getShortName()),
              padding: const EdgeInsets.all(5),
              child: AnimatedContainer(
                duration: const Duration(seconds: 1),
                decoration: BoxDecoration(
                  color: (isLightMode
                      ? odEvColor
                      : dOdEvColor)[i.isOdd ? 100 : 200],
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                      color: isLightMode ? odEvColor[300]! : dOdEvColor[300]!,
                      width: 0.5),
                ),
                child: ExpansionTile(
                  key: ValueKey(i),
                  initiallyExpanded: _expansion[i],
                  controlAffinity: ListTileControlAffinity.leading,
                  expandedAlignment: Alignment.centerLeft,
                  leading: SizedBox(
                    width: 30,
                    height: 24,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        final removed = _collect.verses.removeAt(i);
                        final removedId = i;
                        final removedT = _verseList.removeAt(i);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "${removed.getShortName()}절을 ${_collect.title}에서 제거하였습니다."),
                          action: SnackBarAction(
                            label: "취소",
                            onPressed: () {
                              setState(() {
                                _collect.verses.insert(removedId, removed);
                                _verseList.insert(i, removedT);
                              });
                            },
                          ),
                        ));
                      });
                    },
                  ),
                  title: Text(
                    _collect.verses[i].getShortName(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                      child: CustomSelectableText.rich(
                        _generateSpan(i),
                        key: PageStorageKey<String>(
                            '${_collect.verses[i].getShortName()}_1'),
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 15,
                          textBaseline: TextBaseline.ideographic,
                        ),
                        items: [
                          CustomSelectableTextItem.icon(
                            icon: const Icon(Icons.select_all),
                            controlType: SelectionControlType.selectAll,
                          ),
                          CustomSelectableTextItem.icon(
                              icon: const Icon(Icons.format_underline),
                              onPressed: (start, end) {
                                // String str = List.generate(_verseList[i].length, (index) => _verseList[i][index]["ZVERSE_CONTENT"].trim()).join(" ");
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                        title: const Text('색상 지정'),
                                        content: SizedBox(
                                          width: 300,
                                          height: 80,
                                          child: GridView.count(
                                            crossAxisCount: 5,
                                            children: [
                                              for (var color in _colors)
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.circle,
                                                    size: 32,
                                                    color: HexColor('#$color'),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() => _collect
                                                        .verses[i]
                                                        .highlight("#88$color",
                                                            start, end));
                                                  },
                                                )
                                            ],
                                          ),
                                        )));
                              }),
                          CustomSelectableTextItem.icon(
                              icon: const Icon(Icons.format_clear),
                              onPressed: (start, end) {
                                // String str = List.generate(_verseList[i].length, (index) => _verseList[i][index]["ZVERSE_CONTENT"].trim()).join(" ");
                                setState(() {
                                  _collect.verses[i]
                                      .highlight("#00ff00", start, end, true);
                                });
                              })
                        ],
                      ),
                    )
                  ],
                  onExpansionChanged: (newState) {
                    _expansion[i] = newState;
                  },
                ),
              ),
            ),
            itemCount: _verseList.length,
            onReorder: (oldIdx, newIdx) {
              setState(
                () {
                  if (oldIdx < newIdx) newIdx -= 1;
                  _collect.verses
                      .insert(newIdx, _collect.verses.removeAt(oldIdx));
                  _verseList.insert(newIdx, _verseList.removeAt(oldIdx));
                },
              );
            },
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 0,
                color: Colors.transparent,
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}
