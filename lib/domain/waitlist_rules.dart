const avgMinutesPerParty = 10;

class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

String validateName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    throw const ValidationException('Enter a name.');
  }
  return trimmed;
}

int validatePartySize(int size) {
  if (size <= 0) {
    throw const ValidationException('Party size must be at least 1.');
  }
  return size;
}

int parsePartySize(String input) {
  final digits = _normaliseDigits(input.trim());
  if (digits.isEmpty) {
    throw const ValidationException('Enter the party size.');
  }
  final size = int.tryParse(digits, radix: 10);
  if (size == null) {
    throw ValidationException(
      _onlyDigits.hasMatch(digits)
          ? 'That number is too large.'
          : 'Enter a whole number.',
    );
  }
  return validatePartySize(size);
}

String partiesAheadLabel(int partiesAhead) => switch (partiesAhead) {
  0 => 'Next',
  1 => '1 party ahead',
  _ => '$partiesAhead parties ahead',
};

String? estimatedWaitLabel(int partiesAhead) =>
    partiesAhead == 0 ? null : '≈ ${partiesAhead * avgMinutesPerParty} min';

String? errorMessageOf(void Function() rule) {
  try {
    rule();
    return null;
  } on ValidationException catch (error) {
    return error.message;
  }
}

final _onlyDigits = RegExp(r'^[0-9]+$');

const _easternArabicDigits = '٠١٢٣٤٥٦٧٨٩';

String _normaliseDigits(String input) {
  var result = input;
  for (var index = 0; index < _easternArabicDigits.length; index++) {
    result = result.replaceAll(_easternArabicDigits[index], '$index');
  }
  return result;
}
