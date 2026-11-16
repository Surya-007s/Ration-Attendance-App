import 'package:flutter_test/flutter_test.dart';
import 'package:ration_attendance/utils/ration_cycle.dart';

void main() {
  group('RationCycle Logic Tests', () {
    test('isDistributionOpen calculation', () {
      final isOpen = RationCycle.isDistributionOpen;
      final day = DateTime.now().day;

      if (day >= 25 || day <= 16) {
        expect(isOpen, true);
        expect(RationCycle.status, "OPEN");
      } else {
        expect(isOpen, false);
        expect(RationCycle.status, "CLOSED");
      }
    });

    test('currentCycle string format', () {
      final cycleStr = RationCycle.currentCycle;
      expect(cycleStr, contains("→"));
    });

    test('nextCycleDate returns formatted date string', () {
      final nextDate = RationCycle.nextCycleDate;
      expect(nextDate, isNotEmpty);
    });
  });
}
