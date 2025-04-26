import 'package:sqflite/sqflite.dart';

// ignore: constant_identifier_names
const String PODCASTS_TABLE = 'Podcasts';

class PodcastDBService {
  static Database? _db;
  Future<Database> get database async => _db ??= await _openDatabase();

  Future<Database> _openDatabase() async {
    String dbPath = await getDatabasesPath();
    return await openDatabase(
      '$dbPath/nojcasts.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE $PODCASTS_TABLE (id INTEGER PRIMARY KEY, title TEXT, rssUrl TEXT)');
      },
    );
  }
}
