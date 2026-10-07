import 'package:flutter/foundation.dart';

import '../data/waitlist_repository.dart';
import '../domain/waitlist_rules.dart';
import '../models/party.dart';

class WaitingPartyEntry {
  const WaitingPartyEntry({required this.party, required this.partiesAhead});

  final Party party;
  final int partiesAhead;
}

class WaitlistController extends ChangeNotifier {
  WaitlistController(this._repository);

  final WaitlistRepository _repository;

  List<WaitingPartyEntry> _entries = const [];
  List<WaitingPartyEntry> get entries => _entries;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _loadError;
  String? get loadError => _loadError;

  String? _lastError;
  String? get lastError => _lastError;

  Future<void> load() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();
    try {
      _entries = _buildEntries(await _repository.getWaiting());
    } on Exception catch (error) {
      _loadError = errorMessageOf(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Party?> addParty({required String name, required String size}) async {
    if (_isSaving) {
      return null;
    }
    _isSaving = true;
    _lastError = null;
    notifyListeners();
    try {
      final addedParty = await _repository.add(name: name, size: size);
      try {
        _entries = _buildEntries(await _repository.getWaiting());
        _loadError = null;
      } on Exception catch (error) {
        _loadError = errorMessageOf(error);
      }
      return addedParty;
    } on Exception catch (error) {
      _lastError = errorMessageOf(error);
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> removeParty(int ticket) async {
    _lastError = null;
    try {
      await _repository.remove(ticket);
    } on Exception catch (error) {
      _lastError = errorMessageOf(error);
      notifyListeners();
      return false;
    }

    try {
      _entries = _buildEntries(await _repository.getWaiting());
      _loadError = null;
    } on Exception catch (error) {
      _loadError = errorMessageOf(error);
    }
    notifyListeners();
    return true;
  }

  List<WaitingPartyEntry> _buildEntries(List<Party> parties) {
    return List<WaitingPartyEntry>.unmodifiable([
      for (var index = 0; index < parties.length; index++)
        WaitingPartyEntry(party: parties[index], partiesAhead: index),
    ]);
  }
}
