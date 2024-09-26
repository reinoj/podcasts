import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

const double bottomSheetHeight = 50.0;

class BottomSheetPlayer extends StatefulWidget {
  const BottomSheetPlayer({super.key, required this.player});

  final AudioPlayer player;

  @override
  State<BottomSheetPlayer> createState() => _BottomSheetPlayerState();
}

class _BottomSheetPlayerState extends State<BottomSheetPlayer> {
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
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      height: bottomSheetHeight,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          IconButton(
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
          ),
        ],
      ),
    );
  }
}

bool showBottomSheetPlayer(PlayerState state) {
  if (state == PlayerState.playing || state == PlayerState.paused || state == PlayerState.completed) {
    return true;
  }

  return false;
}
