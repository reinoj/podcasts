import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:nojcasts/components/slider_bar.dart';

const double bottomSheetHeight = 120.0;

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
      color: Theme.of(context).colorScheme.secondary,
      height: bottomSheetHeight,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SliderBar(player: widget.player),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                highlightColor: Theme.of(context).colorScheme.onSecondary,
                hoverColor: Theme.of(context).colorScheme.onSecondary,
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
