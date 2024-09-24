import 'dart:io';

import 'package:flutter/material.dart';

import 'globals.dart';
import 'podcast.dart';
import 'podcast_overview.dart';
import 'podcast_page.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          return PodcastTile(podcastOverview: _allPodcasts.elementAt(index));
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

class PodcastTile extends StatefulWidget {
  const PodcastTile({super.key, required this.podcastOverview});
  final PodcastOverview podcastOverview;

  @override
  State<PodcastTile> createState() => _PodcastTileState();
}

class _PodcastTileState extends State<PodcastTile> {
  late File _img;

  @override
  void initState() {
    Globals? globals = Globals.getGlobals();
    if (globals != null) {
      _img = File('${globals.imagePath}/${widget.podcastOverview.title}.jpg');
      if (!_img.existsSync()) {
        _img = File('${globals.imagePath}/${widget.podcastOverview.title}.png');
      }
    }
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

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PodcastPage(
                podcastInfo: podcastInfo,
              ),
            ),
          );
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
            // Expanded(
            // child:
            Image.file(
              _img,
              width: 75.0,
              height: 75.0,
              fit: BoxFit.contain,
            ),
            // ),
            const SizedBox(width: 8.0),
            Text(
              widget.podcastOverview.title,
              style: TextStyle(fontSize: 18.0, color: Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
