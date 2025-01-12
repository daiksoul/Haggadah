import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haggah/bible/struct.dart';

Future<void> writeRemoteCollection(VerseCollection collection) async {
  await getCollectionRef().doc(collection.uid).set(collection.toJson());
}

Future<void> deleteRemoteCollection(VerseCollection collection) async {
  await getCollectionRef().doc(collection.uid).delete();
}

Future<VerseCollection> readRemoteCollection(String name) async {
  late Map<String, dynamic> map;
  await getCollectionRef().doc(name).snapshots().listen((event) {
    map = Map.of(event.data() as Map<String, dynamic> ?? {});
  });
  return VerseCollection.fromJson(map);
}

Future<List<VerseCollection>> readAllRemoteCollection() async {
  final completer = Completer<List<VerseCollection>>();
  getCollectionRef().snapshots().listen((event) {
    completer.complete(event.docs
        .map((e) => VerseCollection.fromJson(e.data() as Map<String, dynamic>))
        .toList());
  });
  return completer.future;
}

CollectionReference getCollectionRef() {
  return FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("verseCollections");
}
