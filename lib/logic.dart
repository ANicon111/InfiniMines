import 'dart:math';

class CellValue {
  bool isInitd;
  bool isRevealed;
  bool isMine;
  bool flagged;
  int numberOfMinesAround;
  int spriteVariant;
  CellValue({
    this.isInitd = true,
    this.isRevealed = false,
    this.isMine = false,
    this.flagged = false,
    this.numberOfMinesAround = 0,
    this.spriteVariant = 0,
  });
}

class BoardValues {
  double minePercentage;
  int safeArea;
  BoardValues(this.minePercentage, this.safeArea);

  int points = 0;
  bool firstTap = true;
  final Map<int, Map<int, CellValue>> _values = {};

  void updateArea(int x, int y, int w, int h) {
    int numberOfMines = (w * h * minePercentage).toInt();
    int numberOfFreeSpaces = w * h - numberOfMines;
    for (int i = y; i < y + h; i++) {
      if (_values[i] == null) {
        _values[i] = {};
      }
      for (int j = x; j < x + w; j++) {
        if (_values[i]![j] == null) {
          int rand = Random().nextInt(numberOfFreeSpaces + numberOfMines);
          int spriteRand = Random().nextInt(1000000);
          int sprite = -1;
          if (spriteRand < 750000) {
            sprite = 1;
          } else if (spriteRand < 950000) {
            sprite = 2;
          } else if (spriteRand < 980000) {
            sprite = 3;
          } else if (spriteRand < 999999) {
            sprite = 4;
          } else {
            sprite = 5;
          }
          if (rand < numberOfMines) {
            _values[i]![j] = CellValue(isMine: true, spriteVariant: sprite);
            numberOfMines--;
          } else {
            _values[i]![j] = CellValue(spriteVariant: sprite);
            numberOfFreeSpaces--;
          }
        } else {
          if (_values[i]![j]!.isMine) {
            numberOfMines--;
          } else {
            _values[i]![j]!.numberOfMinesAround = 0;
            numberOfFreeSpaces--;
          }
        }
      }
    }
    for (int i = y; i < y + h; i++) {
      for (int j = x; j < x + w; j++) {
        if (_values[i]![j]!.isMine) {
          for (int i1 = -1; i1 <= 1; i1++) {
            for (int j1 = -1; j1 <= 1; j1++) {
              if (_values[i + i1] != null && _values[i + i1]![j + j1] != null) {
                _values[i + i1]![j + j1]!.numberOfMinesAround++;
              }
            }
          }
        }
      }
    }
  }

  CellValue getVal(int x, int y) {
    if (_values[y] == null || _values[y]![x] == null) {
      return CellValue(isInitd: false);
    }
    return _values[y]![x]!;
  }

  Map<int, Map<int, CellValue>> debug() {
    return _values;
  }

  int reveal(int x, int y) {
    if (_values[y]![x]!.spriteVariant == 5) {
      points = 999999;
      return 2;
    }
    if (firstTap) {
      firstTap = false;
      if (x < safeArea ~/ 2) x = safeArea ~/ 2;
      if (y < safeArea ~/ 2) y = safeArea ~/ 2;
      for (int i = -safeArea ~/ 2; i < safeArea / 2; i++) {
        for (int j = -safeArea ~/ 2; j < safeArea / 2; j++) {
          if (_values[y + i] != null &&
              _values[y + i]![x + j] != null &&
              _values[y + i]![x + j]!.isMine) {
            _values[y + i]![x + j]!.isMine = false;
          }
        }
      }
      updateArea(x - safeArea ~/ 2 - 1, y - safeArea ~/ 2 - 1, safeArea + 2,
          safeArea + 2);
    }
    int numberOfFlagsAround = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (_values[y + i] != null &&
            _values[y + i]![x + j] != null &&
            (_values[y + i]![x + j]!.flagged ||
                _values[y + i]![x + j]!.spriteVariant == 5)) {
          numberOfFlagsAround++;
        }
      }
    }
    if (!_values[y]![x]!.isRevealed && !_values[y]![x]!.flagged ||
        _values[y]![x]!.isRevealed &&
            _values[y]![x]!.numberOfMinesAround == numberOfFlagsAround) {
      bool revealAround = false;
      if (_values[y]![x]!.numberOfMinesAround == numberOfFlagsAround) {
        revealAround = true;
      }
      List<int> stepsX = [x];
      List<int> stepsY = [y];
      int depth = 0;
      int max = 1;
      _values[y]![x]!.isRevealed = true;
      while (max > depth && max < 100000) {
        x = stepsX[depth];
        y = stepsY[depth];
        depth++;
        if (_values[y]![x]!.numberOfMinesAround == 0 || revealAround) {
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              if (_values[y + i] != null &&
                  _values[y + i]![x + j] != null &&
                  !_values[y + i]![x + j]!.isRevealed &&
                  (!_values[y + i]![x + j]!.isMine || revealAround) &&
                  !_values[y + i]![x + j]!.flagged &&
                  _values[y + i]![x + j]!.spriteVariant != 5) {
                _values[y + i]![x + j]!.isRevealed = true;
                stepsX.add(x + j);
                stepsY.add(y + i);
                max++;
              }
            }
          }
          revealAround = false;
        }
      }
      if (!_values[y]![x]!.isMine) points += max;
    }
    if (_values[y]![x]!.isMine) {
      return 1;
    }
    return 0;
  }

  void toggleFlag(int x, int y) {
    _values[y]![x]!.flagged = !_values[y]![x]!.flagged;
  }
}
