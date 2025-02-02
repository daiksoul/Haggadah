import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:haggah/bible/struct.dart';
import 'package:haggah/data/firebase.dart';
import 'package:haggah/data/localfile.dart';
import 'package:haggah/data/resolve.dart';
import 'package:haggah/util/button_widgets.dart';
import 'package:haggah/util/theme.dart';
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
        builder: (context, state, _) {
          return SpeedDial(
            elevation: 1,
            icon: Icons.add,
            children: [
              labeledSpeedDialChild(context,
                  label: '새 보관함',
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context)
                        .floatingActionButtonTheme
                        .foregroundColor,
                  ), onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      final _controller = TextEditingController();
                      final _formKey = GlobalKey<FormState>();
                      return AlertDialog(
                        title: const Text("보관함 생성하기"),
                        content: Form(
                          key: _formKey,
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: "보관함 이름"),
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
                            style: Theme.of(context).textButtonTheme.style,
                            child: const Text("취소"),
                          ),
                          Consumer<AppStorageState>(
                            builder: (context, state, _) {
                              return TextButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.pop(context);
                                    state.add(
                                        context,
                                        VerseCollection.empty(
                                            title: _controller.text));
                                  }
                                },
                                style: Theme.of(context).textButtonTheme.style,
                                child: const Text("생성"),
                              );
                            },
                          ),
                        ],
                      );
                    });
              }),
              labeledSpeedDialChild(context,
                  label: '가져오기',
                  icon: Icon(
                    Icons.download,
                    color: Theme.of(context)
                        .floatingActionButtonTheme
                        .foregroundColor,
                  ), onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      final _controller = TextEditingController();
                      final _formKey = GlobalKey<FormState>();
                      return AlertDialog(
                        title: const Text("보관함 가져오기"),
                        content: Form(
                          key: _formKey,
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: "공유 코드"),
                            controller: _controller,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "코드를 입력해야 합니다.";
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
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    FirebaseFirestore.instance
                                        .collection("share_collection")
                                        .doc(_controller.text)
                                        .snapshots()
                                        .listen((event) {
                                      if (event.exists) {
                                        final collection =
                                            VerseCollection.fromJson(
                                                event.data()!);
                                        // print(collection.title);
                                        state.add(context, collection);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text("일치하는 보관함을 찾지 못하였습니다."),
                                          duration: Duration(milliseconds: 500),
                                        ));
                                      }
                                      Navigator.pop(context);
                                    });
                                  }
                                },
                                child: const Text("가져오기"),
                              );
                            },
                          ),
                        ],
                      );
                    });
              }),
            ],
          );
        },
      ),
      body: Stack(
        children: [
          Consumer<AppStorageState>(
            builder: (context, state, _) {
              return GridView(
                padding: const EdgeInsets.all(5),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                children: [
                  ...List.generate(
                    state.collection.length,
                    (index) => genCard(
                      context,
                      state.collection[index],
                      index.isOdd,
                    ),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget genCard(BuildContext context, VerseCollection collection, bool od) {
  final isLightMode = Theme.of(context).brightness == Brightness.light;
  return InkWell(
    onTap: () {
      Navigator.pushNamed(context, "/card", arguments: collection);
    },
    child: Card(
      color: (isLightMode ? odEvColor : dOdEvColor)[od ? 100 : 200],
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
                child: Column(
                  children: [
                    Text(
                      collection.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Divider(
                      height: 10,
                      thickness: 1,
                      color: isLightMode ? odEvColor[300] : dOdEvColor[300],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "${collection.verses.getRange(0, (collection.verses.length > 3) ? 3 : collection.verses.length).map((e) => e.getShortName()).join("\n")}${(collection.verses.length > 3) ? "\n..." : ""}",
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                left: 0,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    labeledIconButton(
                      icon: const Icon(Icons.share),
                      text: const Text("공유"),
                      onPressed: () async {
                        final dat = collection.toJson();
                        dat.remove("uid");
                        final doc = await FirebaseFirestore.instance
                            .collection("share_collection")
                            .add(dat);
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text("공유하기"),
                                  content: SelectableText(doc.id),
                                  actions: [
                                    TextButton(
                                      style: Theme.of(context)
                                          .textButtonTheme
                                          .style,
                                      child: const Text("복사"),
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: doc.id));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text("클립보드에 복사되었습니다."),
                                          duration: Duration(milliseconds: 500),
                                        ));
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("확인"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                ));
                      },
                    ),
                    // labeledIconButton(
                    //   icon: const Icon(Icons.edit),
                    //   text: const Text("수정"),
                    //   onPressed: () {},
                    // ),
                    Consumer<AppStorageState>(
                      builder: (context, state, _) {
                        return labeledIconButton(
                          icon: const Icon(Icons.delete),
                          text: const Text("삭제"),
                          onPressed: () {
                            state.remove(context, collection);
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
    ),
  );
}

Widget labeledIconButton({
  required Widget icon,
  required Text text,
  required void Function()? onPressed,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 20,
        height: 20,
        child: IconButton(
          icon: icon,
          onPressed: onPressed,
          iconSize: 20,
          padding: EdgeInsets.zero,
        ),
      ),
      text
    ],
  );
}

class AppStorageState extends ChangeNotifier {
  final List<VerseCollection> _collections = [];

  List<VerseCollection> get collection => List.of(_collections);

  void add(BuildContext context, VerseCollection collection) {
    if (_collections.where((e) => e.uid == collection.uid).isNotEmpty) {
      update(context, collection);
    } else {
      _collections.add(collection);
      resolveWrite(context, collection);
      notifyListeners();
    }
  }

  void remove(BuildContext context, VerseCollection collection) {
    _collections.removeWhere((element) => element.uid == collection.uid);
    resolveDelete(context, collection);
    notifyListeners();
  }

  void update(BuildContext context, VerseCollection collection) {
    _collections[_collections
        .indexWhere((element) => element.uid == collection.uid)] = collection;
    resolveWrite(context, collection);
    notifyListeners();
  }

  void update2(bool signedIn, VerseCollection collection) {
    _collections[_collections
        .indexWhere((element) => element.uid == collection.uid)] = collection;
    if (signedIn) {
      writeRemoteCollection(collection);
    } else {
      writeLocalCollection(collection);
    }
    notifyListeners();
  }
}
