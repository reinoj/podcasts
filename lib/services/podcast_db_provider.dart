import 'dart:async';

import 'package:nojcasts/models/podcast.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

const String podcastTable = 'Podcasts';
const String podcastDb = 'nojcasts.db';

const int dbVersion = 2;

class PodcastDbProvider {
  final lock = Lock(reentrant: true);
  final _updateController = StreamController<bool>.broadcast();
  static Database? _db;

  Future<void> get ready async => _db ??= await lock.synchronized(() async {
    return await open();
  });

  Future<Database> open() async {
    String dbPath = await getDatabasesPath();
    return await openDatabase(
      '$dbPath/$podcastDb',
      version: dbVersion,
      onCreate: (db, version) async {
        await _createDb(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await _createDb(db);
        }
      },
    );
  }

  Future<void> _createDb(Database db) async {
    await db.execute(
      'CREATE TABLE $podcastTable ($columnId TEXT PRIMARY KEY, $columnTitle TEXT, $columnRssUrl TEXT)',
    );
  }

  void _triggerUpdate() {
    _updateController.sink.add(true);
  }

  Future<void> _addPodcast(DatabaseExecutor? db, Podcast newPodcast) async {
    await db!.insert(podcastTable, newPodcast.toMap());
  }

  Future<void> addPodcast(Podcast newPodcast) async {
    await _addPodcast(_db, newPodcast);
    _triggerUpdate();
  }

  Future<List<Podcast>> getPodcasts() async {
    var list = await _db!.query(
      podcastTable,
      columns: [columnId, columnTitle, columnRssUrl],
    );
    return list.map((podcast) => Podcast()..fromMap(podcast)).toList();
  }

  Stream<List<Podcast?>> onPodcasts() {
    late StreamController<List<Podcast>> controller;
    StreamSubscription? triggerSubscription;

    Future<void> sendUpdate() async {
      List<Podcast> podcasts = await getPodcasts();
      if (!controller.isClosed) {
        controller.add(podcasts);
      }
    }

    controller = StreamController<List<Podcast>>(
      onListen: () {
        sendUpdate();
        triggerSubscription = _updateController.stream.listen(
          (_) => sendUpdate(),
        );
      },
      onCancel: () {
        triggerSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  Future<void> close() async {
    await _db!.close();
  }
}
