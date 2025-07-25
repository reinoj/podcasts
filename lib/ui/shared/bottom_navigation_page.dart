import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nojcasts/ui/shared/bottom_sheet_player.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({
    super.key,
    required this.player,
    required this.child,
  });

  final StatefulNavigationShell child;
  final AudioPlayer player;
  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  bool showPlayer = false;

  @override
  void initState() {
    widget.player.onPlayerStateChanged.listen((it) {
      switch (it) {
        case PlayerState.stopped:
        case PlayerState.disposed:
          setState(() {
            showPlayer = false;
          });
          break;
        case PlayerState.playing:
        case PlayerState.paused:
        case PlayerState.completed:
          setState(() {
            showPlayer = true;
          });
          break;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        centerTitle: true,
        title: const Text('nojcasts'),
      ),
      body: SafeArea(
        child: widget.child,
      ),
      bottomSheet: showPlayer ? BottomSheetPlayer(player: widget.player) : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: widget.child.currentIndex,
        onTap: (index) {
          widget.child.goBranch(
            index,
            initialLocation: index == widget.child.currentIndex,
          );
          setState(() {});
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
        ],
      ),
    );
  }
}
