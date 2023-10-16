import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinimines/definitions.dart';
import 'package:infinimines/logic.dart';
import 'dart:ui' as ui;

class Board extends StatefulWidget {
  final double minePercentage;
  final int safeArea;
  final Map<String, ui.Image?> images;
  const Board(
      {Key? key,
      required this.minePercentage,
      required this.images,
      required this.safeArea})
      : super(key: key);

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  TransformationController ctrlr = TransformationController();
  BoardValues values = BoardValues(0.25, 5);
  Offset pointerPosition = const Offset(0, 0);
  final double pieceSize = 100;
  bool gameOver = false;
  bool gameWon = false;
  Timer? refreshTimer;

  ui.Image? _getImage(CellValue cell) {
    if (!cell.isRevealed) {
      if (cell.flagged) return widget.images["flag.png"];
      return widget.images["undiscovered${cell.spriteVariant}.png"];
    }
    if (cell.isMine) return widget.images["exploded.png"];
    return widget.images["${cell.numberOfMinesAround}.png"];
  }

  @override
  void initState() {
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
    values = BoardValues(widget.minePercentage, widget.safeArea);
    resetCamera();
    gameOver = false;
    gameWon = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (values.minePercentage != widget.minePercentage) {
      values = BoardValues(widget.minePercentage, widget.safeArea);
    }
    if (values.safeArea != widget.safeArea) {
      values.safeArea = widget.safeArea;
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
            onTap: gameOver
                ? null
                : () {
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
              width: 1000 * RelSize(context).pixel,
              height: 1000 * RelSize(context).pixel,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(200),
                borderRadius:
                    BorderRadius.circular(10 * RelSize(context).pixel),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    gameWon ? "You win :)" : "Game over",
                    style: TextStyle(fontSize: 160 * RelSize(context).pixel),
                  ),
                  Text(
                    "Score: ${values.points.toStringAsFixed(0)}",
                    style: TextStyle(fontSize: 64 * RelSize(context).pixel),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.all(
                      100 * RelSize(context).pixel,
                    ),
                    child: Container(
                      height: 100 * RelSize(context).pixel,
                      width: 400 * RelSize(context).pixel,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          10 * RelSize(context).pixel,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          restart();
                        },
                        borderRadius: BorderRadius.circular(
                          10 * RelSize(context).pixel,
                        ),
                        child: Center(
                          child: Text(
                            "Restart",
                            style: TextStyle(
                              fontSize: 60 * RelSize(context).pixel,
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
    values.updateArea(
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
