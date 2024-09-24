import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nojcasts/globals.dart';

import 'package:xml/xml.dart';

import 'podcast.dart';
import 'podcast_overview.dart';
import 'profile.dart';

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

    PodcastInfo? podcastInfo = getPodcastInfo(document, false);
    if (null == podcastInfo) {
      SnackBar snackBar = const SnackBar(content: Text('Unable to serialize RSS feed.'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return;
    }

    Map<String, dynamic> profileMap = await getProfile();
    Profile profile = Profile.fromJson(profileMap);
    // List<PodcastOverview> allPodcasts = List<PodcastOverview>.from(profile['podcasts']);
    bool exists = false;
    for (int i = 0; i < profile.podcasts.length; i++) {
      if (profile.podcasts.elementAt(i).title == podcastInfo.title) {
        exists = true;
        break;
      }
    }

    if (exists) {
      SnackBar snackBar = SnackBar(content: Text('Already have ${podcastInfo.title} RSS feed saved.'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      Globals? globals = Globals.getGlobals();
      if (globals != null) {
        File wFile = File('${globals.podcastPath}/${podcastInfo.title}.xml');
        wFile.writeAsStringSync(document.toString());

        profile.podcasts.add(PodcastOverview(title: podcastInfo.title, url: _addController.text));

        File profileWFile = File('${globals.nojcastsPath}/profile.json');
        profileWFile.writeAsStringSync(jsonEncode(Profile(podcasts: profile.podcasts).toJson()));

        SnackBar snackBar = SnackBar(content: Text('Successfully added RSS feed for ${podcastInfo.title}.'));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
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
