import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haggah/bible/dat.dart';
import 'package:haggah/bible/struct.dart';
import 'package:haggah/data/localfile.dart';
import 'package:haggah/data/resolve.dart';
import 'package:haggah/store/storage.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getDB() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, 'bible/bible.db');
  var exists = await databaseExists(path);

  if (!exists) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    var data = await rootBundle.load(join('assets', 'bible.sqlite3'));
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    await File(path).writeAsBytes(bytes, flush: true);
  }

  return await openDatabase(path);
}

class VersePage extends StatefulWidget {
  const VersePage({super.key});

  @override
  State<StatefulWidget> createState() => VerseState();
}

class VerseState extends State<VersePage> {
  bool _selectMode = false;
  final List<Map> _verses = [];
  late BookNChap bookNChap;

  Future<List<Map<String, Object?>>> _getVerses(BookNChap bNC) async {
    var db = await getDB();

    return await db.rawQuery(
        "SELECT * FROM ZVERSE WHERE ZTOCHAPTER = (SELECT Z_PK FROM ZCHAPTER WHERE ZCHAPTER_NUMBER = ${bNC.chapter} AND ZTOBOOK = (SELECT Z_PK FROM ZBOOK WHERE ZBOOK_INDEX=${bNC.book.index + 1})) ORDER BY ZVERSE_NUMBER");
  }

  void _exitSelectMode() {
    _selectMode = false;
    for (int i = 0; i < _verses.length; i++) {
      _verses[i].update("selected", (_) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () {
        _verses.clear();
        bookNChap =
            ModalRoute.of(this.context)!.settings.arguments as BookNChap;
        _getVerses(bookNChap).then(
          (map) {
            _verses.addAll(map.map((e) => Map.of(e)));
            for (int i = 0; i < _verses.length; i++) {
              _verses[i].putIfAbsent("selected", () => false);
            }
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookNChap = ModalRoute.of(context)!.settings.arguments as BookNChap;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${bookNChap.book.kor} ${bookNChap.chapter}???",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        leading: (_selectMode)
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _exitSelectMode();
                  });
                })
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  Navigator.popUntil(context, (route) {
                    return route.settings.name == "/chapters";
                  });
                },
              ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: (_selectMode)
            ? MainAxisAlignment.spaceAround
            : MainAxisAlignment.spaceBetween,
        children: [
          if (!_selectMode) ...[
            (!(bookNChap.book == Book.gen && bookNChap.chapter == 1))
                ? IconButton(
                    icon: const Icon(Icons.navigate_before),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        _animateRoute(
                            (bookNChap.chapter == 1)
                                ? BookNChap(
                                    Book.values.elementAt(
                                        Book.values.indexOf(bookNChap.book) -
                                            1),
                                    Book.values
                                        .elementAt(Book.values
                                                .indexOf(bookNChap.book) -
                                            1)
                                        .chapters)
                                : BookNChap(
                                    bookNChap.book, bookNChap.chapter - 1),
                            true),

                      );
                    },
                  )
                : IconButton(
                    onPressed: () {},
                    icon: const SizedBox(
                      height: 0,
                    ),
                  ),
            (!(bookNChap.book == Book.rev &&
                    bookNChap.chapter == Book.rev.chapters))
                ? IconButton(
                    icon: const Icon(Icons.navigate_next),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          _animateRoute(
                              (bookNChap.chapter == bookNChap.book.chapters)
                                  ? BookNChap(
                                      Book.values.elementAt(
                                          Book.values.indexOf(bookNChap.book) +
                                              1),
                                      1)
                                  : BookNChap(
                                      bookNChap.book, bookNChap.chapter + 1),
                              false));
                    },
                  )
                : IconButton(
                    onPressed: () {},
                    icon: const SizedBox(
                      height: 0,
                    ),
                  )
          ] else ...[
            IconButton(
              icon: const Icon(
                Icons.copy,
              ),
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("??????????????? ?????????????????????."),
                  duration: Duration(milliseconds: 500),
                ));
                await Clipboard.setData(ClipboardData(
                    text: _verses
                        .where((element) => element["selected"])
                        .map((e) =>
                            "${e["ZVERSE_NUMBER"]} ${e["ZVERSE_CONTENT"]}")
                        .join("")));
              },
            ),
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Consumer<AppStorageState>(
                      builder: (context, state, _) {
                        return ListView(
                          children: [
                            ...List.generate(
                              state.collection.length,
                              (index) => ListTile(
                                leading: const Icon(
                                  Icons.remove,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (con) {
                                        return AlertDialog(
                                          title: Text(
                                              "????????? ${state.collection[index].title}???(???) ?????????????????????????"),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              style: Theme.of(context).textButtonTheme.style,
                                              child: const Text("??????"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                state.remove(context,state.collection[index]);
                                              },
                                              style: Theme.of(context).textButtonTheme.style,
                                              child: const Text("??????"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                title: Text(state.collection[index].title),
                                onTap: () {
                                  VerseCollection vc = state.collection[index];
                                  vc.verses.add(
                                    MultiVerse(
                                      _verses
                                          .where(
                                              (element) => element["selected"])
                                          .map((e) => Verse(
                                              book: bookNChap.book,
                                              chapter: bookNChap.chapter,
                                              verse: e["ZVERSE_NUMBER"] as int))
                                          .toList(),
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("????????? ${vc.title}??? ?????????????????????"),
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  );
                                  resolveWrite(context,state.collection[index]);
                                  Navigator.pop(context);
                                  setState(
                                    () {
                                      _exitSelectMode();
                                    },
                                  );
                                },
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.add),
                              title: const Text("????????? ???????????????"),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    final controller = TextEditingController();
                                    final formKey = GlobalKey<FormState>();
                                    return AlertDialog(
                                      title: const Text("????????? ?????????"),
                                      content: Form(
                                        key: formKey,
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: "????????? ??????"
                                          ),
                                          controller: controller,
                                          validator: (val) {
                                            if (val == null || val.isEmpty) {
                                              return "????????? ???????????? ?????????.";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("??????"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              Navigator.pop(context);
                                              state.add(context,VerseCollection.empty(title: controller.text));
                                            }
                                          },
                                          child: const Text("??????"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            )
          ]
        ],
      ),
      body: ListView(
        children: [
          ...List.generate(
            _verses.length,
            (index) => ListTile(
              onLongPress: () {
                if (!_selectMode) {
                  setState(
                    () {
                      _selectMode = true;
                      _verses[index].update("selected", (_) => true);
                    },
                  );
                }
              },
              onTap: () {
                if (_selectMode) {
                  setState(
                    () {
                      _verses[index].update(
                        "selected",
                        (value) =>
                            !((_verses[index]["selected"] ?? false) as bool),
                      );
                    },
                  );
                }
              },
              leading: Text(
                _verses[index]["ZVERSE_NUMBER"].toString(),
                // content[index]["verse"].toString(),
                style: TextStyle(color: Colors.green.shade600),
              ),
              title: Text(_verses[index]["ZVERSE_CONTENT"].toString().trim()),
              // title: Text(content[index]["content"].toString()),
              selected: (_verses[index]["selected"] ?? false) as bool,
              selectedColor: Colors.black,
              selectedTileColor: Colors.lightGreen.shade100,
            ),
          ),
        ],
      ),
    );
  }
}

Route _animateRoute(Object? arg, bool forward) {
  return PageRouteBuilder(
    settings: RouteSettings(name: "/verses", arguments: arg),
    pageBuilder: (context, animation, _) => const VersePage(),
    transitionsBuilder: (context, animation, secondary, child) {
      final begin = Offset((forward) ? -1.0 : 1.0, 0);
      const end = Offset.zero;
      const curve = Curves.linear;

      var tween = Tween(begin: begin, end: end);
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: curve,
      );

      return SlideTransition(
        position: tween.animate(curvedAnimation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: Offset((forward) ? 1.0 : -1.0, 0),
          ).animate(secondary),
          child: child,
        ),
      );
    },
  );
}