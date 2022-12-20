import 'dart:convert';
import 'dart:io';

import 'package:haggah/bible/struct.dart';
import 'package:haggah/bible/verse.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async{
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> getLocalCollection(String name)async{
  final path = await _localPath;
  return File('$path/collections/$name');
}

Future<FileSystemEntity> deleteLocalCollection(VerseCollection collection) async{
  final file = await getLocalCollection('${collection.uid}.json');
  return await file.delete();
}

Future<File> writeLocalCollection(VerseCollection collection) async{
  final file = await getLocalCollection('${collection.uid}.json');
  return (await file.writeAsString(jsonEncode(collection.toJson())));
}

Future<VerseCollection> readLocalCollection(String name) async{
  final file = await getLocalCollection(name);
  return VerseCollection.fromJson(jsonDecode(await file.readAsString()));
}

Future<List<VerseCollection>> readAllLocalCollection() async{
  final path = await _localPath;
  final dir = Directory("$path/collections/");
  // print(await dir.exists());
  if(!(await dir.exists())){
    await dir.create(recursive: true);
  }
  final files = dir.listSync();
  List<VerseCollection> toReturn = [];
  for(final file in files){
    toReturn.add(await readLocalCollection(basename(file.path)));
  }
  return toReturn;
}