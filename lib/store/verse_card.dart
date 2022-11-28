import 'package:flutter/material.dart';
import 'package:haggah/bible/verse.dart';
import 'package:haggah/data/localfile.dart';

class VerseCardPage extends StatefulWidget {
  const VerseCardPage({super.key});

  @override
  State<StatefulWidget> createState() => VerseCardState();
}

class VerseCardState extends State<VerseCardPage> {
  late VerseCollection _collect;

  final List<List> _verseList = [];

  @override
  void dispose(){
    super.dispose();
    Future.delayed(
      Duration.zero,
          (){
        writeLocalCollection(_collect).then(
          (file){
            print(file.toString());
          }
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
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
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.pushNamed(context, "/practice", arguments: _collect);
            },
          )
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ReorderableListView(
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            _collect.verses.insert(newIndex, _collect.verses.removeAt(oldIndex));
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
                  const SizedBox(height: 10,),
                  for (Map map in _verseList[i]) ...[
                    Text("${map["ZVERSE_NUMBER"]} ${map["ZVERSE_CONTENT"]}"
                        .trim()),
                    const SizedBox(height: 5,)
                  ]
                ],
              ),
            ),
        ],
      ),
    );
  }
}
