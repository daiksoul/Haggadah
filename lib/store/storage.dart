import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:haggah/bible/dat.dart';
import 'package:haggah/bible/verse.dart';
import 'package:haggah/data/localfile.dart';
import 'package:provider/provider.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StatefulWidget> createState() => StorageState();
}

class StorageState extends State<StoragePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("말씀 보관함"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: Consumer<AppStorageState>(
        builder: (context, state, _){
          return FloatingActionButton(
            child: const Icon(
                Icons.add
            ),
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final _controller = TextEditingController();
                    final _formKey = GlobalKey<FormState>();
                    return AlertDialog(
                      title: const Text("보관함 이름"),
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _controller,
                          validator: (val){
                            if(val==null||val.isEmpty){
                              return "이름을 입력해야 합니다.";
                            }
                            return null;
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text("취소"),
                        ),
                        TextButton(
                          onPressed: () {
                            if(_formKey.currentState!.validate()){
                              Navigator.pop(context);
                              state.add(
                                  VerseCollection.empty(
                                      title: _controller.text
                                  )
                              );
                            }
                          },
                          child: const Text("생성"),
                        ),
                      ],
                    );
                  }
              );
            },
          );
        },
      ),
      body: Consumer<AppStorageState>(
        builder: (context, state, _) {
          return GridView(
            padding: const EdgeInsets.all(5),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            children: [
              ...List.generate(state.collection.length,
                  (index) => genCard(context, state.collection[index]))
            ],
          );
        },
      ),
    );
  }
}

Card genCard(BuildContext context, VerseCollection collection) {
  return Card(
    shadowColor: Colors.transparent,
    child: AspectRatio(
      aspectRatio: 3 / 4,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              left: 0,
              child: InkWell(
                onTap: (){
                  Navigator.pushNamed(
                    context,
                    "/card",
                    arguments: collection
                  );
                },
                child: Column(
                  children: [
                    Text(
                      collection.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const Divider(
                      height: 10,
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "${collection.verses.getRange(0, (collection.verses.length > 3) ? 3 : collection.verses.length).map((e) => e.getShortName()).join("\n")}${(collection.verses.length > 3) ? "\n..." : ""}",
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  labeledIconButton(
                    icon: const Icon(Icons.share),
                    text: const Text("공유"),
                    onPressed: () {},
                  ),
                  // labeledIconButton(
                  //   icon: const Icon(Icons.edit),
                  //   text: const Text("수정"),
                  //   onPressed: () {},
                  // ),
                  Consumer<AppStorageState>(
                    builder: (context,state,_){
                      return labeledIconButton(
                        icon: const Icon(Icons.delete),
                        text: const Text("삭제"),
                        onPressed: () {
                          deleteLocalCollection(collection);
                          state.remove(collection);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget labeledIconButton({
  required Widget icon,
  required Text text,
  required void Function()? onPressed,
}) {
  return Column(
    children: [
      IconButton(
        icon: icon,
        onPressed: onPressed,
        iconSize: 20,
      ),
      text
    ],
  );
}

class AppStorageState extends ChangeNotifier {
  final List<VerseCollection> _collections = [];

  List<VerseCollection> get collection => List.of(_collections);

  void add(VerseCollection collection) {
    _collections.add(collection);
    writeLocalCollection(collection);
    notifyListeners();
  }

  void remove(VerseCollection collection) {
    _collections.removeWhere((element) => element.uid == collection.uid);
    deleteLocalCollection(collection);
    notifyListeners();
  }

  void update(VerseCollection collection) {
    _collections[_collections
        .indexWhere((element) => element.uid == collection.uid)] = collection;
    writeLocalCollection(collection);
    notifyListeners();
  }
}
