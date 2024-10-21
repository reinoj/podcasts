import 'dart:developer' show log;

import 'package:sqflite/sqflite.dart';

import 'package:nojcasts/db/podcast_db_entry.dart';

// ignore: constant_identifier_names
const String PODCASTS_TABLE = 'Podcasts';

class PodcastDb {
  static PodcastDb? _instance;
  final Database? _db;

  static Future<PodcastDb> getInstance() async {
    if (_instance == null) {
      String dbPath = await getDatabasesPath();
      Database db = await openDatabase(
        '$dbPath/nojcasts.db',
        version: 1,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE $PODCASTS_TABLE (id INTEGER PRIMARY KEY, title TEXT, rssUrl TEXT)');
        },
      );
      _instance = PodcastDb._(db);
    }
    return _instance!;
  }

  PodcastDb._(Database db) : _db = db;

  Future<List<PodcastDbEntry>> getPodcasts() async {
    if (_db == null) {
      log('get failed: _db is null.');
      return [];
    }

    List<Map<String, Object?>>? query = await _db.query(
      PODCASTS_TABLE,
      columns: ['title', 'rssUrl'],
      orderBy: 'title',
    );

    return query.map(fromMap).toList();
  }

  Future<void> insertPodcast(PodcastDbEntry podcast) async {
    if (_db == null) {
      log('insert failed: _db is null.');
      return;
    }

    await _db.insert(PODCASTS_TABLE, podcast.toMap());
  }

  Future<void> closeDb() async {
    if (_db != null) {
      await _db.close();
    }
  }
}
