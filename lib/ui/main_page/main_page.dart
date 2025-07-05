import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';

import 'package:nojcasts/ui/main_page/podcast_tile.dart';
import 'package:nojcasts/models/podcast_entry.dart';
import 'package:nojcasts/ui/main_page/podcast_viewmodel.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  final AudioPlayer player;
  final Function(bool) updateShowNavBar;
  final MainViewmodel viewModel;

  const MainPage(
      {super.key,
      required this.player,
      required this.updateShowNavBar,
      required this.viewModel});

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
    super.initState();

    loadPodcasts();
    // widget.viewModel.podcasts.addListener(() {
    //   _allPodcasts = widget.viewModel.podcasts;
    //   log('Update new podcast');
    // });
  }

  @override
  void dispose() {
    // widget.viewModel.removeListener(listener)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loaded) {
      return ListView.separated(
        itemBuilder: (BuildContext ctx, int index) {
          return PodcastTile(
            // podcastDbEntry: Consumer<MainViewmodel>(
            //   builder: (context, value, child) {
            //     return value.podcasts.elementAt(index);
            //   },
            // ),
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
