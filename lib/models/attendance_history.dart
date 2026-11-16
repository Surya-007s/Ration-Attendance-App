class AttendanceHistory {
  final int? id;
  final String cardNumber;
  final String beneficiaryName;
  final int month;
  final int year;
  final String receivedAt;
  final String operatorName;
  final String remarks;

  AttendanceHistory({
    this.id,
    required this.cardNumber,
    required this.beneficiaryName,
    required this.month,
    required this.year,
    required this.receivedAt,
    this.operatorName = '',
    this.remarks = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'card_number': cardNumber,
      'beneficiary_name': beneficiaryName,
      'month': month,
      'year': year,
      'received_at': receivedAt,
      'operator_name': operatorName,
      'remarks': remarks,
    };
  }

  factory AttendanceHistory.fromMap(Map<String, dynamic> map) {
    return AttendanceHistory(
      id: map['id'] as int?,
      cardNumber: map['card_number']?.toString() ?? '',
      beneficiaryName: map['beneficiary_name']?.toString() ?? '',
      month: map['month'] is int
          ? map['month']
          : int.tryParse(map['month']?.toString() ?? '0') ?? 0,
      year: map['year'] is int
          ? map['year']
          : int.tryParse(map['year']?.toString() ?? '0') ?? 0,
      receivedAt: map['received_at']?.toString() ?? '',
      operatorName: map['operator_name']?.toString() ?? '',
      remarks: map['remarks']?.toString() ?? '',
    );
  }

  /// Display-friendly date string, preferring received_at over received_date
  String get displayDate {
    if (receivedAt.isNotEmpty) return receivedAt;
    return '';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceHistory &&
          runtimeType == other.runtimeType &&
          cardNumber == other.cardNumber &&
          month == other.month &&
          year == other.year;

  @override
  int get hashCode => Object.hash(cardNumber, month, year);
}
