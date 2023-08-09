import 'package:flutter/material.dart';
import 'package:music_box/util/particle_node.dart';
import 'package:music_box/util/particles.dart';
import 'package:spritewidget/spritewidget.dart';

class ParticleDisplay extends StatefulWidget {
  final Particles? assets;

  ParticleDisplay({this.assets});

  @override
  State<StatefulWidget> createState() => ParticleDisplayState();
}

class ParticleDisplayState extends State<ParticleDisplay> {
  ParticleDisplayNode? _timeDisplayNode;

  @override
  void initState() {
    super.initState();

    _timeDisplayNode =
        ParticleDisplayNode(assets: widget.assets!);

  }

  @override
  void didUpdateWidget(ParticleDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SpriteWidget(_timeDisplayNode!);
  }
}

class ParticleDisplayNode extends NodeWithSize {
  final Particles? assets;

  ParticleDisplayNode({this.assets}) : super(assets!.displaySize) {
    var fireworks = ParticleNode(
      assets: assets!,
      size: assets!.displaySize,
    );
    fireworks.zPosition = 1.0;

    addChild(fireworks);
  }

  // Call once a second to add a new animated time.
  void animateTime(DateTime dateTime) {

  }
}
