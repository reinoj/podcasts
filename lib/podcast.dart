// ignore_for_file: non_constant_identifier_names
// I like having the time unit separated by an underscore at the end of the variable

import 'dart:developer' as developer;
import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

class PodcastInfo {
  final String title;
  final String hosts;
  final List<PodcastItem> items;

  PodcastInfo(this.title, this.hosts, this.items);
}

class PodcastItem {
  final String title;
  final String pubDate;
  final String description;
  final String duration_min;
  final String url;

  PodcastItem(this.title, this.pubDate, this.description, this.duration_min, this.url);
}

XmlDocument? parseXmlString(String contents) {
  try {
    return XmlDocument.parse(contents);
  } on XmlParserException {
    developer.log('XmlParserException: Error parsing XML document');
  } on XmlTagException {
    developer.log('XmlTagException: XML document end tag doesn\'t match the open tag.');
  } catch (e) {
    developer.log('Error parsing XML: $e');
  }

  return null;
}

Future<XmlDocument?> getXmlDocumentFromURL(String url) async {
  Uri uri = Uri.parse(url);
  if (!uri.isAbsolute) {
    developer.log('URL is invalid');
    return null;
  }
  http.Response response = await http.get(uri);

  return parseXmlString(response.body);
}

Future<XmlDocument?> getXmlDocumentFromFile(String title) async {
  Directory dir = await getApplicationDocumentsDirectory();
  File podcastFile = File('${dir.path}/nojcasts/podcasts/$title.xml');
  if (!podcastFile.existsSync()) {
    developer.log('File "$title.xml" does not exist');
    return null;
  }

  String contents = podcastFile.readAsStringSync();
  return parseXmlString(contents);
}

XmlElement? findAndCheckForElement(XmlElement root, String elementName) {
  Iterable<XmlElement> elementIter = root.findElements(elementName);
  if (elementIter.isEmpty) {
    developer.log("No '$elementName' element in channel.");
    return null;
  }
  return elementIter.singleOrNull;
}

PodcastItem? getPodcastItem(XmlElement element) {
  XmlElement? xmlTitle = findAndCheckForElement(element, 'title');
  if (xmlTitle == null) {
    return null;
  }
  String title = xmlTitle.innerText;

  XmlElement? xmlDescription = findAndCheckForElement(element, 'description');
  if (xmlDescription == null) {
    return null;
  }

  // parse the paragraph tag
  Document p = parse(xmlDescription.innerText);
  if (p.body == null) {
    return null;
  }

  String description = p.body!.text;
  if (description.isEmpty) {
    XmlElement? xmlSummary = findAndCheckForElement(element, 'itunes:summary');
    if (xmlSummary != null) {
      p = parse(xmlSummary.innerText);
      if (p.body != null) {
        description = p.body!.text;
      }
    }
  }

  int i = description.lastIndexOf('Timestamps');
  if (i != -1) {
    description = description.substring(0, i);
  }

  XmlElement? pubDate = findAndCheckForElement(element, 'pubDate');
  if (pubDate == null) {
    return null;
  }
  // just keep the day and date
  String shortenedDate = pubDate.innerText.substring(0, 16);

  XmlElement? xmlDuration = findAndCheckForElement(element, 'itunes:duration');
  if (xmlDuration == null) {
    return null;
  }
  int? duration_s = int.tryParse(xmlDuration.innerText);
  if (duration_s == null) {
    return null;
  }
  int duration_min = (duration_s / 60).floor();

  XmlElement? enclosure = findAndCheckForElement(element, 'enclosure');
  if (enclosure == null) {
    return null;
  }

  String? url = enclosure.getAttribute('url');
  if (url == null) {
    return null;
  }

  return PodcastItem(title, shortenedDate, description, duration_min.toString(), url);
}

void savePodcastImage(XmlElement image, String title) async {
  String url = image.attributes.single.value;
  Uri uri = Uri.parse(url);
  if (!uri.isAbsolute) {
    developer.log('URL is invalid');
    return null;
  }
  http.Response response = await http.get(uri);

  String fileType = url.substring(url.length - 3).toLowerCase();
  if ('jpg' != fileType && 'png' != fileType) {
    developer.log('Unsupported image format "$fileType". Currently only jpg and png is supported.');
  }

  Directory directory = await getApplicationDocumentsDirectory();
  File wFile = File('${directory.path}/nojcasts/images/$title.$fileType');
  wFile.writeAsBytesSync(response.bodyBytes);
}

PodcastInfo? getPodcastInfo(XmlDocument document, bool getItems) {
  Iterable<XmlElement> channelIter = document.findAllElements('channel');
  if (channelIter.isEmpty) {
    developer.log('Invalid XML from RSS feed.');
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

  if (getItems) {
    List<XmlElement> itemIter = channel.findElements('item').toList();

    List<PodcastItem> podcastItemList = List.empty(growable: true);
    for (XmlElement item in itemIter) {
      PodcastItem? podcastItem = getPodcastItem(item);
      if (null == podcastItem) {
        return null;
      }
      podcastItemList.add(podcastItem);
    }

    return PodcastInfo(title.innerText, hosts.innerText, podcastItemList);
  }

  XmlElement? image = findAndCheckForElement(channel, 'itunes:image');
  if (null == image) {
    return null;
  }
  savePodcastImage(image, title.innerText);

  return PodcastInfo(title.innerText, hosts.innerText, []);
}

Future<PodcastInfo?> getPodcastInfoFromFile(String title) async {
  XmlDocument? document = await getXmlDocumentFromFile(title);
  if (document == null) {
    return null;
  }

  return getPodcastInfo(document, true);
}
