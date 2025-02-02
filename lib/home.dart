import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(
            height: 50,
          ),
          SvgPicture.asset(
            "assets/logo.svg",
            height: 200,
            color: isLightMode ? Colors.black : Colors.white,
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
                        icon: SvgPicture.asset(
                          "assets/icons/bible.svg",
                          width: 75,
                          height: 75,
                          color: isLightMode ? Colors.black : Colors.white,
                        ),
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
                const SizedBox(height: 30),
                Divider(thickness: 2),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      IconButton(
                        iconSize: 100,
                        icon: SvgPicture.asset(
                          "assets/icons/storage.svg",
                          width: 75,
                          height: 75,
                          color: isLightMode ? Colors.black : Colors.white,
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
          labeledSpeedDialChild(
            context,
            label: '설정',
            icon: Icon(
              Icons.settings,
              color:
                  Theme.of(context).floatingActionButtonTheme.foregroundColor,
            ),
            onTap: () {
              speedDialOpen.value = false;
              Navigator.pushNamed(context, '/settings');
            },
          ),
          labeledSpeedDialChild(
            context,
            label: '프로필',
            icon: Icon(
              Icons.person,
              color:
                  Theme.of(context).floatingActionButtonTheme.foregroundColor,
            ),
            onTap: () {
              speedDialOpen.value = false;
              Navigator.pushNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }
}
