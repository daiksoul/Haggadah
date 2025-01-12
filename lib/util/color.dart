import 'package:flutter/material.dart';

extension MyColorExension on Color {
  static Color hexColor(String hex) {
    var col = hex.replaceAll('#', '');
    return Color(0xff000000 + int.parse(col, radix: 16));
  }
}
