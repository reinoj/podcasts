// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PodcastInfo _$PodcastInfoFromJson(Map<String, dynamic> json) => PodcastInfo(
      json['hosts'] as String,
      (json['items'] as List<dynamic>)
          .map((e) => PodcastItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PodcastInfoToJson(PodcastInfo instance) =>
    <String, dynamic>{
      'hosts': instance.hosts,
      'items': instance.items,
    };
