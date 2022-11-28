import 'package:flutter/material.dart';
import 'package:haggah/bible/select.dart';
import 'package:haggah/bible/verse.dart';
import 'package:haggah/data/localfile.dart';
import 'package:haggah/home.dart';
import 'package:haggah/store/storage.dart';
import 'package:haggah/store/test.dart';
import 'package:haggah/store/verse_card.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context)=>ApplicationState()),
          ChangeNotifierProvider(create: (context)=>AppStorageState())
        ],
        child: const MyApp(),
    )
  );
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyState();
}

class MyState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState(){
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    Future.delayed(
      Duration.zero,
      (){
        readAllLocalCollection().then(
          (val){
            for(final collect in val){
              Provider.of<AppStorageState>(context,listen: false).add(collect);
            }
          }
        );
      },
    );
  }

  @override
  void dispose(){
    super.dispose();
    // WidgetsBinding.instance.removeObserver(this);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haggadah',
      scrollBehavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          shadowColor: Colors.transparent,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20
          )
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          unselectedIconTheme: IconThemeData(
            color: Colors.black,
            size: 24
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.green.shade100,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                color: Colors.black
              )
            ),
            backgroundColor: MaterialStateProperty.all(Colors.green.shade100),
          )
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                color: Colors.green
              )
            )
          )
        )
      ),
      initialRoute: "/",
      routes: {
        "/": (BuildContext context) => const HomePage(),
        "/books": (BuildContext context) => const BookSelectPage(),
        "/chapters": (BuildContext context) => const ChapterSelectPage(),
        "/verses": (BuildContext context) => const VersePage(),
        "/collections": (BuildContext context) => const StoragePage(),
        "/card": (BuildContext context) => const VerseCardPage(),
        "/practice": (BuildContext context) => const TestPage()
      }
    );
  }
}

class ApplicationState extends ChangeNotifier{
  bool _isSignedIn = false;

  void signIn(){
    _isSignedIn = true;
  }
}