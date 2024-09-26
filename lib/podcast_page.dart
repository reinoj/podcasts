import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'podcast.dart';

class PodcastPage extends StatefulWidget {
  const PodcastPage({super.key, required this.initialPodcastInfo, required this.rssUrl});

  final PodcastInfo initialPodcastInfo;
  final String rssUrl;

  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  late PodcastInfo _podcastInfo;

  @override
  void initState() {
    _podcastInfo = widget.initialPodcastInfo;
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
      body: ListView.separated(
        itemBuilder: (BuildContext ctx, int index) {
          return EpisodeTile(podcastItem: _podcastInfo.items.elementAt(index));
        },
        separatorBuilder: (BuildContext ctx, int index) {
          return const SizedBox(height: 8.0);
        },
        itemCount: _podcastInfo.items.length,
        padding: const EdgeInsets.all(8.0),
      ),
    );
  }
}

class EpisodeTile extends StatefulWidget {
  const EpisodeTile({super.key, required this.podcastItem});

  final PodcastItem podcastItem;

  @override
  State<EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<EpisodeTile> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _player.play(UrlSource(widget.podcastItem.mp3Url));
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
              widget.podcastItem.title,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.podcastItem.pubDate,
                  style: const TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
                ),
                Text(
                  '${widget.podcastItem.duration_min} min',
                  style: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
                )
              ],
            ),
            Text(
              widget.podcastItem.description,
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
