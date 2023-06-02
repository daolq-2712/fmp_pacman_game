import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final game = Game();
  PlatformDispatcher.instance.onBeginFrame = game.onBeginFrame;
  PlatformDispatcher.instance.onKeyData = game.onKeyData;
  PlatformDispatcher.instance.scheduleFrame();
}

enum MovingDirection { up, down, left, right }

class Game {
  // Game setting
  static const kRows = 30;
  static const kCols = 22;
  static const kTileSize = 20.0;
  static const kWidth = kCols * kTileSize;
  static const kHeight = kRows * kTileSize;
  static const kGameRectBackground = Rect.fromLTWH(0, 0, kWidth, kHeight);

  final kBackgroundPaint = Paint()..color = Colors.white;
  final kGamePaint = Paint()..color = Colors.black;
  
  final maze = Maze();
  final pacman = Pacman();

  void onBeginFrame(Duration timeStamp) {
    PlatformDispatcher.instance.scheduleFrame();
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // Update properties for game objects
    pacman.update(timeStamp);

    // Update pacman

    // Use canvas to draw
    // Draw background
    canvas.drawRect(Rect.largest, kBackgroundPaint);

    // Draw game area
    canvas.drawRect(kGameRectBackground, kGamePaint);

    // Draw game objects
    maze.render(canvas);
    pacman.render(canvas);

    final picture = recorder.endRecording();
    final sceneBuilder = SceneBuilder();
    sceneBuilder.addPicture(const Offset(100, 100), picture);
    final scene = sceneBuilder.build();
    PlatformDispatcher.instance.views.first.render(scene);
  }

  bool onKeyData(KeyData data) {
    pacman.onKeyData(data);
    return false;
  }
}

class Pacman {
// Pac-man settings
  static const kPacmanSize = Game.kTileSize;
  final kPacmanPaint = Paint()..color = Colors.yellow;
  static const kPacmanSpeed = 2.0;

  var x = 200.0;
  var y = 200.0;
  var direction = MovingDirection.up;

  void update(Duration timeStamp) {
    switch (direction) {
      case MovingDirection.up:
        y -= kPacmanSpeed;
        break;
      case MovingDirection.down:
        y += kPacmanSpeed;
        break;
      case MovingDirection.left:
        x -= kPacmanSpeed;
        break;
      case MovingDirection.right:
        x += kPacmanSpeed;
        break;
    }
  }

  void render(Canvas canvas) {
    canvas.drawCircle(Offset(x, y), kPacmanSize / 2, kPacmanPaint);
  }

  bool onKeyData(KeyData data) {
    if (data.type == KeyEventType.down) {
      final keyPressed = LogicalKeyboardKey(data.logical).keyLabel;
      switch (keyPressed) {
        case 'Arrow Up':
          direction = MovingDirection.up;
          return true;
        case 'Arrow Left':
          direction = MovingDirection.left;
          return true;
        case 'Arrow Down':
          direction = MovingDirection.down;
          return true;
        case 'Arrow Right':
          direction = MovingDirection.right;
          return true;
      }
    }
    return false;
  }
}

class Maze {
  static const kMazeRaw = '''11001001111010111110110
10010000011001101000110
01000001111100101101110
10011100010001111100110
10101100010111010001100
01000001010101110011111
00110110000011010010100
00100111010110010111000
01000100010001000011000
10001111011100000000100
11001001100001110010101
10110000001101000000101
10100011010001001010011
01110010000010101001101
00110010110000110111001
00000100100000110111101
01010011111010010100010
01010110110101111100100
10001000001110001011110
10001000111101110100111
11011001111001101101001
00011111111110100100011
10001110111010110010101
11011100000010011001101
00111010101100100111001
10010111010010001100001
10101001011001111100010
00100100100100000110011
10110010100001100001010
10010101011011001001010
00000101000011011111001''';

  final kMaze = kMazeRaw
      .split('\n')
      .map(
        (row) => row
            .trim()
            .split('')
            .map(
              (cell) => int.parse(cell),
            )
            .toList(),
      )
      .toList();

  final kWallsPaint = Paint()..color = Colors.blue;
  final kWallSize = Game.kTileSize * 0.8;

  void update(Duration timeStamp) {}

  void render(Canvas canvas) {
    for (var r = 0; r < Game.kRows; r++) {
      for (var c = 0; c < Game.kCols; c++) {
        if (kMaze[r][c] == 1) {
          canvas.drawRect(
              Rect.fromLTWH(
                Game.kTileSize * c + Game.kTileSize * 0.1,
                Game.kTileSize * r + Game.kTileSize * 0.1,
                kWallSize,
                kWallSize,
              ),
              kWallsPaint);
        }
      }
    }
  }
}
