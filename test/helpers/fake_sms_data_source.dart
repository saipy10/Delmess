import 'dart:async';

import 'package:delmess/features/messages/data/sms_data_source.dart';
import 'package:delmess/features/messages/domain/raw_sms_message.dart';

/// Fake SMS Data Source strictly for unit, integration, and development testing.
class FakeSmsDataSource implements SmsDataSource {
  final List<RawSmsMessage> _messages;
  final StreamController<RawSmsMessage> _controller =
      StreamController<RawSmsMessage>.broadcast();

  FakeSmsDataSource({List<RawSmsMessage>? initialMessages})
      : _messages = List.from(initialMessages ?? _defaultSampleMessages);

  static final List<RawSmsMessage> _defaultSampleMessages = [
    const RawSmsMessage(
      id: 'fake_1',
      threadId: 'thread_hdfc',
      sender: 'AD-HDFCBK-T',
      body: 'Your OTP is 482921 for transaction of INR 1,500.00 at AMAZON.',
      receivedAtMillis: 1756730000000,
      isRead: false,
    ),
    const RawSmsMessage(
      id: 'fake_2',
      threadId: 'thread_swiggy',
      sender: 'BZ-SWIGGY-P',
      body: 'Craving Biryani? Get 50% OFF up to Rs 100 on your favorite meals!',
      receivedAtMillis: 1756720000000,
      isRead: true,
    ),
    const RawSmsMessage(
      id: 'fake_3',
      threadId: 'thread_jio',
      sender: 'JM-JIOINF-S',
      body: 'Your daily 1.5GB high-speed data balance is 50% consumed.',
      receivedAtMillis: 1756710000000,
      isRead: true,
    ),
  ];

  bool _isSorted = false;

  void addMessage(RawSmsMessage msg) {
    _messages.add(msg);
    _isSorted = false;
    _controller.add(msg);
  }

  void emitIncoming(RawSmsMessage msg) {
    _messages.insert(0, msg);
    _isSorted = false;
    _controller.add(msg);
  }

  @override
  Future<int> getSmsCount() async => _messages.length;

  @override
  Future<List<RawSmsMessage>> getSmsBatch({
    required int limit,
    required int offset,
    DateTime? since,
  }) async {
    if (since != null) {
      final filtered = _messages
          .where((m) => m.receivedAtMillis > since.millisecondsSinceEpoch)
          .toList();
      filtered.sort((a, b) => b.receivedAtMillis.compareTo(a.receivedAtMillis));
      if (offset >= filtered.length) return [];
      final end = (offset + limit < filtered.length)
          ? offset + limit
          : filtered.length;
      return filtered.sublist(offset, end);
    }

    if (!_isSorted) {
      _messages.sort((a, b) => b.receivedAtMillis.compareTo(a.receivedAtMillis));
      _isSorted = true;
    }

    if (offset >= _messages.length) return [];
    final end = (offset + limit < _messages.length)
        ? offset + limit
        : _messages.length;
    return _messages.sublist(offset, end);
  }

  @override
  Stream<RawSmsMessage> get incomingSmsStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
