import 'package:json_annotation/json_annotation.dart';

import 'package:nojcasts/types/podcast_item.dart';

part 'podcast_info.g.dart';

@JsonSerializable()
class PodcastInfo {
  final String hosts;
  final List<PodcastItem> items;

  PodcastInfo(this.hosts, this.items);

  factory PodcastInfo.fromJson(Map<String, dynamic> json) => _$PodcastInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PodcastInfoToJson(this);
}
