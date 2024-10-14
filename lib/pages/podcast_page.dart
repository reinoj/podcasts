import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:nojcasts/components/bottom_sheet_player.dart';
import 'package:nojcasts/components/episode_tile.dart';
import 'package:xml/xml.dart';

import '../components/podcast.dart';

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
  // int _currentIndex = -1;

  void updateShowPlayer() {
    setState(() {
      _showPlayer = showBottomSheetPlayer(widget.player.state);
    });
  }

  // void updateIndex(int newIndex) {
  //   _currentIndex = newIndex;
  // }

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
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
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
              index: index,
              updateShowPlayer: updateShowPlayer,
              // updateIndex: updateIndex,
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
