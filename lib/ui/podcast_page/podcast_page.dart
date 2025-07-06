import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:nojcasts/ui/main_page/podcast_viewmodel.dart';

import 'package:nojcasts/ui/shared/bottom_sheet_player.dart';
import 'package:nojcasts/ui/podcast_page/episode_tile.dart';
import 'package:nojcasts/services/rss_xml.dart';
import 'package:nojcasts/types/podcast_info.dart';
import 'package:nojcasts/utils/result.dart';

class PodcastPage extends StatefulWidget {
  final String title;
  // final PodcastInfo initialPodcastInfo;
  final MainViewmodel viewmodel;
  final AudioPlayer player;
  final Function() updateShowPlayer;

  const PodcastPage({
    super.key,
    required this.title,
    // required this.initialPodcastInfo,
    required this.viewmodel,
    required this.player,
    required this.updateShowPlayer,
  });

  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  bool isReady = false;
  PodcastInfo? _podcastInfo;

  void loadPodcastInfo() async {
    _podcastInfo = await getPodcastInfoFromJson(widget.title);
    setState(() {
      isReady = true;
    });
  }

  @override
  void initState() {
    super.initState();

    loadPodcastInfo();
    widget.updateShowPlayer();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Text('Loading...');
    }

    if (_podcastInfo == null) {
      return Text('Error Loading Podcast Page');
    }

    final appBar = AppBar(
      actions: [
        IconButton(
          onPressed: () async {
            Result<String> result = await widget.viewmodel.getRssFromPodcast(
              widget.title,
            );
            bool succeeded = false;
            switch (result) {
              case Ok<String>():
                succeeded = await trySaveRss(result.value, true);
                break;
              case Error<String>():
                SnackBar snackBar = const SnackBar(
                  content: Text('Unable to retrieve podcast.'),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                return;
            }

            PodcastInfo? pI = await getPodcastInfoFromJson(widget.title);
            if (pI == null) {
              SnackBar snackBar = const SnackBar(
                content: Text('Unable to open podcast\'s json file.'),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              return;
            }

            setState(() {
              _podcastInfo = pI;
            });

            if (succeeded) {
              SnackBar snackBar = const SnackBar(
                content: Text('Successfully updated RSS feed.'),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            } else {
              SnackBar snackBar = const SnackBar(
                content: Text(
                  'Unable to update RSS feed. Yell at the developer for the reason.',
                ),
              );
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
      title: Text(widget.title),
    );

    return Padding(
      padding: showBottomSheetPlayer(widget.player.state)
          ? const EdgeInsets.only(bottom: bottomSheetHeight)
          : const EdgeInsets.only(bottom: 0.0),
      child: ListView.separated(
        itemBuilder: (BuildContext ctx, int index) {
          return EpisodeTile(
            podcastItem: _podcastInfo!.items.elementAt(index),
            player: widget.player,
            index: index,
            updateShowPlayer: widget.updateShowPlayer,
          );
        },
        separatorBuilder: (BuildContext ctx, int index) {
          return const SizedBox(height: 8.0);
        },
        itemCount: _podcastInfo!.items.length,
        padding: const EdgeInsets.all(8.0),
      ),
    );
  }
}
