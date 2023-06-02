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

  final Pacman pacman = Pacman();

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
    pacman.render(canvas);

    final picture = recorder.endRecording();
    final sceneBuilder = SceneBuilder();
    sceneBuilder.addPicture(const Offset(200, 0), picture);
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
