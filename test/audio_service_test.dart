import 'package:flutter_test/flutter_test.dart';
import 'package:ration_attendance/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService Unit Tests', () {
    test('Toggle mute flips isMuted property', () {
      final audio = AudioService.instance;
      final initial = audio.isMuted;
      audio.toggleMute();
      expect(audio.isMuted, !initial);
      audio.toggleMute();
      expect(audio.isMuted, initial);
    });
  });
}
