String parseVerseData(String data) {
  return data
      .replaceAllMapped(RegExp(r'\[[^\[]*\]|\([^\(]*\)'), (_) => '')
      .trim()
      .replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D');
}
