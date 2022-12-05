import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:haggah/data/firebase.dart';
import 'package:haggah/data/localfile.dart';
import 'package:haggah/main.dart';
import 'package:haggah/store/storage.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Consumer<ApplicationState>(builder: (context, state, _) {
                  return (state.isSignedIn)
                      ? Image.network(
                          FirebaseAuth.instance.currentUser!.photoURL ?? "wee")
                      : const Icon(
                          Icons.person,
                          size: 60,
                        );
                }),
                const SizedBox(height: 16.0),
                Consumer<ApplicationState>(
                  builder: (context, state, _) {
                    return (state.isSignedIn)
                        ? Text(FirebaseAuth.instance.currentUser!.displayName ??
                            "Nope")
                        : const Text("로그인");
                  },
                )
              ],
            ),
            const SizedBox(height: 120.0),
            Consumer2<ApplicationState, AppStorageState>(
              builder: (context, state, store, _) => (!state.isSignedIn)
                  ? IconLoginButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green.shade200),
                          minimumSize: MaterialStateProperty.all(
                              const Size.fromHeight(50)),
                          padding: MaterialStateProperty.all(EdgeInsets.zero)),
                      text: "GOOGLE",
                      icon: const Icon(
                        Icons.g_mobiledata_rounded,
                        size: 40,
                      ),
                      onPressed: () async {
                        UserCredential ud = await signInWithGoogle();
                        if (ud.user != null) {
                          state.signIn();
                          final user = FirebaseAuth.instance.currentUser!;
                          final collection =
                              FirebaseFirestore.instance.collection("users");
                          collection
                              .where("uid", isEqualTo: user.uid)
                              .get()
                              .then((value) {
                            if (value.docs.isEmpty) {
                              collection.doc(user.uid).set({
                                "uid": user.uid,
                                "name": user.displayName,
                                "email": user.email,
                              });
                            }
                          });
                          readAllLocalCollection().then((list) {
                            for (final val in list) {
                              writeRemoteCollection(val);
                            }
                          });
                          readAllRemoteCollection().then((list) {
                            // print(list.length);
                            for (final val in list) {
                              // print(val.title);
                              store.add(context, val);
                            }
                          });
                          setState(() {});
                        }
                      },
                    )
                  : IconLoginButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.red.shade200),
                        minimumSize: MaterialStateProperty.all(
                            const Size.fromHeight(50)),
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                      ),
                      text: "LOGOUT",
                      icon: const Icon(
                        Icons.logout,
                        size: 40,
                      ),
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        state.signOut();
                        setState(() {});
                      },
                    ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class IconLoginButton extends StatelessWidget {
  const IconLoginButton(
      {Key? key,
      required this.onPressed,
      required this.style,
      required this.icon,
      required this.text})
      : super(key: key);
  final void Function() onPressed;
  final ButtonStyle style;
  final Icon icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: icon,
          ),
          const SizedBox(
            width: 30,
          ),
          Expanded(
              child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(fontSize: 20),
            ),
          ))
        ],
      ),
    );
  }
}

Future<UserCredential> signInWithGoogle() async {
  if (!kIsWeb) {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: [
      "email",
    ]).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } else {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();

    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }
}
