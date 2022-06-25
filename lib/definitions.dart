import 'package:flutter/material.dart';

class RelSize {
  final BuildContext context;
  RelSize(this.context);
  double vmin() {
    return MediaQuery.of(context).size.shortestSide / 100;
  }

  double vmax() {
    return MediaQuery.of(context).size.longestSide / 100;
  }

  double pixel() {
    return MediaQuery.of(context).size.shortestSide / 1080;
  }
}

List<MaterialColor> pieceColors = [
  MaterialColor(Colors.grey.shade700.value,
      {700: Colors.grey.shade800, 800: Colors.grey.shade900}), //empty cell
  MaterialColor(Colors.white.value,
      {700: Colors.grey.shade300, 800: Colors.grey.shade500}), //pseudo-white
  Colors.teal,
  Colors.purple,
  Colors.amber,
  Colors.red,
  Colors.pink,
  Colors.lightGreen,
  Colors.green,
  Colors.blue,
  Colors.indigo,
];
