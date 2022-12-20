import 'package:flutter/material.dart';
import 'package:haggah/bible/dat.dart';
import 'package:haggah/bible/verse.dart';
import 'package:sqflite/sqflite.dart';

class VerseCollection {
  List<MultiVerse> verses;
  String title;
  final String uid;

  VerseCollection.empty({required this.title})
      : verses = [],
        uid = UniqueKey().toString();

  VerseCollection({required this.title, required this.verses})
      : uid = UniqueKey().toString();

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'title': title,
    'verses': verses.map((e) => e.toJson()).toList(),
  };

  VerseCollection.fromJson(Map<String, dynamic> json)
      : uid = (json.containsKey("uid"))?json['uid'] as String:UniqueKey().toString(),
        title = json['title'] as String,
        verses = (json['verses'] as List)
            .map((e) => MultiVerse.fromJson(e))
            .toList();
}

class MultiVerse {
  List<Verse> verse;
  List<Highlight> comment = [];
  MultiVerse(this.verse);

  String getShortName() {
    int tmp = verse.first.verse;
    int count = 0;
    String v = "$tmp";

    for(int i = 0; i<verse.length; i++){
      if(tmp==verse[i].verse){
        tmp++;
        count++;
      }else{
        if(count==1){
          v += ",";
        }else{
          v += "-${tmp-1},";
        }
        count = 1;
        v += "${verse[i].verse}";
        tmp = verse[i].verse+1;
      }
    }
    if(count>1){
      v += "-${tmp-1}";
    }

    return "${verse[0].book.korAb} ${verse[0].chapter} : $v";
  }

  Future<List<Map>> getAllVerses() async {
    List<Map> toReturn = [];
    for (final v in verse) {
      toReturn.add(await v.getVerse());
    }
    return toReturn;
  }

  Map<String, dynamic> toJson() => {
    'verses': verse.map((e) => e.toJson()).toList(),
    'comment': comment.map((e) => e.toJson()).toList()
  };

  MultiVerse.fromJson(Map<String, dynamic> json)
      : verse = (json["verses"] as List)
      .map((e) => Verse.fromJson(e))
      .toList(),
        comment = List<dynamic>.of(json['comment']??[]).map((e) => Highlight.fromJson(e)).toList(growable: true);

  void highlight(String color, int start, int end, [bool remove = false]){
    var addAfter = <Highlight>[];

    for(var val in comment){
      if(val.start<=start&&val.end>=end){
        addAfter.add(Highlight(color: val.color, start: end, end: val.end));
        val.end = start;
      }else{
        if(val.start<=start&&val.end>=start){
          val.end = start;
        }
        if(val.start<=end&&val.end>=end){
          val.start = end;
        }
      }
    }
    comment.removeWhere((val) => (start<=val.start&&end>=val.end));
    comment.addAll(addAfter);

    if(!remove) {
      comment.add(Highlight(color: color, start: start, end: end));
    }

    comment.sort((a,b){return a.start - b.start;});
  }
}

class Verse {
  Book book;
  int chapter;
  int verse;

  Verse({required this.book, required this.chapter, required this.verse});

  Future<Map> getVerse() async {
    Database db = await getDB();
    return (await db.rawQuery(
        "SELECT * FROM ZVERSE WHERE ZVERSE_NUMBER = $verse and ZTOCHAPTER = (SELECT Z_PK FROM ZCHAPTER WHERE ZCHAPTER_NUMBER = $chapter AND ZTOBOOK = (SELECT Z_PK FROM ZBOOK WHERE ZBOOK_INDEX=${book.index + 1}))"))
        .map((e) => Map.of(e))
        .toList()[0];
  }

  Verse.fromJson(Map<String, dynamic> json)
      : book = Book.values[json['book'] as int],
        chapter = json['chapter'] as int,
        verse = json['verse'] as int;

  Map<String, dynamic> toJson() =>
      {'book': book.index, 'chapter': chapter, 'verse': verse};
}

class Highlight{
  String color;
  int start;
  int end;

  Highlight({required this.color, required this.start, required this.end});

  Highlight.fromJson(Map<String,dynamic> json)
    : color = json['color'] as String,
      start = json['s'] as int,
      end = json['e'] as int;

  Map<String,dynamic> toJson() =>
      {'color': color, 's': start, 'e': end};
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toLowerCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "ff$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}