import 'dart:async';
// import 'dart:developer' as developer;
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:nojcasts/ui/shared/slider_bar.dart';

const double bottomSheetHeight = 120.0;
// ignore: constant_identifier_names
const int fifteenSeconds_ms = 15000;

String formatDuration(Duration d) {
  String fullString = d.toString();
  // remove the hours from the string if it is less than 1 hour long
  int start = d.inHours == 0 ? 2 : 0;
  // remove the microseconds from the string
  return fullString.substring(start, fullString.length - 7);
}

class BottomSheetPlayer extends StatefulWidget {
  const BottomSheetPlayer({super.key, required this.player});

  final AudioPlayer player;

  @override
  State<BottomSheetPlayer> createState() => _BottomSheetPlayerState();
}

class _BottomSheetPlayerState extends State<BottomSheetPlayer> {
  // audioplayers example https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers/example/lib/components/player_widget.dart
  Duration? _position;
  Duration? _duration;

  String _positionString = '00:00';
  String _durationString = '00:00';

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _completionSubscription;

  final List<Icon> _playPauseButton = [
    const Icon(
      Icons.play_circle_outline,
      size: 40.0,
    ),
    const Icon(
      Icons.pause_circle_outline,
      size: 40.0,
    )
  ];
  late int _playPauseState;

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
              _positionString = formatDuration(_position!);
            },
          ),
        );
    widget.player.getDuration().then(
          (currentDuration) => setState(
            () {
              _duration = currentDuration;
              _durationString = formatDuration(_duration!);
            },
          ),
        );
    _initStreams();

    if (widget.player.state == PlayerState.paused) {
      setState(() {
        _playPauseState = 0;
      });
    } else {
      setState(() {
        _playPauseState = 1;
      });
    }
    super.initState();
  }

  void _initStreams() {
    _positionSubscription = widget.player.onPositionChanged.listen(
      (position) => setState(
        () {
          _position = position;
          _positionString = formatDuration(_position!);
        },
      ),
    );

    _durationSubscription = widget.player.onDurationChanged.listen(
      (duration) => setState(
        () {
          _duration = duration;
          _durationString = formatDuration(_duration!);
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
    return Container(
      color: Theme.of(context).colorScheme.onSecondary,
      height: bottomSheetHeight,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SliderBar(
            player: widget.player,
            position: _position,
            duration: _duration,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_positionString),
              rewindButton(context),
              playPauseButton(context),
              fastForwardButton(context),
              Text(_durationString)
            ],
          ),
        ],
      ),
    );
  }

  IconButton rewindButton(BuildContext context) {
    return IconButton(
      highlightColor: Theme.of(context).colorScheme.secondary,
      hoverColor: Theme.of(context).colorScheme.secondary,
      onPressed: () async {
        Duration? currentPosition = await widget.player.getCurrentPosition();
        if (currentPosition == null) {
          return;
        }
        int rewind15 =
            max(currentPosition.inMilliseconds - fifteenSeconds_ms, 0);
        widget.player.seek(Duration(milliseconds: rewind15));
      },
      icon: const Icon(
        Icons.rotate_90_degrees_ccw_outlined,
        size: 40.0,
      ),
    );
  }

  IconButton playPauseButton(BuildContext context) {
    return IconButton(
      highlightColor: Theme.of(context).colorScheme.secondary,
      hoverColor: Theme.of(context).colorScheme.secondary,
      onPressed: () {
        if (widget.player.state == PlayerState.playing) {
          widget.player.pause();
          setState(() {
            _playPauseState = 0;
          });
        } else if (widget.player.state == PlayerState.paused) {
          widget.player.resume();
          setState(() {
            _playPauseState = 1;
          });
        }
      },
      icon: _playPauseButton[_playPauseState],
    );
  }

  IconButton fastForwardButton(BuildContext context) {
    return IconButton(
      highlightColor: Theme.of(context).colorScheme.secondary,
      hoverColor: Theme.of(context).colorScheme.secondary,
      onPressed: () async {
        Duration? currentPosition = await widget.player.getCurrentPosition();
        if (currentPosition == null) {
          return;
        }
        Duration? playerDuration = await widget.player.getDuration();
        if (playerDuration == null) {
          return;
        }
        int fastforward15 = min(
            currentPosition.inMilliseconds + fifteenSeconds_ms,
            playerDuration.inMilliseconds);
        widget.player.seek(Duration(milliseconds: fastforward15));
      },
      icon: const Icon(
        Icons.rotate_90_degrees_cw_outlined,
        size: 40.0,
      ),
    );
  }
}

bool showBottomSheetPlayer(PlayerState state) {
  if (state == PlayerState.playing ||
      state == PlayerState.paused ||
      state == PlayerState.completed) {
    return true;
  }

  return false;
}
