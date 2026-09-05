import 'package:intl/intl.dart';

/// Formatter for message timestamps, conversation dates, and OTP expiry.
class AppDateFormatter {
  AppDateFormatter._();

  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM dd');

  /// Formats date for conversation list (e.g. "10:45 AM", "Yesterday", or "Aug 28").
  static String formatConversationDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      return _timeFormat.format(dateTime);
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7 && difference > 1) {
      return DateFormat('EEE').format(dateTime);
    } else if (dateTime.year == now.year) {
      return _shortDateFormat.format(dateTime);
    } else {
      return _dateFormat.format(dateTime);
    }
  }

  /// Detailed timestamp for single message view (e.g. "Aug 31, 2026 • 02:45 PM").
  static String formatDetailedDate(DateTime dateTime) {
    return '${_dateFormat.format(dateTime)} • ${_timeFormat.format(dateTime)}';
  }

  /// Formats time only for message bubbles (e.g. "2:45 PM").
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Formats conversation chat date separator (e.g. "Today", "Yesterday", "Monday, Aug 24", "Aug 24, 2025").
  static String formatChatDivider(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7 && difference > 1) {
      return DateFormat('EEEE, MMM d').format(dateTime);
    } else if (dateTime.year == now.year) {
      return DateFormat('EEEE, MMM d').format(dateTime);
    } else {
      return DateFormat('EEEE, MMM d, yyyy').format(dateTime);
    }
  }
}
