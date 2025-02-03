import 'package:flutter/material.dart';
import 'package:haggah/bible/dat.dart';
import 'package:haggah/bible/verse.dart';
import 'package:haggah/util/verse_data.dart';
import 'package:sqflite/sqflite.dart';

/// Collection of [MultiVerse]
///
/// Collection of multiple [MultiVerse]s</br>
/// Users create VerseCollection when creating collection
class VerseCollection {
  /// List of [MultiVerse]
  List<MultiVerse> verses;

  /// Title of the Collection
  String title;

  /// Unique id of the collection
  final String uid;

  /// Creates an empty Verse Collection
  VerseCollection.empty({required this.title})
      : verses = [],
        uid = UniqueKey().toString();

  /// Creates a Collection with verses initialized
  VerseCollection({required this.title, required this.verses})
      : uid = UniqueKey().toString();

  /// Exports to JSON
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'title': title,
        'verses': verses.map((e) => e.toJson()).toList(),
      };

  /// Imports from JSON
  VerseCollection.fromJson(Map<String, dynamic> json)
      : uid = (json.containsKey("uid"))
            ? json['uid'] as String
            : UniqueKey().toString(),
        title = json['title'] as String,
        verses = (json['verses'] as List)
            .map((e) => MultiVerse.fromJson(e))
            .toList();
}

/// Collection of individual [Verse]s
///
/// Contains individual [Verse]s</br>
/// and list of [Highlight]s
class MultiVerse {
  /// List of [Verse]s
  List<Verse> verse;

  /// List of [Highlight]s
  List<Highlight> comment = [];

  /// Constructor with verses list
  MultiVerse(this.verse);

  /// Returns a short name
  ///
  /// ex) 창세기 1장 1절, 창세기 1장 2절, 창세기 1장 3절 -> 창세기 1장 1-3절</br>
  /// 호세아 6장 3절, 호세아 6장 6절 -> 호세아 6장 3,6절
  String getShortName() {
    int tmp = verse.first.verse;
    int count = 0;
    String v = "$tmp";

    for (int i = 0; i < verse.length; i++) {
      if (tmp == verse[i].verse) {
        tmp++;
        count++;
      } else {
        if (count == 1) {
          v += ",";
        } else {
          v += "-${tmp - 1},";
        }
        count = 1;
        v += "${verse[i].verse}";
        tmp = verse[i].verse + 1;
      }
    }
    if (count > 1) {
      v += "-${tmp - 1}";
    }

    return "${verse[0].book.korAb} ${verse[0].chapter} : $v";
  }

  String getName() {
    int tmp = verse.first.verse;
    int count = 0;
    String v = "${numberToText(tmp)}절";

    for (int i = 0; i < verse.length; i++) {
      if (tmp == verse[i].verse) {
        tmp++;
        count++;
      } else {
        if (count == 1) {
          v += ", ";
        } else {
          v += "부터 ${numberToText(tmp - 1)}절, ";
        }
        count = 1;
        v += "${numberToText(verse[i].verse)}절";
        tmp = verse[i].verse + 1;
      }
    }
    if (count > 1) {
      v += "부터 ${numberToText(tmp - 1)}절";
    }

    return "${verse[0].book.kor} ${numberToText(verse[0].chapter)}장 $v 말씀.";
  }

  /// Returns a List of Map containing each [Verse] contents
  ///
  /// Calls [Verse.getVerse]
  Future<List<Map>> getAllVerses() async {
    List<Map> toReturn = [];
    for (final v in verse) {
      toReturn.add(await v.getVerse());
    }
    return toReturn;
  }

  /// Export to JSON
  Map<String, dynamic> toJson() => {
        'verses': verse.map((e) => e.toJson()).toList(),
        'comment': comment.map((e) => e.toJson()).toList()
      };

  /// Import from JSON
  MultiVerse.fromJson(Map<String, dynamic> json)
      : verse = (json["verses"] as List).map((e) => Verse.fromJson(e)).toList(),
        comment = List<dynamic>.of(json['comment'] ?? [])
            .map((e) => Highlight.fromJson(e))
            .toList(growable: true);

  /// Add or Remove Highlights on Verses
  ///
  /// If [remove] is set to true, then It will remove the highlight from the selected range
  /// </br>
  /// </br>
  /// Adding a new highlight right next to an existing highlight
  /// with the same color will merge them together</br>
  /// Adding a new highlight on top of an existing highlight
  /// will override the existing highlight
  void highlight(String color, int start, int end, [bool remove = false]) {
    var addAfter = <Highlight>[];

    for (var val in comment) {
      if (val.start <= start && val.end >= end) {
        addAfter.add(Highlight(color: val.color, start: end, end: val.end));
        val.end = start;
      } else {
        if (val.start <= start && val.end >= start) {
          val.end = start;
        }
        if (val.start <= end && val.end >= end) {
          val.start = end;
        }
      }
    }
    comment.removeWhere((val) => (start <= val.start && end >= val.end));
    comment.addAll(addAfter);

    if (!remove) {
      comment.add(Highlight(color: color, start: start, end: end));
    }

    comment.sort((a, b) {
      return a.start - b.start;
    });
  }
}

/// Info of a verse
///
/// Contains only the essential data
class Verse {
  /// The book where the verse is from
  Book book;

  /// The chapter where the verse is from
  int chapter;

  /// The verse number
  int verse;

  /// All fields are required to construct this object
  Verse({required this.book, required this.chapter, required this.verse});

  /// Get query result from the DB corresponding to this verse
  Future<Map> getVerse() async {
    Database db = await getDB();
    return (await db.rawQuery(
            "SELECT * FROM ZVERSE WHERE ZVERSE_NUMBER = $verse and ZTOCHAPTER = (SELECT Z_PK FROM ZCHAPTER WHERE ZCHAPTER_NUMBER = $chapter AND ZTOBOOK = (SELECT Z_PK FROM ZBOOK WHERE ZBOOK_INDEX=${book.index + 1}))"))
        .map((e) => Map.of(e))
        .toList()[0];
  }

  /// Import from JSON
  Verse.fromJson(Map<String, dynamic> json)
      : book = Book.values[json['book'] as int],
        chapter = json['chapter'] as int,
        verse = json['verse'] as int;

  /// Export to JSON
  Map<String, dynamic> toJson() =>
      {'book': book.index, 'chapter': chapter, 'verse': verse};
}

/// Highlight object
///
/// the [start] field and the [end] field are from
/// the index of [MultiVerse] rather than each individual [Verse]s
class Highlight {
  /// Color of the Highlight
  String color;

  /// Where the highlight begins
  int start;

  /// where the highlight ends
  int end;

  Highlight({required this.color, required this.start, required this.end});

  /// Import from JSON
  Highlight.fromJson(Map<String, dynamic> json)
      : color = json['color'] as String,
        start = json['s'] as int,
        end = json['e'] as int;

  /// Export to JSON
  Map<String, dynamic> toJson() => {'color': color, 's': start, 'e': end};
}

/// To create Color object from Hexcode
///
/// probably useless
@Deprecated("Hexcodes can already be used from Color objects")
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
