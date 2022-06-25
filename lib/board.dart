import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinimines/definitions.dart';
import 'package:infinimines/logic.dart';
import 'dart:ui' as ui;

class Board extends StatefulWidget {
  final double minePercentage;
  const Board({Key? key, required this.minePercentage}) : super(key: key);

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  TransformationController ctrlr = TransformationController();
  BoardValues values = BoardValues(0.25);
  Offset pointerPosition = const Offset(0, 0);
  final double pieceSize = 100;
  bool gameOver = false;
  bool gameWon = false;
  Timer? refreshTimer;

  final Map<String, ui.Image?> images = {
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

  void _loadImage(String name) async {
    final data = await rootBundle.load("assets/$name");
    images[name] = await decodeImageFromList(data.buffer.asUint8List());
    setState(() {});
  }

  ui.Image? _getImage(CellValue cell) {
    if (!cell.isRevealed) {
      if (cell.flagged) return images["flag.png"];
      return images["undiscovered${cell.spriteVariant}.png"];
    }
    if (cell.isMine) return images["exploded.png"];
    return images["${cell.numberOfMinesAround}.png"];
  }

  @override
  void initState() {
    images.forEach((key, value) => _loadImage(key));
    resetCamera();
    refreshTimer = Timer.periodic(
      const Duration(milliseconds: 1000 ~/ 30),
      (_) {
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    if (refreshTimer != null && refreshTimer!.isActive) refreshTimer!.cancel();
    super.dispose();
  }

  void resetCamera() {
    ctrlr.value = Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -5e7, -5e7, 0, 1);
  }

  void restart() {
    values = BoardValues(widget.minePercentage);
    resetCamera();
    gameOver = false;
    gameWon = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (values.minePercentage != widget.minePercentage) {
      values = BoardValues(widget.minePercentage);
    }
    return Stack(
      children: [
        InteractiveViewer(
          panEnabled: !gameOver,
          scaleEnabled: !gameOver,
          constrained: false,
          transformationController: ctrlr,
          minScale: 1 / 5,
          maxScale: 2,
          scaleFactor: 200,
          child: GestureDetector(
            onTapDown: (details) {
              pointerPosition = details.localPosition;
            },
            onTap: () {
              switch (values.reveal(pointerPosition.dx ~/ pieceSize,
                  pointerPosition.dy ~/ pieceSize)) {
                case 1:
                  gameOver = true;
                  break;
                case 2:
                  gameOver = true;
                  gameWon = true;
                  break;
                default:
              }

              setState(() {});
            },
            onLongPress: () {
              values.toggleFlag(pointerPosition.dx ~/ pieceSize,
                  pointerPosition.dy ~/ pieceSize);
              setState(() {});
            },
            onSecondaryTapDown: (details) {
              pointerPosition = details.localPosition;
            },
            onSecondaryTap: () {
              values.toggleFlag(pointerPosition.dx ~/ pieceSize,
                  pointerPosition.dy ~/ pieceSize);
              setState(() {});
            },
            child: CustomPaint(
              painter: BoardPainter(ctrlr.value, MediaQuery.of(context).size,
                  pieceSize, values, _getImage),
              size: const Size(1e8, 1e8),
            ),
          ),
        ),
        Visibility(
          visible: gameOver,
          child: Center(
            child: Container(
              width: 1000 * RelSize(context).pixel(),
              height: 1000 * RelSize(context).pixel(),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(200),
                borderRadius:
                    BorderRadius.circular(10 * RelSize(context).pixel()),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    gameWon ? "You win :)" : "Game over",
                    style: TextStyle(fontSize: 160 * RelSize(context).pixel()),
                  ),
                  Text(
                    "Score: ${values.points.toStringAsFixed(0)}",
                    style: TextStyle(fontSize: 64 * RelSize(context).pixel()),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.all(
                      100 * RelSize(context).pixel(),
                    ),
                    child: Container(
                      height: 100 * RelSize(context).pixel(),
                      width: 400 * RelSize(context).pixel(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          10 * RelSize(context).pixel(),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          restart();
                        },
                        borderRadius: BorderRadius.circular(
                          10 * RelSize(context).pixel(),
                        ),
                        child: Center(
                          child: Text(
                            "Restart",
                            style: TextStyle(
                              fontSize: 60 * RelSize(context).pixel(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BoardPainter extends CustomPainter {
  final Matrix4 screen;
  final Size screenSize;
  final double pieceSize;
  final BoardValues values;
  final Function getImage;
  BoardPainter(
      this.screen, this.screenSize, this.pieceSize, this.values, this.getImage);
  final int safeArea = 10;

  @override
  void paint(Canvas canvas, Size size) {
    double scale = pieceSize * screen.getMaxScaleOnAxis();
    int x = -screen.row0.a ~/ scale;
    int y = -screen.row1.a ~/ scale;
    int width = screenSize.width ~/ scale;
    int height = screenSize.height ~/ scale;
    values.generateArea(
        x > safeArea ? x - safeArea : 0,
        y > safeArea ? y - safeArea : 0,
        width + 2 * safeArea,
        height + 2 * safeArea);
    for (int i = y > safeArea ? -safeArea : 0;
        i <= height + safeArea && i + y < size.height ~/ pieceSize;
        i++) {
      for (int j = x > safeArea ? -safeArea : 0;
          j <= width + safeArea && j + x < size.width ~/ pieceSize;
          j++) {
        if (getImage(values.getVal(j + x, i + y)) != null) {
          canvas.drawImage(getImage(values.getVal(j + x, i + y)),
              Offset((j + x) * pieceSize, (i + y) * pieceSize), Paint());
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (1 == 1) return true;
    throw UnimplementedError();
  }
}
