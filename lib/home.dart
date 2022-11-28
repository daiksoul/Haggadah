import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          const Align(
            alignment: Alignment.center,
            child: Text("하가다"),
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.person
        ),
        onPressed: (){

        },
      ),
    );
  }
}
