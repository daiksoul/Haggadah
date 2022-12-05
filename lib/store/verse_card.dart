import 'package:flutter/material.dart';
import 'package:haggah/bible/verse.dart';
import 'package:haggah/main.dart';
import 'package:haggah/store/storage.dart';
import 'package:provider/provider.dart';

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
                children: const [SizedBox(height: 10,),Icon(Icons.checklist)],
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
            ListTile(
              tileColor: i.isOdd ? Colors.lightGreen.shade50 : Colors.white,
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
              key: Key('$i'),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _collect.verses[i].getShortName(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  for (Map map in _verseList[i]) ...[
                    Text("${map["ZVERSE_NUMBER"]} ${map["ZVERSE_CONTENT"]}"
                        .trim()),
                    const SizedBox(
                      height: 5,
                    )
                  ]
                ],
              ),
            ),
        ],
      ),
    );
  }
}
