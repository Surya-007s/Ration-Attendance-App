class Attendance {
  final int? id;
  final String cardNumber;
  final int month;
  final int year;
  final int received;
  final String? receivedDate;

  Attendance({
    this.id,
    required this.cardNumber,
    required this.month,
    required this.year,
    this.received = 1,
    this.receivedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'card_number': cardNumber,
      'month': month,
      'year': year,
      'received': received,
      'received_date': receivedDate,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as int?,
      cardNumber: map['card_number']?.toString() ?? '',
      month: map['month'] is int
          ? map['month']
          : int.tryParse(map['month']?.toString() ?? '0') ?? 0,
      year: map['year'] is int
          ? map['year']
          : int.tryParse(map['year']?.toString() ?? '0') ?? 0,
      received: map['received'] is int
          ? map['received']
          : int.tryParse(map['received']?.toString() ?? '1') ?? 1,
      receivedDate: map['received_date']?.toString(),
    );
  }

  Attendance copyWith({
    int? id,
    String? cardNumber,
    int? month,
    int? year,
    int? received,
    String? receivedDate,
  }) {
    return Attendance(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      month: month ?? this.month,
      year: year ?? this.year,
      received: received ?? this.received,
      receivedDate: receivedDate ?? this.receivedDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Attendance &&
          runtimeType == other.runtimeType &&
          cardNumber == other.cardNumber &&
          month == other.month &&
          year == other.year;

  @override
  int get hashCode => Object.hash(cardNumber, month, year);
}
