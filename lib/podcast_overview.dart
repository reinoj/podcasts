import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:json_annotation/json_annotation.dart';

part 'podcast_overview.g.dart';

@JsonSerializable()
class PodcastOverview {
  final String title;
  final String lastUpdated;

  PodcastOverview({required this.title, required this.lastUpdated});

  factory PodcastOverview.fromJson(Map<String, dynamic> json) => _$PodcastOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$PodcastOverviewToJson(this);
}

Future<Map<String, dynamic>> getProfile() async {
  Directory directory = await getApplicationDocumentsDirectory();
  File rFile = File('${directory.path}/nojcasts/profile.json');
  String profileString = rFile.readAsStringSync();
  return jsonDecode(profileString);
}
