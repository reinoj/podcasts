import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nojcasts/podcast_overview.dart';

import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import 'podcast.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void getNewRSS(BuildContext context) async {
    XmlDocument? document = await getXmlDocumentFromURL(_addController.text);
    if (null == document) {
      SnackBar snackBar = const SnackBar(content: Text('Issue getting RSS feed.'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return;
    }

    Iterable<XmlElement> channelIter = document.findAllElements('channel');
    if (channelIter.isEmpty) {
      SnackBar snackBar = const SnackBar(content: Text('Invalid XML from RSS feed.'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return;
    }
    XmlElement channel = channelIter.single;

    PodcastInfo? podcastInfo = getPodcastInfo(channel, false);
    if (null == podcastInfo) {
      SnackBar snackBar = const SnackBar(content: Text('Unable to serialize RSS feed.'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return;
    }

    Directory directory = await getApplicationDocumentsDirectory();
    File wFile = File('${directory.path}/nojcasts/${podcastInfo.title}.xml');
    wFile.writeAsStringSync(document.toString());

    Map<String, dynamic> profile = await getProfile();
    List<PodcastOverview> allPodcasts = List<PodcastOverview>.from(profile['podcasts']);
    for (int i = 0; i < allPodcasts.length; i++) {
      if (allPodcasts.elementAt(i).title == podcastInfo.title) {
        break;
      }
    }

    if (true) {}

    SnackBar snackBar = SnackBar(content: Text('Successfully added RSS feed for ${podcastInfo.title}.'));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    _addController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
          child: TextFormField(
            controller: _addController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter RSS link',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => getNewRSS(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          ),
          child: const Text('Add RSS Feed'),
        ),
      ],
    );
  }
}
