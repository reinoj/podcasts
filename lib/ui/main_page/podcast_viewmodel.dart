import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:nojcasts/models/podcast_entry.dart';
import 'package:nojcasts/services/podcast_repository.dart';
import 'package:nojcasts/utils/command.dart';
import 'package:nojcasts/utils/result.dart';

class MainViewmodel extends ChangeNotifier {
  MainViewmodel({required PodcastRepository podcastRepository})
    : _podcastRepository = podcastRepository {
    loadPodcasts = Command0(_loadPodcasts)..execute();
  }

  final PodcastRepository _podcastRepository;

  List<PodcastEntry> _podcasts = <PodcastEntry>[];
  List<PodcastEntry> get podcasts => _podcasts;

  late Command0 loadPodcasts;

  Future<Result<List<PodcastEntry>>> _loadPodcasts() async {
    log('Running _loadPodcasts');
    Result<List<PodcastEntry>> result = await _podcastRepository.getPodcasts();
    switch (result) {
      case Ok<List<PodcastEntry>>():
        log('length: ${result.value.length}');
        _podcasts = result.value;
        notifyListeners();
      case Error<List<PodcastEntry>>():
        log('Error retrieving podcasts: ${result.error}');
        break;
    }
    return result;
  }

  Future<void> insertPodcast(PodcastEntry entry) async {
    await _podcastRepository.insertPodcast(entry);
    await _loadPodcasts();
    notifyListeners();
  }

  Future<Result<String>> getRssFromPodcast(String title) async {
    return await _podcastRepository.getRssFromPodcast(title);
  }
}
