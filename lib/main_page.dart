import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';

import 'package:nojcasts/components/podcast_tile.dart';
import 'package:nojcasts/podcast_overview.dart';
import 'package:nojcasts/profile.dart';

class MainPage extends StatefulWidget {
  final AudioPlayer player;

  const MainPage({super.key, required this.player});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<PodcastOverview> _allPodcasts = [];
  bool _loaded = false;

  void loadProfile() async {
    Map<String, dynamic> profileJson = await getProfile();
    Profile profile = Profile.fromJson(profileJson);

    setState(() {
      _allPodcasts = profile.podcasts;
      _loaded = true;
    });
  }

  @override
  void initState() {
    loadProfile();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loaded) {
      return ListView.separated(
        itemBuilder: (BuildContext ctx, int index) {
          return PodcastTile(
            podcastOverview: _allPodcasts.elementAt(index),
            loadProfile: loadProfile,
            player: widget.player,
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
