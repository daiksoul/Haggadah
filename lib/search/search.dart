import 'package:flutter/material.dart';
import 'package:haggah/bible/dat.dart';
import 'package:haggah/bible/verse.dart';
import 'package:haggah/search/search_manager.dart';
import 'package:haggah/util/verse_data.dart';
import 'package:provider/provider.dart';

class Search {
  Future<List<Map>> search(String query) async {
    String searchOptions = '';
    return (await DBManager.database.rawQuery(
            "SELECT ZBOOK_NAME, ZCHAPTER_NUMBER, ZVERSE_NUMBER, ZVERSE_CONTENT FROM ZVERSE JOIN (SELECT ZCHAPTER.Z_PK, ZBOOK_NAME, ZCHAPTER_NUMBER, ZBOOK_INDEX FROM ZBOOK JOIN ZCHAPTER ON (ZBOOK.Z_PK = ZCHAPTER.ZTOBOOK) $searchOptions ) AS C ON (ZVERSE.ZTOCHAPTER = C.Z_PK) WHERE ZVERSE_CONTENT LIKE '$query' ORDER BY ZBOOK_INDEX ASC, ZCHAPTER_NUMBER ASC, ZVERSE_NUMBER ASC;"))
        .map((e) => Map.of(e))
        .toList();
  }
}

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  final GlobalKey _results = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchManager(),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('검색'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Consumer<SearchManager>(builder: (context, state, _) {
            return CustomScrollView(
              slivers: [
                const SliverResizingHeader(
                  maxExtentPrototype: SearchHeader(),
                  minExtentPrototype: SearchHeader(),
                  child: SearchHeader(),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: ExpansionTile(
                      dense: true,
                      maintainState: true,
                      title: Text('검색 범위'),
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              toggler(
                                text: '전체',
                                onChange: state.toggleAll,
                                value: state.isAllSelected(),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        toggler(
                                          text: '구약 전체',
                                          onChange: state.toggleOldT,
                                          value: state.isOldTAllSelected(),
                                        ),
                                        ...List.generate(
                                          39,
                                          (idx) => toggler(
                                            text: Book.values[idx].kor,
                                            onChange: () => state
                                                .toggleBook(Book.values[idx]),
                                            value: state
                                                .bookSelected(Book.values[idx]),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      toggler(
                                        text: '신약 전체',
                                        onChange: state.toggleNewT,
                                        value: state.isNewTAllSelected(),
                                      ),
                                      ...List.generate(
                                        27,
                                        (idx) => toggler(
                                          text: Book.values[idx + 39].kor,
                                          onChange: () => state
                                              .toggleBook(Book.values[idx + 39]),
                                          value: state.bookSelected(
                                              Book.values[idx + 39]),
                                        ),
                                      )
                                    ],
                                  ))
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SliverResizingHeader(
                  maxExtentPrototype: resultText(state),
                  minExtentPrototype: resultText(state),
                  child: resultText(state),
                ),
                SliverList.builder(
                  key: _results,
                  itemCount: state.queryResult.length,
                  itemBuilder: (_, idx) => QueryVerse(
                    data: state.queryResult[idx],
                    keyword: state.keywordController.text,
                  ),
                )
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget toggler(
      {required String text,
      required void Function() onChange,
      required bool? value}) {
    return GestureDetector(
      child: Row(
        children: [
          Checkbox(value: value, onChanged: (_) => onChange()),
          Text(text),
        ],
      ),
      onTap: onChange,
    );
  }

  Widget resultText(SearchManager state) {
    return Consumer<SearchManager>(
      builder: (context, state, _) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
          child: Text('검색결과 : ${state.queryResult.length} 항목')),
    );
  }
}

class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchManager>(
      builder: (context, state, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        textInputAction: TextInputAction.search,
                        controller: state.keywordController,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: '키워드',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        onFieldSubmitted: (_) {
                          state.search();
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        state.search();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.replay),
                      onPressed: () {
                        state.resetSearchOptions();
                      },
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class QueryVerse extends StatelessWidget {
  const QueryVerse({super.key, required this.data, required this.keyword});
  final Map<String, dynamic> data;
  final String keyword;

  TextSpan _generateSpan() {
    var text = parseVerseData(data["ZVERSE_CONTENT"].toString());
    final word = parseVerseData(keyword);

    if (text.isEmpty) {
      return const TextSpan(text: '로딩중...');
    }

    var lst = <TextSpan>[];
    while (text.contains(word)) {
      final tmp = text.substring(0, text.indexOf(word));
      text = text.substring(text.indexOf(word) + word.length);
      lst.add(TextSpan(text: tmp));
      lst.add(
        TextSpan(
          text: word,
          style: const TextStyle(backgroundColor: Color(0x88fbf719)),
        ),
      );
    }
    lst.add(TextSpan(text: text));

    var toRet = TextSpan(children: lst);

    return toRet;
  }

  @override
  Widget build(BuildContext context) {
    final book = Book.values[data['ZBOOK_INDEX'] - 1];
    final chapter = data['ZCHAPTER_NUMBER'] as int;
    final verse = data['ZVERSE_NUMBER'] as int;
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                '${book.korAb} $chapter : $verse',
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width - 115,
              child: Text.rich(
                _generateSpan(),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/verses',
          arguments: BookNChap(book, chapter),
        );
      },
    );
  }
}
