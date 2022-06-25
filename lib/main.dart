import 'package:flutter/material.dart';
import 'package:infinimines/board.dart';
import 'package:infinimines/definitions.dart';
import 'package:infinimines/settings.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Frame(),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
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

  double setPercentage([double val = -1]) {
    if (val != -1) {
      minePercentage = val;
      setState(() {});
    }
    return minePercentage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Visibility(
            visible: settingsOpen,
            child: Settings(setPercentage: setPercentage),
          ),
          Visibility(
            visible: !settingsOpen,
            maintainState: true,
            child: Board(minePercentage: minePercentage),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              iconSize: 64 * RelSize(context).pixel(),
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
