import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';

import 'package:nojcasts/components/podcast_tile.dart';
import 'package:nojcasts/models/podcast_entry.dart';
import 'package:nojcasts/view_models/podcast_viewmodel.dart';

class MainPage extends StatefulWidget {
  final AudioPlayer player;
  final Function(bool) updateShowNavBar;
  final PodcastViewmodel viewModel;

  const MainPage({super.key, required this.player, required this.updateShowNavBar, required this.viewModel});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late List<PodcastEntry> _allPodcasts;
  bool _loaded = false;

  Future<void> loadPodcasts() async {
    _allPodcasts = widget.viewModel.podcasts;
    setState(() {
      _loaded = true;
    });
  }

  @override
  void initState() {
    loadPodcasts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loaded) {
      return ListView.separated(
        itemBuilder: (BuildContext ctx, int index) {
          return PodcastTile(
            podcastDbEntry: _allPodcasts.elementAt(index),
            player: widget.player,
            loadPodcasts: loadPodcasts,
            updateShowNavBar: widget.updateShowNavBar,
          );
        },
        separatorBuilder: (BuildContext ctx, int index) {
          return const SizedBox(height: 8.0);
        },
        itemCount: _allPodcasts.length,
        padding: const EdgeInsets.all(8.0),
      );
    } else {
      return const Center(
        child: Text('Loading Podcasts'),
      );
    }
  }
}
