import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import 'package:nojcasts/db/podcast_db.dart';
import 'package:nojcasts/db/podcast_db_entry.dart';
import 'package:nojcasts/types/podcast_info.dart';
import 'package:nojcasts/types/podcast_item.dart';
import 'package:nojcasts/globals.dart';

Future<bool> trySaveRss(String url, bool update) async {
  XmlDocument? document = await getXmlDocumentFromURL(url);
  if (null == document) {
    return false;
  }

  (String, PodcastInfo)? xmlRecord = getPodcastInfoFromXml(document, !update);
  if (xmlRecord == null) {
    return false;
  }

  String title = xmlRecord.$1;
  PodcastInfo podcastInfo = xmlRecord.$2;

  PodcastDb db = await PodcastDb.getInstance();
  List<PodcastDbEntry> savedPodcasts = await db.getPodcasts();
  bool exists = false;
  for (final podcast in savedPodcasts) {
    if (podcast.title == title) {
      exists = true;
      break;
    }
  }

  if (exists) {
    if (update) {
      return savePodcastInfoToFile(title, podcastInfo);
    } else {
      log('RSS feed is already saved.');
      return true;
    }
  } else {
    await db.insertPodcast(PodcastDbEntry(title, url));
    return savePodcastInfoToFile(title, podcastInfo);
  }
}

(String, PodcastInfo)? getPodcastInfoFromXml(XmlDocument document, bool saveImage) {
  Iterable<XmlElement> channelIter = document.findAllElements('channel');
  if (channelIter.isEmpty) {
    log('Invalid XML from RSS feed.');
    return null;
  }
  XmlElement channel = channelIter.single;

  XmlElement? title = findAndCheckForElement(channel, 'title');
  if (null == title) {
    return null;
  }

  XmlElement? hosts = findAndCheckForElement(channel, 'itunes:author');
  if (null == hosts) {
    return null;
  }

  if (saveImage) {
    XmlElement? image = findAndCheckForElement(channel, 'itunes:image');
    if (null == image) {
      return null;
    }
    savePodcastImage(image, title.innerText);
  }

  List<XmlElement> itemIter = channel.findElements('item').toList();

  List<PodcastItem> podcastItemList = List.empty(growable: true);
  for (XmlElement item in itemIter) {
    PodcastItem? podcastItem = getPodcastItem(item);
    if (null == podcastItem) {
      return null;
    }
    podcastItemList.add(podcastItem);
  }

  return (title.innerText, PodcastInfo(hosts.innerText, podcastItemList));
}

void savePodcastImage(XmlElement image, String title) async {
  String url = image.attributes.single.value;
  Uri uri = Uri.parse(url);
  if (!uri.isAbsolute) {
    log('URL is invalid');
    return null;
  }
  http.Response response = await http.get(uri);

  String fileType = url.substring(url.length - 3).toLowerCase();
  if ('jpg' != fileType && 'png' != fileType) {
    log('Unsupported image format "$fileType". Currently only jpg and png is supported.');
  }

  Directory directory = await getApplicationDocumentsDirectory();
  File wFile = File('${directory.path}/nojcasts/images/$title.$fileType');
  wFile.writeAsBytesSync(response.bodyBytes);
}

bool savePodcastInfoToFile(String title, PodcastInfo podcastInfo) {
  Globals? globals = Globals.getGlobals();
  if (globals == null) {
    log('Failed to get global variables.');
    return false;
  }

  File wFile = File('${globals.podcastPath}/$title.json');
  try {
    wFile.writeAsStringSync(jsonEncode(podcastInfo.toJson()));
  } on FileSystemException {
    log('Failed to save Json file.');
    return false;
  }

  return true;
}

PodcastInfo? getPodcastInfoFromJson(String title) {
  Globals? globals = Globals.getGlobals();
  if (globals == null) {
    log('Failed to get global variables.');
    return null;
  }

  File rFile = File('${globals.podcastPath}/$title.json');
  if (!rFile.existsSync()) {
    log('File "$title.json" does not exist');
    return null;
  }

  String contents = rFile.readAsStringSync();
  return PodcastInfo.fromJson(jsonDecode(contents));
}

XmlDocument? parseXmlString(String contents) {
  try {
    return XmlDocument.parse(contents);
  } on XmlParserException {
    log('XmlParserException: Error parsing XML document');
  } on XmlTagException {
    log('XmlTagException: XML document end tag doesn\'t match the open tag.');
  } catch (e) {
    log('Error parsing XML: $e');
  }

  return null;
}

Future<XmlDocument?> getXmlDocumentFromURL(String url) async {
  Uri uri = Uri.parse(url);
  if (!uri.isAbsolute) {
    log('URL is invalid');
    return null;
  }
  http.Response response = await http.get(uri);

  return parseXmlString(response.body);
}

XmlElement? findAndCheckForElement(XmlElement root, String elementName) {
  Iterable<XmlElement> elementIter = root.findElements(elementName);
  if (elementIter.isEmpty) {
    log("No '$elementName' element in channel.");
    return null;
  }
  return elementIter.singleOrNull;
}

PodcastItem? getPodcastItem(XmlElement element) {
  XmlElement? xmlTitle = findAndCheckForElement(element, 'title');
  String title = xmlTitle?.innerText ?? '';

  String description = '';
  XmlElement? xmlDescription = findAndCheckForElement(element, 'description');
  if (xmlDescription != null) {
    // parse the paragraph tag
    Document p = parse(xmlDescription.innerText);
    if (p.body == null) {
      return null;
    }

    description = p.body!.text;
    if (description.isEmpty) {
      XmlElement? xmlSummary = findAndCheckForElement(element, 'itunes:summary');
      if (xmlSummary != null) {
        p = parse(xmlSummary.innerText);
        if (p.body != null) {
          description = p.body!.text;
        }
      }
    }
  }

  XmlElement? pubDate = findAndCheckForElement(element, 'pubDate');
  // just keep the day and date
  String shortenedDate = pubDate?.innerText.substring(0, 16) ?? '';

  XmlElement? xmlDuration = findAndCheckForElement(element, 'itunes:duration');
  String textDuration = xmlDuration?.innerText ?? '0';
  int? durationS = int.tryParse(textDuration);
  int? durationMin;
  if (durationS == null) {
    List<String> splitDuration = textDuration.split(':');
    if (splitDuration.length == 2) {
      int? minuteIndex = int.tryParse(splitDuration[0]);
      if (minuteIndex != null) {
        durationMin = minuteIndex;
      }
    } else if (splitDuration.length == 3) {
      int? hourIndex = int.tryParse(splitDuration[0]);
      int? minuteIndex = int.tryParse(splitDuration[1]);
      if (hourIndex != null && minuteIndex != null) {
        durationMin = (hourIndex * 60) + minuteIndex;
      }
    } else {
      log('Unable to parse duration.');
    }
  } else {
    durationMin = (durationS / 60).floor();
  }
  durationMin ??= 1;

  XmlElement? enclosure = findAndCheckForElement(element, 'enclosure');
  if (enclosure == null) {
    return null;
  }

  String? url = enclosure.getAttribute('url');
  if (url == null) {
    return null;
  }

  return PodcastItem(title, shortenedDate, description, durationMin.toString(), url);
}
