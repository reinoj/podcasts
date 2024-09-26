import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:nojcasts/bottom_sheet_player.dart';
import 'package:xml/xml.dart';

import 'podcast.dart';

class PodcastPage extends StatefulWidget {
  const PodcastPage({super.key, required this.initialPodcastInfo, required this.rssUrl, required this.player});

  final PodcastInfo initialPodcastInfo;
  final String rssUrl;
  final AudioPlayer player;

  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  late PodcastInfo _podcastInfo;
  late bool _showPlayer;

  void updateShowPlayer() {
    setState(() {
      _showPlayer = showBottomSheetPlayer(widget.player.state);
    });
  }

  @override
  void initState() {
    _podcastInfo = widget.initialPodcastInfo;
    updateShowPlayer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              bool succeeded = await downloadRss(widget.rssUrl, true);
              XmlDocument? document = await getXmlDocumentFromFile(_podcastInfo.title);
              if (document == null) {
                return;
              }

              PodcastInfo? pI = getPodcastInfo(document, true, true);
              if (pI == null) {
                return;
              }

              setState(() {
                _podcastInfo = pI;
              });
              if (succeeded) {
                SnackBar snackBar = const SnackBar(content: Text('Successfully updated RSS feed.'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              } else {
                SnackBar snackBar =
                    const SnackBar(content: Text('Unable to update RSS feed. Yell at the developer for the reason.'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              }
            },
            tooltip: 'Update',
            icon: const Icon(Icons.update),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(_podcastInfo.title),
      ),
      body: Padding(
        padding: showBottomSheetPlayer(widget.player.state)
            ? const EdgeInsets.only(bottom: bottomSheetHeight)
            : const EdgeInsets.only(bottom: 0.0),
        child: ListView.separated(
          itemBuilder: (BuildContext ctx, int index) {
            return EpisodeTile(
              podcastItem: _podcastInfo.items.elementAt(index),
              player: widget.player,
              updateShowPlayer: updateShowPlayer,
            );
          },
          separatorBuilder: (BuildContext ctx, int index) {
            return const SizedBox(height: 8.0);
          },
          itemCount: _podcastInfo.items.length,
          padding: const EdgeInsets.all(8.0),
        ),
      ),
      bottomSheet: _showPlayer ? BottomSheetPlayer(player: widget.player) : null,
    );
  }
}

class EpisodeTile extends StatelessWidget {
  const EpisodeTile({super.key, required this.podcastItem, required this.player, required this.updateShowPlayer});

  final PodcastItem podcastItem;
  final AudioPlayer player;
  final Function() updateShowPlayer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await player.setSource(UrlSource(podcastItem.mp3Url));
        await player.resume();
        updateShowPlayer();
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
