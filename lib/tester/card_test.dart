import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:haggah/bible/verse.dart';

class CardTestPage extends StatefulWidget {
  const CardTestPage({super.key});

  @override
  State<StatefulWidget> createState() => CardTestState();
}

class CardTestState extends State<CardTestPage> with SingleTickerProviderStateMixin {
  Alignment _dragAlgin = Alignment.center;
  late AnimationController _animController;
  late Animation<Alignment> _animation;
  var _currentPage = 0;
  final List<List<Map>> _list = [];
  final List<int> _corct = [];
  final List<int> _wrong = [];
  final List<int> _waitng = [];
  late VerseCollection _collection;
  final _carControl = CarouselController();

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _animController.addListener(() {
      setState(() {
        _dragAlgin = _animation.value;
      });
    });
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    Future.delayed(
      Duration.zero,
          () {
        _collection =
        ModalRoute
            .of(context)!
            .settings
            .arguments as VerseCollection;
        _list.clear();
        _waitng.clear();
        _corct.clear();
        _wrong.clear();

        _list.addAll(List.generate(_collection.verses.length, (index) => []));
        _waitng
            .addAll(List.generate(_collection.verses.length, (index) => index));

        for (int j = 0; j < _list.length; j++) {
          _collection.verses[j].getAllVerses().then((value) {
            _list[j].addAll(value);
            if (j == _list.length - 1) {
              setState(() {});
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
    ]);
    _animController.dispose();
    super.dispose();
  }

  void _animate(Offset offset, Size size) {
    _animation = _animController.drive(
      AlignmentTween(
        begin: _dragAlgin,
        end: Alignment.center,
      ),
    );
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = offset.dx / size.width;
    final unitsPerSecondY = offset.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _animController.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    _collection = ModalRoute
        .of(context)!
        .settings
        .arguments as VerseCollection;
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        shadowColor: Colors.black,
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = MediaQuery
              .of(context)
              .size;
          return GestureDetector(
            // onTap: () {
            //   print("$_currentPage");
            // },
            onPanDown: (detail) {
              if (_dragAlgin.x.abs() < 2) {
                _animController.stop();
              }
            },
            onPanUpdate: (detail) {
              setState(() {
                _dragAlgin += Alignment(detail.delta.dx / 15, 0);
              });
            },
            onPanEnd: (details) {
              _animate(details.velocity.pixelsPerSecond, size);
              setState(() {
                if (_dragAlgin.x < -10) {
                  _wrong.add(_waitng.removeAt(_currentPage));
                  if (_currentPage >= _waitng.length) {
                    _currentPage = _waitng.length - 1;
                  }
                  HapticFeedback.lightImpact();
                } else if (_dragAlgin.x > 10) {
                  _corct.add(_waitng.removeAt(_currentPage));
                  if (_currentPage >= _waitng.length) {
                    _currentPage = _waitng.length - 1;
                  }
                  HapticFeedback.lightImpact();
                }
                _animate(details.velocity.pixelsPerSecond, size);
              });
            },
            child: (_waitng.isNotEmpty)
                ? CarouselSlider(
              items: [
                ...List.generate(
                  _waitng.length,
                      (index) =>
                      Align(
                        alignment: (_currentPage == index)
                            ? _dragAlgin
                            : Alignment.center,
                        // alignment: Alignment.center,
                        child: Transform.rotate(
                          angle: (_currentPage == index)
                              ? _dragAlgin.x * (3.14) * 0.01
                              : 0,
                          // angle: 0,
                          child: Card(
                            color: (_currentPage == index)
                                ? ((_dragAlgin.x < -8)
                                ? Colors.red.shade200
                                : ((_dragAlgin.x > 8)
                                ? Colors.green.shade200
                                : Colors.white))
                                : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Text(
                                      _collection.verses[_waitng[index]]
                                          .getShortName(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 20),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Expanded(
                                      child: ListView(
                                        children: [
                                          for (Map map
                                          in _list[_waitng[index]]) ...[
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  "\t${map["ZVERSE_NUMBER"]} ",
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    (map["ZVERSE_CONTENT"] as String)
                                                        .trim(),
                                                    style: const TextStyle(fontSize: 15),
                                                    // onSelectionChanged: (
                                                    //     selection, reason) {
                                                    //   final str = map["ZVERSE_CONTENT"] as String;
                                                    //   print(str.substring(
                                                    //       selection.start,
                                                    //       selection.end));
                                                    // },
                                                    // toolbarOptions: ToolbarOptions(
                                                    //
                                                    // ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 5,)
                                          ]
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                ),
              ],
              options: CarouselOptions(
                height: constraints.maxHeight,
                viewportFraction: 0.5,
                scrollDirection: Axis.vertical,
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                scrollPhysics: const BouncingScrollPhysics(),
                enlargeStrategy: CenterPageEnlargeStrategy.scale,
                onPageChanged: (t, _) {
                  setState(() {
                    _currentPage = t;
                  });
                },
              ),
            )
                : (_corct.isNotEmpty || _wrong.isNotEmpty)
                ? Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "정답 ${_corct.length}개",
                          style: TextStyle(
                            color: Colors.green.shade300,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              ...List.generate(
                                _corct.length,
                                    (index) =>
                                    Text(
                                      _collection.verses[_corct[index]]
                                          .getShortName(),
                                      style:
                                      const TextStyle(color: Colors.white),
                                    ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(
                    color: Colors.white,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "오답 ${_wrong.length}개",
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              ...List.generate(
                                _wrong.length,
                                    (index) =>
                                    Text(
                                      _collection.verses[_wrong[index]]
                                          .getShortName(),
                                      style:
                                      const TextStyle(color: Colors.white),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox(),
          );
        },
      ),
    );
  }
}