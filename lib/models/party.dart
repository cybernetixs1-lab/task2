enum PartyStatus { waiting, removed }

class Party {
  const Party({
    required this.ticket,
    required this.name,
    required this.size,
    required this.status,
    required this.joinedAt,
    this.removedAt,
  });

  final int ticket;
  final String name;
  final int size;
  final PartyStatus status;
  final int joinedAt;
  final int? removedAt;

  factory Party.fromMap(Map<String, Object?> map) {
    return Party(
      ticket: map['ticket']! as int,
      name: map['name']! as String,
      size: map['size']! as int,
      status: PartyStatus.values.byName(map['status']! as String),
      joinedAt: map['joined_at']! as int,
      removedAt: map['removed_at'] as int?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'ticket': ticket,
      'name': name,
      'size': size,
      'status': status.name,
      'joined_at': joinedAt,
      'removed_at': removedAt,
    };
  }

  Party copyWith({String? name, int? size}) {
    return Party(
      ticket: ticket,
      name: name ?? this.name,
      size: size ?? this.size,
      status: status,
      joinedAt: joinedAt,
      removedAt: removedAt,
    );
  }
}
