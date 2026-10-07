import 'package:flutter/foundation.dart';

import '../data/waitlist_repository.dart';
import '../models/party.dart';

enum LoadStatus { loading, ready, error }

typedef QueueEntry = ({Party party, int partiesAhead});

class WaitlistController extends ChangeNotifier {
  WaitlistController(this._repository);

  final WaitlistRepository _repository;

  LoadStatus _status = LoadStatus.loading;
  List<Party> _waiting = const [];
  bool _isBusy = false;
  int? _lastRemovedTicket;

  LoadStatus get status => _status;
  bool get isBusy => _isBusy;

  List<QueueEntry> get entries => List.generate(
    _waiting.length,
    (index) => (party: _waiting[index], partiesAhead: index),
  );

  Future<void> load() async {
    try {
      _waiting = await _repository.getWaiting();
      _status = LoadStatus.ready;
    } on Exception {
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> retry() {
    _status = LoadStatus.loading;
    notifyListeners();
    return load();
  }

  Future<List<Party>> loadHistory() => _repository.getHistory();

  Future<int?> addParty({required String name, required int size}) async {
    int? ticket;
    await _write(() async {
      ticket = await _repository.add(name: name, size: size);
    });
    return ticket;
  }

  Future<bool> editParty(Party edited) =>
      _write(() => _repository.update(edited));

  Future<bool> removeParty(int ticket) async {
    final removed = await _write(() => _repository.remove(ticket));
    if (removed) _lastRemovedTicket = ticket;
    return removed;
  }

  Future<void> undoLastRemoval() async {
    final ticket = _lastRemovedTicket;
    if (ticket == null) return;
    if (await _write(() => _repository.restore(ticket))) {
      _lastRemovedTicket = null;
    }
  }

  Future<bool> _write(Future<void> Function() write) async {
    if (_isBusy) return false;
    _setBusy(true);
    try {
      await write();
      await load();
      return true;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
