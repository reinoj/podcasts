import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nojcasts/podcast_overview.dart';

import 'package:xml/xml.dart';
import 'package:path_provider/path_provider.dart';

import 'podcast.dart';

Future<PodcastInfo?> getRSS(BuildContext context) async {
  final AssetBundle rootBundleContext = DefaultAssetBundle.of(context);
  XmlDocument document = await getXmlDocumentFromFile(rootBundleContext, 'assets/morning_somewhere.xml');

  Iterable<XmlElement> channelIter = document.findAllElements('channel');
  if (channelIter.isEmpty) {
    developer.log('No channel element in XML.');
    return null;
  }
  XmlElement channel = channelIter.single;

  PodcastInfo? podcastInfo = getPodcastInfo(channel, true);
  if (null == podcastInfo) {
    return null;
  }

  return podcastInfo;
}

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

    setState(() {
      _allPodcasts = List<PodcastOverview>.from(profileJson['podcasts']);
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
      );
    } else {
      return const Center(
        child: Text('Loading Podcasts'),
      );
    }
  }
}

class PodcastScaffold extends StatelessWidget {
  const PodcastScaffold({super.key, required this.podcastInfo});

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

class PodcastTile extends StatelessWidget {
  const PodcastTile({super.key, required this.podcastOverview});
  final PodcastOverview podcastOverview;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 3.0),
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Text(
            '${podcastOverview.title}',
            style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}
