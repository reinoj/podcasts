// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PodcastItem _$PodcastItemFromJson(Map<String, dynamic> json) => PodcastItem(
      json['title'] as String,
      json['pubDate'] as String,
      json['description'] as String,
      json['durationMin'] as String,
      json['mp3Url'] as String,
    );

Map<String, dynamic> _$PodcastItemToJson(PodcastItem instance) =>
    <String, dynamic>{
      'title': instance.title,
      'pubDate': instance.pubDate,
      'description': instance.description,
      'durationMin': instance.durationMin,
      'mp3Url': instance.mp3Url,
    };
