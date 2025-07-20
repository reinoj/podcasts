import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:nojcasts/main.dart';
import 'package:nojcasts/ui/home_page/podcast_tile.dart';

class HomePage extends StatelessWidget {
  final AudioPlayer player;

  const HomePage({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dbProvider.onPodcasts(),
      builder: (context, snapshot) {
        var podcasts = snapshot.data;
        if (podcasts == null) {
          return Center(child: CircularProgressIndicator());
        }
        if (podcasts.isEmpty) {
          return Center(child: Text('No Podcasts'));
        }

        return ListView.separated(
          itemCount: podcasts.length,
          itemBuilder: (context, index) {
            return PodcastTile(player: player, podcast: podcasts[index]!);
          },
          separatorBuilder: (BuildContext ctx, int index) {
            return const SizedBox(height: 8.0);
          },
          padding: const EdgeInsets.all(8.0),
        );
      },
    );
  }
}
