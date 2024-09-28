import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SliderBar extends StatefulWidget {
  final AudioPlayer player;

  const SliderBar({super.key, required this.player});

  @override
  State<SliderBar> createState() => _SliderBarState();
}

class _SliderBarState extends State<SliderBar> {
  // audioplayers example https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers/example/lib/components/player_widget.dart
  Duration? _position;
  Duration? _duration;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _completionSubscription;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    widget.player.getCurrentPosition().then(
          (currentPosition) => setState(
            () {
              _position = currentPosition;
            },
          ),
        );
    widget.player.getDuration().then(
          (currentDuration) => setState(
            () {
              _duration = currentDuration;
            },
          ),
        );
    _initStreams();
    super.initState();
  }

  void _initStreams() {
    _positionSubscription = widget.player.onPositionChanged.listen(
      (position) => setState(
        () {
          _position = position;
        },
      ),
    );

    _durationSubscription = widget.player.onDurationChanged.listen(
      (duration) => setState(
        () {
          _duration = duration;
        },
      ),
    );

    _completionSubscription = widget.player.onPlayerComplete.listen(
      (_) => setState(
        () {
          _position = Duration.zero;
        },
      ),
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _completionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      activeColor: Theme.of(context).colorScheme.onSecondary,
      value: (_position != null && _duration != null && _position!.inMilliseconds > 0 && _duration!.inMilliseconds > 0)
          ? _position!.inMilliseconds / _duration!.inMilliseconds
          : 0.0,
      onChanged: (double value) {
        if (_duration == null) {
          return;
        }

        final double position = value * _duration!.inMilliseconds;
        widget.player.seek(Duration(milliseconds: position.round()));
      },
    );
  }
}
