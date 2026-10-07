class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

String? validateName(String value) {
  if (value.trim().isEmpty) {
    return 'Enter a name.';
  }
  return null;
}

String? validatePartySize(int? size) {
  if (size == null) {
    return 'Enter the party size.';
  }
  if (size <= 0) {
    return 'Party size must be at least 1.';
  }
  return null;
}

int? parsePartySize(String value) {
  final normalized = value.split('').map((character) {
    final code = character.codeUnitAt(0);
    if (code >= 0x0660 && code <= 0x0669) {
      return String.fromCharCode(code - 0x0660 + 0x30);
    }
    return character;
  }).join();
  return int.tryParse(normalized.trim());
}

String? validatePartySizeInput(String value) {
  if (value.trim().isEmpty) {
    return validatePartySize(null);
  }
  final size = parsePartySize(value);
  if (size == null) {
    final digitsOnly = RegExp(r'^[0-9\u0660-\u0669]+$');
    return digitsOnly.hasMatch(value.trim())
        ? 'That number is too large.'
        : 'Enter a whole number.';
  }
  return validatePartySize(size);
}

String errorMessageOf(Object error) {
  if (error is ValidationException) {
    return error.message;
  }
  return 'Something went wrong. Please try again.';
}

String partiesAheadLabel(int partiesAhead) {
  if (partiesAhead <= 0) {
    return 'Next';
  }
  if (partiesAhead == 1) {
    return '1 party ahead';
  }
  return '$partiesAhead parties ahead';
}
