import 'dart:async';

import 'package:delmess/features/messages/domain/raw_sms_message.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract contract for reading SMS data from the platform or a test source.
abstract class SmsDataSource {
  /// Returns the total number of SMS messages available.
  Future<int> getSmsCount();

  /// Fetches a batch of raw SMS messages with pagination.
  Future<List<RawSmsMessage>> getSmsBatch({
    required int limit,
    required int offset,
    DateTime? since,
  });

  /// Stream of new incoming SMS messages received in real-time.
  Stream<RawSmsMessage> get incomingSmsStream;
}

/// Native Android implementation using MethodChannel and EventChannel.
class AndroidSmsDataSource implements SmsDataSource {
  static const MethodChannel _methodChannel = MethodChannel(
    'com.delmess.smsorganizer/sms',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.delmess.smsorganizer/sms_events',
  );

  Stream<RawSmsMessage>? _incomingStream;

  @override
  Future<int> getSmsCount() async {
    try {
      final count = await _methodChannel.invokeMethod<int>('getSmsCount');
      return count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<List<RawSmsMessage>> getSmsBatch({
    required int limit,
    required int offset,
    DateTime? since,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        if (since != null) 'since': since.millisecondsSinceEpoch,
      };

      final result = await _methodChannel
          .invokeListMethod<Map<dynamic, dynamic>>('getSmsBatch', params);

      if (result == null) return [];
      return result.map((map) => RawSmsMessage.fromMap(map)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Stream<RawSmsMessage> get incomingSmsStream {
    _incomingStream ??= _eventChannel
        .receiveBroadcastStream()
        .where((event) => event is Map)
        .map((event) => RawSmsMessage.fromMap(event as Map<dynamic, dynamic>))
        .asBroadcastStream();
    return _incomingStream!;
  }
}

/// Fake SMS Data Source for unit, integration, and development testing.
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

  void addMessage(RawSmsMessage msg) {
    _messages.add(msg);
    _controller.add(msg);
  }

  void emitIncoming(RawSmsMessage msg) {
    _messages.insert(0, msg);
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
    var filtered = _messages;
    if (since != null) {
      filtered = filtered
          .where((m) => m.receivedAtMillis > since.millisecondsSinceEpoch)
          .toList();
    }
    filtered.sort((a, b) => b.receivedAtMillis.compareTo(a.receivedAtMillis));

    if (offset >= filtered.length) return [];
    final end = (offset + limit < filtered.length)
        ? offset + limit
        : filtered.length;
    return filtered.sublist(offset, end);
  }

  @override
  Stream<RawSmsMessage> get incomingSmsStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}

/// Riverpod provider for SmsDataSource. Defaults to AndroidSmsDataSource on Android platform.
final smsDataSourceProvider = Provider<SmsDataSource>((ref) {
  return AndroidSmsDataSource();
});
