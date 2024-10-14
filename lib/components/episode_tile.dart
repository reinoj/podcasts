import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:nojcasts/components/podcast.dart';

class EpisodeTile extends StatelessWidget {
  const EpisodeTile({
    super.key,
    required this.podcastItem,
    required this.player,
    required this.index,
    required this.updateShowPlayer,
    // required this.updateIndex,
  });

  final PodcastItem podcastItem;
  final AudioPlayer player;
  final int index;
  final Function() updateShowPlayer;
  // final Function(int) updateIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await player.setSource(UrlSource(podcastItem.mp3Url));
        await player.resume();
        updateShowPlayer();
        // updateIndex(index);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline, width: 3.0),
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        ),
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              podcastItem.title,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  podcastItem.pubDate,
                  style: const TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
                ),
                Text(
                  '${podcastItem.duration_min} min',
                  style: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
                )
              ],
            ),
            Text(
              podcastItem.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
