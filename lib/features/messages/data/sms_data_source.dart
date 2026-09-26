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

/// Riverpod provider for SmsDataSource. Defaults to AndroidSmsDataSource on Android platform.
final smsDataSourceProvider = Provider<SmsDataSource>((ref) {
  return AndroidSmsDataSource();
});
