import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Future<Database> open() async {
    final databasePath = path.join(await getDatabasesPath(), 'waitlist.db');
    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) async {
        // AUTOINCREMENT prevents ticket reuse even after all rows are removed.
        await database.execute('''
          CREATE TABLE parties (
            ticket INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL CHECK (length(trim(name)) > 0),
            size INTEGER NOT NULL CHECK (size > 0),
            status TEXT NOT NULL DEFAULT 'waiting'
              CHECK (status IN ('waiting', 'removed')),
            joined_at INTEGER NOT NULL,
            removed_at INTEGER
          )
        ''');
        await database.execute(
          'CREATE INDEX idx_parties_status_ticket ON parties(status, ticket)',
        );
      },
      onUpgrade: (database, oldVersion, newVersion) async {},
    );
  }
}
