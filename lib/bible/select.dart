import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:haggah/bible/dat.dart';

class BookSelectPage extends StatefulWidget {
  const BookSelectPage({super.key});

  @override
  State<StatefulWidget> createState() => BookSelectPageState();
}

class BookSelectPageState extends State<BookSelectPage> {
  var newTest = false;
  final carouController = CarouselController();
  Color selectColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.hovered)) {
      return Colors.green.shade50;
    } else if (states.contains(MaterialState.pressed)) {
      return Colors.green.shade100;
    } else {
      return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    carouController.animateToPage(0);
                  },
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(BorderSide.none),
                    minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery.of(context).size.width / 2, 50),
                    ),
                    overlayColor:
                        MaterialStateProperty.resolveWith(selectColor),
                  ),
                  child: const Text(
                    "구약",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    carouController.animateToPage(1);
                  },
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(BorderSide.none),
                    minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery.of(context).size.width / 2, 50),
                    ),
                    overlayColor:
                        MaterialStateProperty.resolveWith(selectColor),
                  ),
                  child: const Text(
                    "신약",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width:
                    newTest ? MediaQuery.of(context).size.width / 2 + 10 : 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2 - 20,
                height: 2,
                color: Colors.green,
              ),
            ],
          ),
          Expanded(
            child: CarouselSlider(
              carouselController: carouController,
              items: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.separated(
                    itemCount: 39,
                    itemBuilder: (context,index)=>ListTile(
                      title: Text(Book.values[index].kor),
                      onTap: () {
                        Navigator.pushNamed(context, "/chapters",
                            arguments: Book.values[index]);
                      },
                    ),
                    separatorBuilder: (context,_)=>const Divider(
                      thickness: 0.5,
                      height: 0.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.separated(
                    itemCount: 27,
                    itemBuilder: (context,index)=>ListTile(
                      title: Text(Book.values[index+39].kor, textAlign: TextAlign.end,),
                      onTap: () {
                        Navigator.pushNamed(context, "/chapters",
                            arguments: Book.values[index+39]);
                      },
                    ),
                    separatorBuilder: (context,_)=>const Divider(
                      thickness: 0.5,
                      height: 0.5,
                    ),
                  ),
                )
              ],
              options: CarouselOptions(
                enableInfiniteScroll: false,
                viewportFraction: 1,
                height: MediaQuery.of(context).size.height,
                onPageChanged: (page, _) {
                  setState(() {
                    newTest = page != 0;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterSelectPage extends StatefulWidget {
  const ChapterSelectPage({super.key});

  @override
  State<StatefulWidget> createState() => ChapterSelectState();
}

class ChapterSelectState extends State<ChapterSelectPage> {
  late Book currBook;
  @override
  Widget build(BuildContext context) {
    currBook = (ModalRoute.of(context)?.settings.arguments as Book) ?? Book.gen;
    return Scaffold(
      appBar: AppBar(
        title: Text(currBook.kor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GridView(
        padding: const EdgeInsets.all(5),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 80, mainAxisSpacing: 5, crossAxisSpacing: 5),
        // crossAxisCount: 6,
        children: [
          for (var t = 1; t <= currBook.chapters; t++)
            ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
                  shadowColor: MaterialStateProperty.all(Colors.transparent)),
              onPressed: () {
                Navigator.pushNamed(context, "/verses",
                    arguments: BookNChap(currBook, t));
              },
              child: Text(
                t.toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
        ],
      ),
    );
  }
}
