import 'package:flutter_test/flutter_test.dart';
import 'package:ration_attendance/utils/qr_parser.dart';

void main() {
  group('QRParser', () {
    test('extracts RC number from AP AePDS QR URL', () {
      const qr = 'https://aepos.ap.gov.in/Qcodesearch.jsp?rcno=2818012263';
      expect(QRParser.extractCardNumber(qr), '2818012263');
    });

    test('extracts RC number from AP AePDS QR URL with extra params', () {
      const qr = 'https://aepos.ap.gov.in/Qcodesearch.jsp?rcno=2818012263&foo=bar';
      expect(QRParser.extractCardNumber(qr), '2818012263');
    });

    test('extracts RC number from JSON format', () {
      const qr = '{"cardNumber": "2818012263", "name": "Test"}';
      expect(QRParser.extractCardNumber(qr), '2818012263');
    });

    test('extracts RC number from JSON format with case insensitivity', () {
      const qr = '{"CARD_NO": "2818012263"}';
      expect(QRParser.extractCardNumber(qr), '2818012263');
    });

    test('extracts RC number from explicit key-value format', () {
      const qr = 'CARD=2818012263';
      expect(QRParser.extractCardNumber(qr), '2818012263');
    });

    test('extracts WAP number from exact match', () {
      const qr = 'WAP074600200370';
      expect(QRParser.extractCardNumber(qr), 'WAP074600200370');
    });

    test('does not extract arbitrary string like V10747026', () {
      const qr = 'V10747026';
      expect(QRParser.extractCardNumber(qr), null);
    });
    
    test('extracts exactly 10 digits as fallback', () {
      const qr = '2818012263';
      expect(QRParser.extractCardNumber(qr), '2818012263');
    });
  });
}
