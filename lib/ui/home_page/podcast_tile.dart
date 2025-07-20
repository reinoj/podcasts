import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nojcasts/main.dart';
import 'package:nojcasts/models/podcast.dart';
import 'package:nojcasts/types/podcast_info.dart';
import 'package:nojcasts/services/rss_xml.dart';

class PodcastTile extends StatefulWidget {
  final AudioPlayer player;
  final Podcast podcast;
  // final Function(bool) updateShowNavBar;

  const PodcastTile({
    super.key,
    required this.player,
    required this.podcast,
    // required this.updateShowNavBar,
  });

  @override
  State<PodcastTile> createState() => _PodcastTileState();
}

class _PodcastTileState extends State<PodcastTile> {
  Image? _img;

  Future<void> loadImg() async {
    imageCache.clear();

    File img = File(
      '${globals.globals!.imagePath}/${widget.podcast.title.v}.jpg',
    );
    if (!img.existsSync()) {
      img = File(
        '${globals.globals!.imagePath}/${widget.podcast.title.v}.png',
      );
    }

    setState(() {
      _img = Image.file(img, width: 75.0, height: 75.0, fit: BoxFit.fill);
    });
  }

  @override
  void initState() {
    loadImg();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_img == null) {
      return Text('Loading...');
    }
    return GestureDetector(
      onTap: () async {
        PodcastInfo? podcastInfo = await getPodcastInfoFromJson(
          widget.podcast.title.v ?? 'empty',
        );
        if (context.mounted) {
          if (podcastInfo == null) {
            SnackBar snackBar = const SnackBar(
              content: Text('Unable to serialize RSS feed.'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            return;
          }

          context.go('/podcast/${widget.podcast.title.v!}');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 3.0,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        ),
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            _img!,
            const SizedBox(width: 8.0),
            Text(
              widget.podcast.title.v ?? 'empty',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
