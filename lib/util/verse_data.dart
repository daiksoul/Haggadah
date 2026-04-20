String parseVerseData(String data, {bool chimrye = false, bool haggah = false}) {
  if (chimrye) data = data.replaceAll("세례", "침례");
  if (haggah) {
    data = data.replaceAll("묵상이", "하가가")
                .replaceAll("묵상", "하가");
  }
    return data
        .replaceAllMapped(
        RegExp(r'^\[[^\[]*\]|어떤 사본에는.*'), (_) => '')
        .trim()
        .replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D');
}

String parseVerseDataMin(String data, {bool chimrye = false, bool haggah = false}) {
  if (chimrye) data = data.replaceAll("세례", "침례");
  if (haggah) data = data.replaceAll("묵상", "하가");
  return data
      .replaceAllMapped(
          RegExp(r'^\[[^\[]*\]|어떤 사본에는.*'), (_) => '')
      .trim();
}

String numberToText(int number) {
  int n = number;
  final hund = n ~/ 100;
  n = n % 100;
  final ten = n ~/ 10;
  n = n % 10;
  final one = n;

  var toReturn = '';
  if (hund >= 1) {
    if (hund != 1) {
      toReturn += numToKorMap[hund] ?? '';
    }
    toReturn += '백 ';
  }
  if (ten >= 1) {
    if (ten != 1) {
      toReturn += numToKorMap[ten] ?? '';
    }
    toReturn += '십 ';
  }
  toReturn += numToKorMap[one] ?? '';
  return toReturn;
}

Map<int, String> numToKorMap = {
  1: '일',
  2: '이',
  3: '삼',
  4: '사',
  5: '오',
  6: '육',
  7: '칠',
  8: '팔',
  9: '구',
};
