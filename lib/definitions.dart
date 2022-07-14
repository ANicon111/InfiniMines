import 'package:flutter/material.dart';

class RelSize {
  final BuildContext context;
  RelSize(this.context);
  double get vmin {
    return MediaQuery.of(context).size.shortestSide / 100;
  }

  double get vmax {
    return MediaQuery.of(context).size.longestSide / 100;
  }

  double get pixel {
    return MediaQuery.of(context).size.shortestSide / 1080;
  }
}
