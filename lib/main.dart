import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final game = Game();
  PlatformDispatcher.instance.onBeginFrame = game.onBeginFrame;
  PlatformDispatcher.instance.scheduleFrame();
}

// Static values

// Game setting
final kBackgroundPaint = Paint()..color = Colors.white;
final kGamePaint = Paint()..color = Colors.black;
const kGameRows = 60;
const kGameColumns = 44;
const kGameTilesize = 20.0;
const kGameW = kGameColumns * kGameTilesize;
const kGameH = kGameRows * kGameTilesize;
const kGameRectBackground = Rect.fromLTWH(0, 0, kGameW, kGameH);

// Pac-man settings
const kPacmanSize = kGameTilesize;
final kPacmanPaint = Paint()..color = Colors.yellow;

class Game {
  void onBeginFrame(Duration timeStamp) {
    PlatformDispatcher.instance.scheduleFrame();
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // Use canvas to draw
    // Draw background
    canvas.drawRect(Rect.largest, kBackgroundPaint);

    // Draw game area
    canvas.drawRect(kGameRectBackground, kGamePaint);

    // Draw pac-man
    canvas.drawCircle(const Offset(100, 100), kPacmanSize / 2, kPacmanPaint);

    final picture = recorder.endRecording();
    final sceneBuilder = SceneBuilder();
    sceneBuilder.addPicture(const Offset(150, 300), picture);
    final scene = sceneBuilder.build();
    PlatformDispatcher.instance.views.first.render(scene);
  }
}
