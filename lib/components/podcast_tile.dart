import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:nojcasts/data/podcast_overview.dart';

import 'package:nojcasts/pages/podcast_page.dart';
import 'package:nojcasts/globals.dart';
import 'package:nojcasts/components/podcast.dart';

class PodcastTile extends StatefulWidget {
  final PodcastOverview podcastOverview;
  final Function() loadProfile;
  final AudioPlayer player;

  const PodcastTile({super.key, required this.podcastOverview, required this.loadProfile, required this.player});

  @override
  State<PodcastTile> createState() => _PodcastTileState();
}

class _PodcastTileState extends State<PodcastTile> {
  // late File _img;
  late Image _img;

  void loadImg() {
    imageCache.clear();
    Globals? globals = Globals.getGlobals();
    if (globals != null) {
      File img = File('${globals.imagePath}/${widget.podcastOverview.title}.jpg');
      if (!img.existsSync()) {
        img = File('${globals.imagePath}/${widget.podcastOverview.title}.png');
      }
      setState(() {
        _img = Image.file(
          img,
          width: 75.0,
          height: 75.0,
          fit: BoxFit.fill,
        );
      });
    }
  }

  @override
  void initState() {
    loadImg();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        PodcastInfo? podcastInfo = await getPodcastInfoFromFile(widget.podcastOverview.title);
        if (context.mounted) {
          if (podcastInfo == null) {
            SnackBar snackBar = const SnackBar(content: Text('Unable to serialize RSS feed.'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            return;
          }

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PodcastPage(
                initialPodcastInfo: podcastInfo,
                rssUrl: widget.podcastOverview.url,
                player: widget.player,
              ),
            ),
          );
          widget.loadProfile();
          loadImg();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline, width: 3.0),
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            _img,
            const SizedBox(width: 8.0),
            Text(
              widget.podcastOverview.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20.0, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
