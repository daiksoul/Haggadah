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
import 'package:haggah/util/theme.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ApplicationState()),
      ChangeNotifierProvider(create: (context) => AppStorageState()),
      ChangeNotifierProvider(create: (context) => AppSpeechTextState()),
      ChangeNotifierProvider(create: (context) => AppSettingState()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyState();

  static MyState of(BuildContext context) =>
      context.findAncestorStateOfType<MyState>()!;
}

class MyState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    Future.delayed(
      Duration.zero,
      () {
        if (FirebaseAuth.instance.currentUser != null) {
          Provider.of<ApplicationState>(context, listen: false).signIn();
        } else {
          Provider.of<ApplicationState>(context, listen: false).signOut();
        }
        Provider.of<AppSpeechTextState>(context, listen: false).init();
        resolveReadAll(context).then((val) {
          for (final collect in val) {
            Provider.of<AppStorageState>(context, listen: false)
                .add(context, collect);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    Provider.of<AppSpeechTextState>(context, listen: false).stop();
    super.dispose();
    // WidgetsBinding.instance.removeObserver(this);
  }

  ThemeMode myThemeMode = ThemeMode.system;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haggadah',
      scrollBehavior:
          const MaterialScrollBehavior().copyWith(scrollbars: false),
      theme: theme,
      darkTheme: darkTheme,
      themeMode: myThemeMode,
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

  void changeTheme(ThemeMode? themeMode) {
    setState(() {
      myThemeMode = themeMode??myThemeMode;
    });
  }
}

class ApplicationState extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  void signIn() {
    _isSignedIn = true;
  }

  void signOut() {
    _isSignedIn = false;
  }
}
