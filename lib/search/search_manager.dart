import 'package:flutter/material.dart';
import 'package:haggah/bible/verse.dart';
import 'package:sqflite/sqflite.dart';

import '../bible/dat.dart';

class SearchManager extends ChangeNotifier {
  final Set<Book> _selectedBook = Set.from(Book.values);
  final TextEditingController _keywordController = TextEditingController();
  final List<Map<String, dynamic>> _queryResult = [];

  TextEditingController get keywordController => _keywordController;

  bool bookSelected(Book book) => _selectedBook.contains(book);
  bool isAllSelected() => _selectedBook.containsAll(Book.values);
  bool isNewTAllSelected() =>
      _selectedBook.containsAll(Book.values.where((e) => e.newT));
  bool isOldTAllSelected() =>
      _selectedBook.containsAll(Book.values.where((e) => !e.newT));

  List<Map<String, dynamic>> get queryResult => List.from(_queryResult);

  void selectBook(Book book) {
    _selectedBook.add(book);
    notifyListeners();
  }

  void removeBook(Book book) {
    _selectedBook.remove(book);
    notifyListeners();
  }

  void toggleBook(Book book) {
    if (_selectedBook.contains(book)) {
      _selectedBook.remove(book);
    } else {
      _selectedBook.add(book);
    }
    notifyListeners();
  }

  void toggleAll() {
    if (isAllSelected()) {
      _selectedBook.clear();
    } else {
      _selectedBook.addAll(Book.values);
    }
    notifyListeners();
  }

  void toggleOldT() {
    if (isOldTAllSelected()) {
      _selectedBook.removeWhere((e) => !e.newT);
    } else {
      _selectedBook.addAll(Book.values.where((e) => !e.newT));
    }
    notifyListeners();
  }

  void toggleNewT() {
    if (isNewTAllSelected()) {
      _selectedBook.removeWhere((e) => e.newT);
    } else {
      _selectedBook.addAll(Book.values.where((e) => e.newT));
    }
    notifyListeners();
  }

  void resetSearchOptions() {
    _selectedBook.addAll(Book.values);
    _keywordController.clear();
    _queryResult.clear();
    notifyListeners();
  }

  void search() async {
    if (_keywordController.text.isEmpty) return;
    _queryResult.clear();
    Database db = DBManager.database;

    String searchOption = '';

    if (!isAllSelected()) {
      var str = _selectedBook.map((e) => Book.values.indexOf(e) + 1).join(',');
      searchOption = 'WHERE ZBOOK_INDEX IN($str)';
    }

    final lst = (await db.rawQuery(
            "SELECT ZBOOK_INDEX, ZCHAPTER_NUMBER, ZVERSE_NUMBER, ZVERSE_CONTENT FROM ZVERSE JOIN (SELECT ZCHAPTER.Z_PK, ZBOOK_NAME, ZCHAPTER_NUMBER, ZBOOK_INDEX FROM ZBOOK JOIN ZCHAPTER ON (ZBOOK.Z_PK = ZCHAPTER.ZTOBOOK) $searchOption ) AS C ON (ZVERSE.ZTOCHAPTER = C.Z_PK) WHERE ZVERSE_CONTENT LIKE '%${_keywordController.text}%' ORDER BY ZBOOK_INDEX ASC, ZCHAPTER_NUMBER ASC, ZVERSE_NUMBER ASC;"))
        .map((e) => Map.of(e))
        .toList();
    _queryResult.addAll(lst);
    notifyListeners();
  }
}
