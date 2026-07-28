import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/material.dart';

void main() {
  final chars_1 = "안녕하십니까만나서반갑습니다이것이무엇일까요";
  final chars_2 = "안녕하십니까반갑습니다오늘은무엇일까요";

  var lst = diff(chars_1, chars_2);
  print(lst);

  for (final a in lst) {
     print(a);
  }
}