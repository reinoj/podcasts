import 'package:flutter/material.dart';

import 'podcast.dart';

class PodcastPage extends StatelessWidget {
  const PodcastPage({super.key, required this.podcastInfo});

  final PodcastInfo podcastInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(podcastInfo.title),
      ),
      body: ListView.separated(
        itemBuilder: (BuildContext ctx, int index) {
          return EpisodeTile(podcastItem: podcastInfo.items.elementAt(index));
        },
        separatorBuilder: (BuildContext ctx, int index) {
          return const SizedBox(height: 8.0);
        },
        itemCount: podcastInfo.items.length,
        padding: const EdgeInsets.all(8.0),
      ),
    );
  }
}

class EpisodeTile extends StatelessWidget {
  const EpisodeTile({super.key, required this.podcastItem});

  final PodcastItem podcastItem;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
