import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class HomePage extends StatefulWidget{
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
          const SizedBox(height: 20,),
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
                        icon: Image.asset("assets/icons/bible.png",),
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
                const SizedBox(height: 30,),
                const Divider(
                  thickness: 2,
                ),
                const SizedBox(height: 30,),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      IconButton(
                        iconSize: 100,
                        icon: Image.asset("assets/icons/storage.png",),
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
          SpeedDialChild(
            elevation: 1.0,
            label: '설정',
            child: IconButton(
              icon: const Icon(
                Icons.settings
              ),
              onPressed: (){
                speedDialOpen.value = false;
                Navigator.pushNamed(context, '/settings');
              },
            )
          ),
          SpeedDialChild(
            elevation: 1.0,
            label: '프로필',
            child: IconButton(
              icon: const Icon(
                Icons.person
              ),
              onPressed: (){
                speedDialOpen.value = false;
                Navigator.pushNamed(context, "/login");
              },
            )
          )
        ],
      ),
    );
  }
}
