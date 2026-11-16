import 'package:flutter_test/flutter_test.dart';
import 'package:ration_attendance/models/ration_card.dart';

void main() {
  group('RationCard Model Tests', () {
    test('fromMap parses map correctly', () {
      final map = {
        'id': 1,
        'card_number': 'AP1234567890',
        'head_name': 'Ramesh Kumar',
        'relation': 'Self',
        'mobile': '9876543210',
        'category': 'WAP',
        'units': 4,
        'rice': 20,
        'address': 'Door No 1-2-3, Main Road',
      };

      final card = RationCard.fromMap(map);

      expect(card.id, 1);
      expect(card.cardNumber, 'AP1234567890');
      expect(card.headName, 'Ramesh Kumar');
      expect(card.units, 4);
      expect(card.rice, 20);
    });

    test('toMap serializes RationCard correctly', () {
      final card = RationCard(
        id: 2,
        cardNumber: 'AP0987654321',
        headName: 'Sita Devi',
        relation: 'Wife',
        mobile: '9123456789',
        category: 'AAP',
        units: 3,
        rice: 15,
        address: 'Street 4',
      );

      final map = card.toMap();

      expect(map['id'], 2);
      expect(map['card_number'], 'AP0987654321');
      expect(map['head_name'], 'Sita Devi');
      expect(map['units'], 3);
      expect(map['rice'], 15);
    });
  });
}
