import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SliderBar extends StatelessWidget {
  final AudioPlayer player;
  final Duration? position;
  final Duration? duration;

  const SliderBar({super.key, required this.player, required this.position, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Slider(
      activeColor: Theme.of(context).colorScheme.secondary,
      value: (position != null && duration != null && position!.inMilliseconds > 0 && duration!.inMilliseconds > 0)
          ? position!.inMilliseconds / duration!.inMilliseconds
          : 0.0,
      onChanged: (double value) {
        if (duration == null) {
          return;
        }
        final double position = value * duration!.inMilliseconds;
        player.seek(Duration(milliseconds: position.round()));
      },
    );
  }
}
