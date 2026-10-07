import 'package:sqflite/sqflite.dart';

import '../domain/waitlist_rules.dart';
import '../models/party.dart';

class WaitlistRepository {
  const WaitlistRepository(this._db);

  final Database _db;
  static const _table = 'parties';

  Future<int> add({required String name, required int size}) async {
    final row = {
      'name': validateName(name),
      'size': validatePartySize(size),
      'status': PartyStatus.waiting.dbValue,
      'joined_at': DateTime.now().millisecondsSinceEpoch,
    };
    return _db.insert(_table, row);
  }

  Future<List<Party>> getWaiting() async {
    final rows = await _db.query(
      _table,
      where: 'status = ?',
      whereArgs: [PartyStatus.waiting.dbValue],
      orderBy: 'ticket ASC',
    );
    return rows.map(Party.fromMap).toList();
  }

  Future<List<Party>> getHistory() async {
    final rows = await _db.query(
      _table,
      where: 'status = ?',
      whereArgs: [PartyStatus.removed.dbValue],
      orderBy: 'removed_at DESC, ticket DESC',
    );
    return rows.map(Party.fromMap).toList();
  }

  Future<void> update(Party party) async {
    await _db.update(
      _table,
      {'name': validateName(party.name), 'size': validatePartySize(party.size)},
      where: 'ticket = ? AND status = ?',
      whereArgs: [party.ticket, PartyStatus.waiting.dbValue],
    );
  }

  Future<void> remove(int ticket) async {
    await _db.update(
      _table,
      {
        'status': PartyStatus.removed.dbValue,
        'removed_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'ticket = ? AND status = ?',
      whereArgs: [ticket, PartyStatus.waiting.dbValue],
    );
  }

  Future<void> restore(int ticket) async {
    await _db.update(
      _table,
      {'status': PartyStatus.waiting.dbValue, 'removed_at': null},
      where: 'ticket = ? AND status = ?',
      whereArgs: [ticket, PartyStatus.removed.dbValue],
    );
  }
}
