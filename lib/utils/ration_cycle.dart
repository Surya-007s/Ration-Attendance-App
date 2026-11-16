import 'package:intl/intl.dart';

class RationCycle {
  static DateTime get now => DateTime.now();

  /// Distribution is OPEN from 25th to 16th
  static bool get isDistributionOpen {
    return now.day >= 25 || now.day <= 16;
  }

  /// Cycle Month
  static int get cycleMonth {
    if (now.day >= 25) {
      return now.month;
    }

    if (now.day <= 16) {
      return now.month == 1 ? 12 : now.month - 1;
    }

    return now.month;
  }

  /// Cycle Year
  static int get cycleYear {
    if (now.day >= 25) {
      return now.year;
    }

    if (now.day <= 16) {
      return now.month == 1 ? now.year - 1 : now.year;
    }

    return now.year;
  }

  /// OPEN / CLOSED
  static String get status =>
      isDistributionOpen ? "OPEN" : "CLOSED";

  /// Current Cycle
  ///
  /// Example:
  /// 25 Jun 2026 → 16 Jul 2026
  static String get currentCycle {
    DateTime start;
    DateTime end;

    if (now.day >= 25) {
      start = DateTime(now.year, now.month, 25);
      end = DateTime(now.year, now.month + 1, 16);
    } else if (now.day <= 16) {
      start = DateTime(now.year, now.month - 1, 25);
      end = DateTime(now.year, now.month, 16);
    } else {
      start = DateTime(now.year, now.month, 25);
      end = DateTime(now.year, now.month + 1, 16);
    }

    return "${DateFormat("dd MMM yyyy").format(start)} → "
        "${DateFormat("dd MMM yyyy").format(end)}";
  }

  /// Next Distribution Date
  static String get nextCycleDate {
    DateTime next;

    if (isDistributionOpen) {
      next = DateTime(
        now.year,
        now.month + 1,
        25,
      );
    } else {
      next = DateTime(
        now.year,
        now.month,
        25,
      );
    }

    return DateFormat("dd MMM yyyy").format(next);
  }

  /// Remaining days until next cycle
  static int get remainingDays {
    DateTime next;

    if (isDistributionOpen) {
      next = DateTime(
        now.year,
        now.month + 1,
        25,
      );
    } else {
      next = DateTime(
        now.year,
        now.month,
        25,
      );
    }

    return next.difference(now).inDays;
  }

  /// Status Color
  static bool get isClosed => !isDistributionOpen;
}