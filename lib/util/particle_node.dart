
import 'package:flutter/material.dart';
import 'package:music_box/util/particles.dart';
import 'package:spritewidget/spritewidget.dart';

const _avgTimeBetweenExplosions = .5;

/// The fireworks node animates continuous fireworks.
class ParticleNode extends NodeWithSize {
  final Particles? assets;

  ParticleNode({this.assets, Size? size}) : super(size);

  double _countDown = 0.0;

  double _playSound = 4.0;

  @override
  void update(double dt) {
    // Called before rendering each frame, check if we should add any new
    // explosions.

    if (_countDown <= 0.0) {
      addExplosion();
      _countDown = randomDouble() * _avgTimeBetweenExplosions * 4.0;
    }

    if(assets!.offset!=null) {
      addExplosion();
    }

    if(_playSound <= 0.0) {
      _playSound = 4.0;
    }

    _countDown -= dt;
    _playSound -= dt;

    //print("Time $_playSound");
  }

  // Get a random color suitable for fireworks
  Color _randomExplosionColor() {
    return assets!.fireworkColor;
  }

  // Adds an explosion to the fireworks
  void addExplosion() {

    //print("addExplosion");
    if(assets!=null) {
      try {
        if(assets?.textureFirework!=null) {
          Color startColor = assets!.fireworkColor;
          Color endColor = startColor.withAlpha(0);

          // Use SpriteWidget's particle system to render the fireworks' explosions.
          ParticleSystem system = ParticleSystem(
            assets!.textureFirework,
            numParticlesToEmit: 5,
            emissionRate: 100.0,
            rotateToMovement: true,
            startRotation: 90.0,
            endRotation: 90.0,
            speed: 10.0,
            speedVar: 5.0,
            startSize: 0.50,
            startSizeVar: 0.15,
            gravity: Offset(assets!.gravitySpeed, 30.0),
            colorSequence:
            ColorSequence.fromStartAndEndColor(startColor, endColor),
          );

          // Place the explosion at a random position within the size bounds.
          if (assets!.offset != null) {
            system.position = assets?.offset ?? Offset(0, 0);
          } else {
            system.position =
                Offset(randomDouble() * size.width, randomDouble() * size.height);
          }

          if(assets!.getUserId==-1) {
            system.removeFromParent();
          } else {
            addChild(system);
          }
        }
      } catch(e) {

      }


    }
  }
}