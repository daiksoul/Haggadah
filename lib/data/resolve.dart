import 'package:flutter/material.dart';
import 'package:haggah/bible/struct.dart';
import 'package:haggah/bible/verse.dart';
import 'package:haggah/data/firebase.dart';
import 'package:haggah/data/localfile.dart';
import 'package:haggah/main.dart';
import 'package:provider/provider.dart';

Future<bool> resolveWrite(BuildContext context, VerseCollection collection)async{
  final signedIn = Provider.of<ApplicationState>(context, listen: false).isSignedIn;
  if(signedIn){
    await writeRemoteCollection(collection);
  }
  await writeLocalCollection(collection);
  return true;
}

Future<bool> resolveDelete(BuildContext context, VerseCollection collection)async{
  final signedIn = Provider.of<ApplicationState>(context, listen: false).isSignedIn;
  if(signedIn){
    await deleteRemoteCollection(collection);
  }
  await deleteLocalCollection(collection);
  return true;
}

Future<List<VerseCollection>> resolveReadAll(BuildContext context)async{
  final signedIn = Provider.of<ApplicationState>(context, listen: false).isSignedIn;
  if(signedIn){
    return readAllRemoteCollection();
  }else{
    return readAllLocalCollection();
  }
}

Future<VerseCollection> resolveRead(BuildContext context, String name){
  final signedIn = Provider.of<ApplicationState>(context, listen:  false).isSignedIn;
  if(signedIn){
    return readRemoteCollection(name);
  }else{
    return readLocalCollection(name);
  }
}