import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Backup Data Format Tests', () {
    test('Backup JSON structure contains expected keys and data', () {
      final sampleBackup = {
        'version': 1,
        'app': 'ration_attendance',
        'exported_at': '2026-08-06T07:40:00.000Z',
        'ration_cards': [
          {
            'card_number': 'AP123456789012',
            'head_name': 'Ramesh Kumar',
            'relation': 'Self',
            'mobile': '9876543210',
            'category': 'White Card',
            'units': 4,
            'rice': 20,
            'address': 'Vijayawada'
          }
        ],
        'attendance': [
          {
            'card_number': 'AP123456789012',
            'month': 8,
            'year': 2026,
            'received': 1,
            'received_date': '2026-08-06'
          }
        ],
        'attendance_history': []
      };

      final jsonString = jsonEncode(sampleBackup);
      final decoded = jsonDecode(jsonString);

      expect(decoded['app'], 'ration_attendance');
      expect(decoded['version'], 1);
      expect(decoded['ration_cards'].length, 1);
      expect(decoded['ration_cards'][0]['card_number'], 'AP123456789012');
      expect(decoded['attendance'].length, 1);
    });
  });
}
