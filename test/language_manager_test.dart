import 'package:flutter_test/flutter_test.dart';
import 'package:ration_attendance/utils/language_manager.dart';

void main() {
  group('LanguageManager Unit Tests', () {
    test('Default language is English', () {
      final lang = LanguageManager.instance;
      lang.setLanguage(AppLanguage.english);
      expect(lang.isTelugu, false);
      expect(lang.getText('app_title'), 'RationTrack');
      expect(lang.getText('scan_qr'), 'SCAN QR');
    });

    test('Switching to Telugu returns Telugu strings', () {
      final lang = LanguageManager.instance;
      lang.setLanguage(AppLanguage.telugu);
      expect(lang.isTelugu, true);
      expect(lang.getText('app_title'), 'రేషన్ హాజరు వ్యవస్థ');
      expect(lang.getText('scan_qr'), 'క్యూఆర్‌ స్కాన్ చేయండి');
      expect(lang.getText('card_number'), 'రైస్ కార్డ్ సంఖ్య');
    });

    test('Toggle language toggles back and forth', () {
      final lang = LanguageManager.instance;
      lang.setLanguage(AppLanguage.english);
      lang.toggleLanguage();
      expect(lang.isTelugu, true);
      lang.toggleLanguage();
      expect(lang.isTelugu, false);
    });
  });
}
