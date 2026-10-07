import 'package:sqflite/sqflite.dart';

import '../domain/waitlist_rules.dart';
import '../models/party.dart';

class WaitlistRepository {
  const WaitlistRepository(this._database);

  final Database _database;

  Future<Party> add({required String name, required String size}) async {
    final nameError = validateName(name);
    if (nameError != null) {
      throw ValidationException(nameError);
    }
    final sizeError = validatePartySizeInput(size);
    if (sizeError != null) {
      throw ValidationException(sizeError);
    }

    final parsedSize = parsePartySize(size)!;
    final trimmedName = name.trim();
    final joinedAt = DateTime.now().millisecondsSinceEpoch;
    final ticket = await _database.insert('parties', {
      'name': trimmedName,
      'size': parsedSize,
      'status': PartyStatus.waiting.name,
      'joined_at': joinedAt,
    });
    return Party(
      ticket: ticket,
      name: trimmedName,
      size: parsedSize,
      status: PartyStatus.waiting,
      joinedAt: joinedAt,
    );
  }

  Future<List<Party>> getWaiting() async {
    final rows = await _database.query(
      'parties',
      where: 'status = ?',
      whereArgs: [PartyStatus.waiting.name],
      orderBy: 'ticket ASC',
    );
    return rows.map(Party.fromMap).toList(growable: false);
  }

  Future<void> remove(int ticket) async {
    final count = await _database.update(
      'parties',
      {
        'status': PartyStatus.removed.name,
        'removed_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'ticket = ? AND status = ?',
      whereArgs: [ticket, PartyStatus.waiting.name],
    );
    if (count != 1) {
      throw Exception('That party is no longer waiting.');
    }
  }
}
