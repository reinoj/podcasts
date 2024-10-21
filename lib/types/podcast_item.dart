import 'package:json_annotation/json_annotation.dart';

part 'podcast_item.g.dart';

@JsonSerializable()
class PodcastItem {
  final String title;
  final String pubDate;
  final String description;
  final String durationMin;
  final String mp3Url;

  PodcastItem(this.title, this.pubDate, this.description, this.durationMin, this.mp3Url);

  factory PodcastItem.fromJson(Map<String, dynamic> json) => _$PodcastItemFromJson(json);

  Map<String, dynamic> toJson() => _$PodcastItemToJson(this);
}
