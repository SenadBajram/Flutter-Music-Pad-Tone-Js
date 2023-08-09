import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';

var _pathFireworkParticle = 'assets/images/particle.png';

class Particles {


  SpriteTexture get textureNumberOutline => _textureNumberOutline!;
  SpriteTexture? _textureNumberOutline;

  SpriteTexture get textureFirework => _textureFirework!;
  SpriteTexture? _textureFirework;

  double get gravitySpeed => _gravitySpeed;
  double _gravitySpeed = -500.0;

  ImageMap? _images;
  bool isSoundEnabled = false;

  Color get fireworkColor => _fireworkColor;
  int get getUserId => _userId;

  Color _fireworkColor = Colors.red;
  Offset? offset;
  Size displaySize = Size(800.0, 800.0);
  int _userId = 0;

  void setColor(Color color) {
    _fireworkColor = color;
  }

  void setUser(int userId) {
    _userId = userId;
  }

  void setSpeed(double speed) {
    _gravitySpeed = speed;
  }

  Future<void> load() async {
    _images = ImageMap(rootBundle);
    await _images!.load([
      _pathFireworkParticle,
    ]);
    _textureFirework = SpriteTexture(_images![_pathFireworkParticle]);
  }
}