import 'package:json_annotation/json_annotation.dart';
import 'package:nojcasts/data/podcast_overview.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  List<PodcastOverview> podcasts;

  Profile({required this.podcasts});

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
