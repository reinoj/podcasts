import 'package:nojcasts/services/podcast_db_service.dart';
import 'package:nojcasts/models/podcast_entry.dart';
import 'package:nojcasts/utils/result.dart';

class PodcastRepository {
  final PodcastDBService _dbService = PodcastDBService();

  Future<Result<List<PodcastEntry>>> getPodcasts() async {
    final db = await _dbService.database;

    List<Map<String, Object?>> query = await db.query(
      PODCASTS_TABLE,
      columns: ['title', 'rssUrl'],
      orderBy: 'title',
    );

    return Result.ok(query.map(fromMap).toList());
  }

  Future<void> insertPodcast(PodcastEntry podcast) async {
    final db = await _dbService.database;

    // insert() returns the id of the last inserted row, but i don't need it so just ignore it
    await db.insert(PODCASTS_TABLE, podcast.toMap());
  }
}
