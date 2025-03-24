import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeColor _currentColor = ThemeColor.blue;
  
  ThemeColor get currentColor => _currentColor;

  void setColor(ThemeColor color) {
    _currentColor = color;
    notifyListeners();
  }
}

enum ThemeColor {
  red,
  orange,
  yellow,
  green,
  blue,
  indigo,
  violet,
  gray,
  black,
  white;

  Color get color {
    switch (this) {
      case ThemeColor.red:
        return Colors.red.withOpacity(0.8);
      case ThemeColor.orange:
        return Colors.orange.withOpacity(0.8);
      case ThemeColor.yellow:
        return Colors.yellow.withOpacity(0.8);
      case ThemeColor.green:
        return Colors.green.withOpacity(0.8);
      case ThemeColor.blue:
        return Colors.blue.withOpacity(0.8);
      case ThemeColor.indigo:
        return Colors.indigo.withOpacity(0.8);
      case ThemeColor.violet:
        return Colors.purple.withOpacity(0.8);
      case ThemeColor.gray:
        return Colors.grey.withOpacity(0.8);
      case ThemeColor.black:
        return Colors.black;
      case ThemeColor.white:
        return Colors.white;
    }
  }
} 