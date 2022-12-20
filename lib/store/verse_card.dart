import 'package:flutter/material.dart';
import 'package:haggah/bible/struct.dart';
import 'package:haggah/bible/verse.dart';
import 'package:haggah/main.dart';
import 'package:haggah/store/storage.dart';
import 'package:provider/provider.dart';
import 'package:custom_selectable_text/custom_selectable_text.dart';

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

  @override
  void dispose() {
    Future.delayed(Duration.zero, () {
      _stor.update2(_app.isSignedIn, _collect);
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _stor = Provider.of<AppStorageState>(context, listen: false);
      _app = Provider.of<ApplicationState>(context, listen: false);
      _collect = ModalRoute.of(context)!.settings.arguments as VerseCollection;
      _expansion = List.generate(_collect.verses.length, (index) => false);
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

  @override
  Widget build(BuildContext context) {
    _collect = ModalRoute.of(context)!.settings.arguments as VerseCollection;
    return Scaffold(
      appBar: AppBar(
        title: Text(_collect.title),
        actions: [
          DropdownButton<int>(
            underline: const SizedBox(),
            alignment: AlignmentDirectional.centerEnd,
            elevation: 1,
            icon: const Text(""),
            hint: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: const [
                  SizedBox(
                    height: 10,
                  ),
                  Icon(Icons.checklist)
                ],
              ),
            ),
            items: [
              DropdownMenuItem(
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
                  )),
              DropdownMenuItem(
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
                  ))
            ],
            onChanged: (value) {
              if (value == 0) {
                Navigator.pushNamed(context, "/practice", arguments: _collect);
              } else {
                Navigator.pushNamed(context, "/test", arguments: _collect);
              }
            },
          ),
          IconButton(
            icon: const Icon(
                Icons.zoom_out_map
            ),
            onPressed: (){
              setState(() {
                for(int i = 0; i<_verseList.length; i++){
                  _expansion[i] = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.edit,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final _controller = TextEditingController();
                    final _formKey = GlobalKey<FormState>();
                    _controller.text = _collect.title;
                    return AlertDialog(
                      title: const Text("이름 변경하기"),
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: "새로운 이름"),
                          controller: _controller,
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
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pop(context);
                                  setState(() {
                                    _collect.title = _controller.text;
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
      body: ReorderableListView(
        proxyDecorator: (child, index, animation) {
          return Material(
            elevation: 0,
            color: Colors.transparent,
            child: child,
          );
        },
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            _collect.verses
                .insert(newIndex, _collect.verses.removeAt(oldIndex));
            _verseList.insert(newIndex, _verseList.removeAt(oldIndex));
          });
        },
        children: [
          for (int i = 0; i < _verseList.length; i++)
            Padding(
              key: PageStorageKey(_collect.verses[i].getShortName()),
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(
                  color: i.isOdd ? Colors.lightGreen.shade50 : Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border:
                      Border.all(color: Colors.lightGreen.shade200, width: 0.5),
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    // key: PageStorageKey<String>('${_collect.verses[i].getShortName()}_1'),
                    initiallyExpanded: _expansion[i],
                    maintainState: true,
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
                          style: const TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                      ),
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
                        // child: Text(
                        //   List.generate(_verseList[i].length, (index) => _verseList[i][index]["ZVERSE_CONTENT"].trim()).join(" "),
                        //   textAlign: TextAlign.start,
                        //   style: const TextStyle(fontSize: 15),
                        // ),
                        child: CustomSelectableText.rich(
                          TextSpan(
                            text: List.generate(_verseList[i].length, (index) => _verseList[i][index]["ZVERSE_CONTENT"].trim()).join(" "),
                          ),
                          key: PageStorageKey<String>('${_collect.verses[i].getShortName()}_1'),
                          textAlign: TextAlign.start,
                          style: const TextStyle(fontSize: 15),
                          items: [
                            CustomSelectableTextItem.icon(
                              icon: const Icon(Icons.select_all),
                              controlType: SelectionControlType.selectAll,
                            ),
                            CustomSelectableTextItem.icon(
                              icon: const Icon(Icons.format_underline),
                              onPressed: (text){
                                _collect.verses[i].comment['123'] = [];
                              }
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // ListTile(
              //   contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              //   shape: RoundedRectangleBorder(side: BorderSide(color: Colors.lightGreen.shade200,width:0.5),borderRadius: const BorderRadius.all(Radius.circular(20))),
              //   tileColor: i.isOdd ? Colors.lightGreen.shade50 : Colors.white,
              //   trailing: IconButton(
              //     icon: const Icon(
              //       Icons.delete_outline,
              //     ),
              //     onPressed: () {
              //       setState(() {
              //         final removed = _collect.verses.removeAt(i);
              //         final removedId = i;
              //         final removedT = _verseList.removeAt(i);
              //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //           content: Text(
              //               "${removed.getShortName()}절을 ${_collect.title}에서 제거하였습니다."),
              //           action: SnackBarAction(
              //             label: "취소",
              //             onPressed: () {
              //               setState(() {
              //                 _collect.verses.insert(removedId, removed);
              //                 _verseList.insert(i, removedT);
              //               });
              //             },
              //           ),
              //         ));
              //       });
              //     },
              //   ),
              //   title: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         _collect.verses[i].getShortName(),
              //         style: const TextStyle(
              //             fontWeight: FontWeight.bold, color: Colors.green),
              //       ),
              //       const SizedBox(
              //         height: 10,
              //       ),
              //       for (Map map in _verseList[i]) ...[
              //         Text("${map["ZVERSE_NUMBER"]} ${map["ZVERSE_CONTENT"]}"
              //             .trim()),
              //         const SizedBox(
              //           height: 5,
              //         )
              //       ]
              //     ],
              //   ),
              // ),
            ),
        ],
      ),
    );
  }
}
