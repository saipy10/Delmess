import 'package:delmess/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 5 Date & Timestamp Formatter Tests', () {
    test('formats today time properly in 12-hour format', () {
      final now = DateTime.now();
      final timeStr = AppDateFormatter.formatTime(now);
      expect(timeStr, isNotEmpty);
      expect(timeStr.contains('AM') || timeStr.contains('PM'), isTrue);
    });

    test('formatChatDivider returns Today for today', () {
      final now = DateTime.now();
      expect(AppDateFormatter.formatChatDivider(now), equals('Today'));
    });

    test('formatChatDivider returns Yesterday for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(AppDateFormatter.formatChatDivider(yesterday), equals('Yesterday'));
    });

    test('formatConversationDate returns time for today and Yesterday for 1 day ago', () {
      final now = DateTime.now();
      final todayStr = AppDateFormatter.formatConversationDate(now);
      expect(todayStr.contains('AM') || todayStr.contains('PM'), isTrue);

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(AppDateFormatter.formatConversationDate(yesterday), equals('Yesterday'));
    });
  });
}
