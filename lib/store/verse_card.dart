import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:haggah/audio/tts.dart';
import 'package:haggah/bible/dat.dart';
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

class VerseCardState extends State<VerseCardPage> with WidgetsBindingObserver {
  late VerseCollection _collect;
  late AppStorageState _stor;
  late ApplicationState _app;
  late TtsState? _tts;
  late AppSettingState _sett;

  final List<List> _verseList = [];

  // bool _cExpaneded = false;

  // final List<ExpansibleController> _expControllers = [];

  final _menuController = MenuController();

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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _stor = Provider.of<AppStorageState>(context, listen: false);
    _app = Provider.of<ApplicationState>(context, listen: false);
    _tts = Provider.of<TtsState>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _sett = Provider.of<AppSettingState>(context, listen: false);
        _collect =
            ModalRoute.of(context)!.settings.arguments as VerseCollection;
        _verseList.clear();
        _verseList.addAll(
          List.generate(_collect.verses.length, (index) => []),
        );

        await Future.wait([
          for (int j = 0; j < _collect.verses.length; j++)
            _collect.verses[j].getAllVerses().then(
              (val) {
                _verseList[j] = val;
                setState(() {});
              },
            )
        ]);
        _tts?.setTexts(getTTSString());
      },
    );
  }

  void _addNewVerses(List<MultiVerse> mVerses) async {
    _tts?.audioHandler.stop();

    final startIdx = _collect.verses.length;
    final endIdx = startIdx + mVerses.length;

    _collect.verses.addAll(mVerses);

    _verseList.addAll(List.generate(mVerses.length, (_) => []));

    await Future.wait([
      for (int j = startIdx; j < endIdx; j++)
        _collect.verses[j].getAllVerses().then(
            (val) {
              _verseList[j] = val;
              setState(() {});
            }
        )
    ]);

    _tts?.setTexts(getTTSString());
  }

  TextSpan _generateSpan(int index) {
    var mulVerse = _collect.verses[index];
    var text = List.generate(
      _verseList[index].length,
      (index2) => parseVerseData(
        _verseList[index][index2]["ZVERSE_CONTENT"].toString(),
        chimrye: _sett.chimrye,
        haggah: _sett.haggah,
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

  List<String> getTTSString() {
    final lst = <String>[];
    for (int i = 0; i < _collect.verses.length; i++) {
      lst.add(_collect.verses[i].getName() +
          List.generate(
            _verseList[i].length,
            (j) => parseVerseDataMin(
                _verseList[i][j]["ZVERSE_CONTENT"].toString(),
              chimrye: _sett.chimrye,
              haggah: _sett.haggah,
            ),
          ).join('\n'));
    }
    return lst;
  }

  @override
  Widget build(BuildContext context) {
    _collect = ModalRoute.of(context)!.settings.arguments as VerseCollection;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return PopScope(
      onPopInvokedWithResult: (val, _) {
        _menuController.close();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_collect.title),
          actions: [
            MenuAnchor(
              controller: _menuController,
              builder: (_, controller, __) =>
                  IconButton(onPressed: () {
                    if(controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                    },
                    icon: const Icon(Icons.more_horiz),
                  ),
                menuChildren: [
                  PopupTile(
                    onPressed: () {
                      _menuController.close();
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
                    leading: Icons.edit,
                    text: '이름 변경하기',
                  ),
                  PopupTile(
                    onPressed: () async {
                      final newVerses = await showDialog<List<MultiVerse>>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Dialog(
                          insetPadding: EdgeInsets.all(10), 
                          constraints: BoxConstraints( maxHeight: 400), 
                          child: AddressModal(verseCollection: _collect,),
                        ),
                      );
                      _addNewVerses(newVerses??[]);
                    },
                    leading: Icons.add,
                    text: '말씀 추가하기',
                  ),
                  menuDivider(),
                  StreamBuilder<PlaybackState>(
                    stream: _tts?.audioHandler.playbackState,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing == true;
                      return PopupTile(
                        onPressed: () {
                          if (!playing) {
                            _tts?.audioHandler.play();
                          } else {
                            _tts?.audioHandler.pause();
                          }
                        },
                        leading: !playing ? Icons.play_circle_outline : Icons.stop_circle_outlined,
                        text: !playing ? '보관함 재생' : '보관함 정지',
                      );
                    },
                  ),
                  menuDivider(),
                  PopupTile(
                    onPressed: () {
                      _menuController.close();
                      Navigator.pushNamed(context, "/practice", arguments: _collect);
                    },
                    leading: Icons.fact_check_outlined,
                    text: '수동 검사',
                  ),
                  PopupTile(
                    onPressed: () {
                      _menuController.close();
                      Navigator.pushNamed(context, "/test", arguments: _collect);
                    },
                    leading: Icons.multitrack_audio,
                    text: '자동 검사',
                  ),
                ],
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context, _collect);
            },
          ),
        ),
        body: SafeArea(
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              expansionTileTheme: const ExpansionTileThemeData(
                shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                ),
                collapsedShape: RoundedRectangleBorder(
                  side: BorderSide.none,
                ),
              ),
            ),
            child: ReorderableListView.builder(
              itemBuilder: (context, i) => Padding(
                key: PageStorageKey('$i'),
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
                      width: 1,
                    ),
                  ),
                  child: ExpansionTile(
                    key: ValueKey(i),
                    initiallyExpanded: _sett.expandByDefault,
                    controlAffinity: ListTileControlAffinity.leading,
                    // controller: _expControllers[i],
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_circle_outline),
                          onPressed: () {
                            _tts?.audioHandler.skipToQueueItem(i);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              final removed = _collect.verses.removeAt(i);
                              final removedId = i;
                              final removedT = _verseList.removeAt(i);
                              final controller = ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
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
                                ),
                              );
                              Future.delayed(const Duration(seconds: 1), () => controller.close());
                            });
                          },
                        ),
                      ],
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
                              '${i}_1'),
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
      ),
    );
  }

  Widget menuDivider() {
    return Divider(color: Theme.of(context).brightness == Brightness.light ? mainColor[200] : dMainColor[200]);
  }
}

class PopupTile extends StatelessWidget {
  final void Function()? onPressed;
  final IconData leading;
  final String text;
  const PopupTile({super.key, this.onPressed, required this.leading, required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Row(
          children: [
            Icon(
              leading,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 15
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddressModalController extends ChangeNotifier {
  final _multiVerseList = <MultiVerse>[];
  List<MultiVerse> get multiVerseList => [..._multiVerseList];

  void addMultiVerse(MultiVerse mVerse) {
    _multiVerseList.add(mVerse);
    notifyListeners();
  }

  void removeMultiVerse(MultiVerse mVerse) {
    _multiVerseList.remove(mVerse);
    notifyListeners();
  }

  void clearMultiVerse() {
    _multiVerseList.clear();
    notifyListeners();
  }
}

class AddressMaker extends StatefulWidget {
  const AddressMaker({super.key});

  @override
  State<AddressMaker> createState() => _AddressMakerState();
}

class _AddressMakerState extends State<AddressMaker> {
  var _valid = true;

  var book = Book.gen;
  var chapter = 1;
  var textController = TextEditingController();
  final filterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dropdownMenuTheme: const DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationThemeData(
            contentPadding: EdgeInsets.all(5),
            visualDensity: VisualDensity.compact,
          ),
          menuStyle: MenuStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.all(0))
          ),
        ),
        menuTheme: const MenuThemeData(
          style: MenuStyle(
            side: WidgetStatePropertyAll(BorderSide(color: Colors.transparent)),
          )
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60,
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: DropdownMenu<Book>(
                    controller: filterController,
                    initialSelection: book,
                    requestFocusOnTap: true,
                    showTrailingIcon: false,
                    menuHeight: 200,
                    menuStyle: MenuStyle(
                      visualDensity: VisualDensity.compact,
                      padding: WidgetStatePropertyAll(EdgeInsets.zero)
                    ),
                    onSelected: (v) {
                      setState(() {
                        book = v ?? Book.gen;
                      });
                    },
                    // enableSearch: true,
                    enableFilter: true,
                    // searchCallback: (entries, query) => entries.indexWhere((e) => e.value.korAb == query),
                    filterCallback: (entries, query) => Book.values.where((e) => e.korAb.contains(query)).map((e) => DropdownMenuEntry(value: e, label: e.korAb)).toList(),
                    dropdownMenuEntries: List.generate(
                      Book.values.length,
                      (idx) {
                        final cBook = Book.values[idx];
                        return DropdownMenuEntry(
                          value: cBook,
                          label: cBook.korAb,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 60,
                  child: DropdownMenu<int>(
                    initialSelection: chapter,
                    menuHeight: 200,
                    showTrailingIcon: false,
                    menuStyle: MenuStyle(
                        visualDensity: VisualDensity.compact,
                        padding: WidgetStatePropertyAll(EdgeInsets.zero)
                    ),
                    onSelected: (v) {
                      setState(() {
                        chapter = v ?? 1;
                      });
                    },
                    dropdownMenuEntries: List.generate(
                      book.chapters,
                      (idx) => DropdownMenuEntry(value: (idx + 1), label: '${idx + 1}'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero
                    ),
                    controller: textController,
                  ),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  height: 48,
                  child: Consumer<AddressModalController>(
                    builder: (context, controller, _) {
                      return ElevatedButton(
                        onPressed: () async {
                          _valid = await validateAddress(book, chapter, textController.text);
                          setState(() {});
                          if (!_valid) return;

                          final multiVerse = MultiVerse(stringToNumberArray(textController.text).map((e) => Verse(book: book, chapter: chapter, verse: e)).toList());
                          controller.addMultiVerse(multiVerse);
                        },
                        child: const Text(
                          "추가", style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
          if (!_valid)
            const Text("잘못된 주소입니다", style: TextStyle(color: Colors.redAccent),)
        ],
      ),
    );
  }
}

class AddressModal extends StatefulWidget {
  const AddressModal({super.key, required this.verseCollection});
  final VerseCollection verseCollection;

  @override
  State<AddressModal> createState() => _AddressModalState();
}

class _AddressModalState extends State<AddressModal> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddressModalController>(
      create: (context) => AddressModalController(),
      child: Material(
          child: Center(
            widthFactor: 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '말씀 일괄 추가',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Consumer<AddressModalController>(
                      builder: (context, controller, __) {
                        return ListView(
                          children: [
                            for (final element in controller.multiVerseList)
                              SizedBox(
                                height: 45,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(element.getShortName(), style: TextStyle(fontSize: 16),),
                                    IconButton(onPressed: () => controller.removeMultiVerse(element) , icon: Icon(Icons.delete_outline))
                                  ],
                                ),
                              ),
                            AddressMaker(),
                          ],
                        );
                      }
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () {
                        Navigator.of(context).pop(<MultiVerse>[]);
                      }, child: const Text("취소")),
                      Consumer3<AppStorageState,ApplicationState, AddressModalController>(
                        builder: (context, storage, app, address, _) {
                          return TextButton(onPressed: (){
                            // widget.verseCollection.verses.addAll(address.multiVerseList);
                            // storage.update2(app.isSignedIn, widget.verseCollection);
                            Navigator.of(context).pop(address.multiVerseList);
                          }, child: const Text("확인"));
                        }
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
