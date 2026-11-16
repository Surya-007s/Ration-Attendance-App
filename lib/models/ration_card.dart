class RationCard {
  final int? id;
  final String cardNumber;
  final String headName;
  final String relation;
  final String mobile;
  final String category;
  final int units;
  final int rice;
  final String address;

  RationCard({
    this.id,
    required this.cardNumber,
    required this.headName,
    required this.relation,
    required this.mobile,
    required this.category,
    required this.units,
    required this.rice,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'card_number': cardNumber,
      'head_name': headName,
      'relation': relation,
      'mobile': mobile,
      'category': category,
      'units': units,
      'rice': rice,
      'address': address,
    };
  }

  factory RationCard.fromMap(Map<String, dynamic> map) {
    return RationCard(
      id: map['id'] as int?,
      cardNumber: map['card_number']?.toString() ?? '',
      headName: map['head_name']?.toString() ?? '',
      relation: map['relation']?.toString() ?? '',
      mobile: map['mobile']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      units: map['units'] is int
          ? map['units']
          : int.tryParse(map['units']?.toString() ?? '0') ?? 0,
      rice: map['rice'] is int
          ? map['rice']
          : int.tryParse(map['rice']?.toString() ?? '0') ?? 0,
      address: map['address']?.toString() ?? '',
    );
  }

  RationCard copyWith({
    int? id,
    String? cardNumber,
    String? headName,
    String? relation,
    String? mobile,
    String? category,
    int? units,
    int? rice,
    String? address,
  }) {
    return RationCard(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      headName: headName ?? this.headName,
      relation: relation ?? this.relation,
      mobile: mobile ?? this.mobile,
      category: category ?? this.category,
      units: units ?? this.units,
      rice: rice ?? this.rice,
      address: address ?? this.address,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RationCard &&
          runtimeType == other.runtimeType &&
          cardNumber == other.cardNumber;

  @override
  int get hashCode => cardNumber.hashCode;

  @override
  String toString() =>
      'RationCard(cardNumber: $cardNumber, headName: $headName)';
}