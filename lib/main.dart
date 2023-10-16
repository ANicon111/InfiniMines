import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinimines/board.dart';
import 'package:infinimines/definitions.dart';
import 'package:infinimines/settings.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Frame(),
      theme: ThemeData.dark(),
    );
  }
}

class Frame extends StatefulWidget {
  const Frame({Key? key}) : super(key: key);

  @override
  State<Frame> createState() => _FrameState();
}

class _FrameState extends State<Frame> {
  bool settingsOpen = false;
  double minePercentage = 0.25;
  int safeArea = 5;
  String currentTheme = "";
  Map<String, ui.Image?> images = {
    "flag.png": null,
    "exploded.png": null,
    "undiscovered1.png": null,
    "undiscovered2.png": null,
    "undiscovered3.png": null,
    "undiscovered4.png": null,
    "undiscovered5.png": null,
    "0.png": null,
    "1.png": null,
    "2.png": null,
    "3.png": null,
    "4.png": null,
    "5.png": null,
    "6.png": null,
    "7.png": null,
    "8.png": null,
  };

  void _loadImage(String category, String name) async {
    final data = await rootBundle.load("assets/$category/$name");
    images[name] = await decodeImageFromList(data.buffer.asUint8List());
    setState(() {});
  }

  double setPercentage([double val = -1]) {
    if (val != -1) {
      minePercentage = val;
      setState(() {});
    }
    return minePercentage;
  }

  int setSafeArea([int val = -1]) {
    if (val != -1) {
      safeArea = val;
      setState(() {});
    }
    return safeArea;
  }

  @override
  void initState() {
    images.forEach((key, value) => _loadImage("grassy", key));
    currentTheme = "grassy";
    super.initState();
  }

  void setTheme(String theme) {
    images.forEach((key, value) => _loadImage(theme, key));
    currentTheme = theme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Visibility(
            visible: settingsOpen,
            child: Settings(
              setPercentage: setPercentage,
              setSafeArea: setSafeArea,
              setTheme: setTheme,
              currentTheme: currentTheme,
            ),
          ),
          Visibility(
            visible: !settingsOpen,
            maintainState: true,
            child: Board(
              minePercentage: minePercentage,
              images: images,
              safeArea: safeArea,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              iconSize: 64 * RelSize(context).pixel,
              onPressed: () {
                setState(() {
                  settingsOpen = !settingsOpen;
                });
              },
              icon: settingsOpen
                  ? const Icon(Icons.close)
                  : const Icon(Icons.settings),
            ),
          )
        ],
      ),
    );
  }
}
