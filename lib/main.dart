import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:haggah/bible/select.dart';
import 'package:haggah/bible/verse.dart';
import 'package:haggah/data/resolve.dart';
import 'package:haggah/home.dart';
import 'package:haggah/login.dart';
import 'package:haggah/setting/setting.dart';
import 'package:haggah/store/storage.dart';
import 'package:haggah/tester/card_test.dart';
import 'package:haggah/store/verse_card.dart';
import 'package:haggah/tester/voice_test.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context)=>ApplicationState()),
          ChangeNotifierProvider(create: (context)=>AppStorageState()),
          ChangeNotifierProvider(create: (context)=>AppSpeechTextState()),
          ChangeNotifierProvider(create: (context)=>AppSettingState()),
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
        if(FirebaseAuth.instance.currentUser!=null){
          Provider.of<ApplicationState>(context,listen: false).signIn();
        }else{
          Provider.of<ApplicationState>(context,listen: false).signOut();
        }
        Provider.of<AppSpeechTextState>(context,listen: false).init();
        resolveReadAll(context).then(
          (val){
            for(final collect in val){
              Provider.of<AppStorageState>(context,listen: false).add(context,collect);
            }
          }
        );
      },
    );
  }

  @override
  void dispose(){
    Provider.of<AppSpeechTextState>(context,listen: false).stop();
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
        fontFamily: 'Nanum',
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.green.shade200,
          elevation: 1
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(TextStyle(color: Colors.green.shade200))
          )
        ),
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
        ), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(secondary: Colors.green)
      ),
      initialRoute: "/",
      routes: {
        "/": (BuildContext context) => const HomePage(),
        "/books": (BuildContext context) => const BookSelectPage(),
        "/chapters": (BuildContext context) => const ChapterSelectPage(),
        "/verses": (BuildContext context) => const VersePage(),
        "/collections": (BuildContext context) => const StoragePage(),
        "/card": (BuildContext context) => const VerseCardPage(),
        "/practice": (BuildContext context) => const CardTestPage(),
        "/test": (BuildContext context) => const VocalTestPage(),
        "/login": (BuildContext context) => const LoginPage(),
        "/settings": (BuildContext context) => const SettingsPage(),
      },
    );
  }
}

class ApplicationState extends ChangeNotifier{
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  void signIn(){
    _isSignedIn = true;
  }

  void signOut(){
    _isSignedIn = false;
  }
}