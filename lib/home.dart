import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:haggah/util/button_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomePage> {
  final speedDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(
            height: 50,
          ),
          Image.asset(
            "assets/logo.png",
            height: 200,
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      IconButton(
                        iconSize: 100,
                        icon: Image.asset(
                          "assets/icons/bible.png",
                          width: 100,
                          height: 100,
                        ),
                        color: Colors.black,
                        onPressed: () {
                          Navigator.pushNamed(context, "/books");
                        },
                      ),
                      const Text(
                        "성경",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Divider(
                  thickness: 2,
                  color: Colors.black,
                ),
                const SizedBox(
                  height: 30,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      IconButton(
                        iconSize: 100,
                        icon: Image.asset(
                          "assets/icons/storage.png",
                          width: 100,
                          height: 100,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/collections');
                        },
                      ),
                      const Text(
                        "말씀 보관함",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
      floatingActionButton: SpeedDial(
        openCloseDial: speedDialOpen,
        elevation: 1.0,
        icon: Icons.menu,
        children: [
          LabeledSpeedDialChild(
              label: '설정',
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).floatingActionButtonTheme.focusColor,
              ),
              onTap: () {
                speedDialOpen.value = false;
                Navigator.pushNamed(context, '/settings');
              },
              backgroundColor:
                  Theme.of(context).floatingActionButtonTheme.backgroundColor),
          // SpeedDialChild(
          //   elevation: 1.0,
          //   label: '설정',
          //   labelWidget: Container(
          //     height: 50,
          //     decoration: BoxDecoration(
          //       // color: Colors.white,
          //         color: Theme.of(context).floatingActionButtonTheme.backgroundColor,
          //         borderRadius: BorderRadius.circular(30)
          //     ),
          //     child: Row(
          //       children: [
          //         Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: 12),
          //           child: Text('설정',
          //             style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 color: Theme.of(context).floatingActionButtonTheme.focusColor
          //             ),
          //           ),
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.only(right: 12),
          //           child: Icon(
          //             Icons.settings,
          //             color: Theme.of(context).floatingActionButtonTheme.focusColor,
          //           ),
          //         )
          //       ],
          //     ),
          //   ),
          //   onTap: (){
          //     speedDialOpen.value = false;
          //     Navigator.pushNamed(context, '/settings');
          //   },
          // ),
          LabeledSpeedDialChild(
              label: '프로필',
              icon: Icon(
                Icons.person,
                color: Theme.of(context).floatingActionButtonTheme.focusColor,
              ),
              onTap: () {
                speedDialOpen.value = false;
                Navigator.pushNamed(context, "/login");
              },
              backgroundColor:
                  Theme.of(context).floatingActionButtonTheme.backgroundColor),
          // SpeedDialChild(
          //   elevation: 1.0,
          //   labelWidget: Container(
          //     height: 50,
          //     decoration: BoxDecoration(
          //       // color: Colors.white,
          //         color: Theme.of(context).floatingActionButtonTheme.backgroundColor,
          //         borderRadius: BorderRadius.circular(30)
          //     ),
          //     child: Row(
          //       children: [
          //         Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: 12),
          //           child: Text('프로필',
          //             style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 color: Theme.of(context).floatingActionButtonTheme.focusColor
          //             ),
          //           ),
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.only(right: 12),
          //           child: Icon(
          //             Icons.person,
          //             color: Theme.of(context).floatingActionButtonTheme.focusColor,
          //           ),
          //         )
          //       ],
          //     ),
          //   ),
          //   onTap: (){
          //     speedDialOpen.value = false;
          //     Navigator.pushNamed(context, "/login");
          //   }
          // )
        ],
      ),
    );
  }
}
