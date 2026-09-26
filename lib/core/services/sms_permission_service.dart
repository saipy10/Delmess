import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents Android SMS runtime permission status.
enum SmsPermissionState { unknown, granted, denied, permanentlyDenied }

/// Abstract service handling SMS permissions and Default SMS App operations.
abstract class SmsPermissionService {
  Future<SmsPermissionState> getPermissionState();
  Future<SmsPermissionState> requestSmsPermission();
  Future<bool> openAppSettings();
  Future<bool> isDefaultSmsApp();
  Future<bool> requestDefaultSmsApp();
  Future<bool> sendSms(String recipient, String body);
}

/// Native Android implementation using MethodChannel.
class AndroidSmsPermissionService implements SmsPermissionService {
  static const MethodChannel _channel = MethodChannel(
    'com.delmess.smsorganizer/sms',
  );

  @override
  Future<SmsPermissionState> getPermissionState() async {
    try {
      final stateStr = await _channel.invokeMethod<String>(
        'getPermissionState',
      );
      return _parseState(stateStr);
    } catch (_) {
      return SmsPermissionState.unknown;
    }
  }

  @override
  Future<SmsPermissionState> requestSmsPermission() async {
    try {
      final stateStr = await _channel.invokeMethod<String>(
        'requestPermissions',
      );
      return _parseState(stateStr);
    } catch (_) {
      return SmsPermissionState.denied;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      final res = await _channel.invokeMethod<bool>('openAppSettings');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isDefaultSmsApp() async {
    try {
      final res = await _channel.invokeMethod<bool>('isDefaultSmsApp');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestDefaultSmsApp() async {
    try {
      final res = await _channel.invokeMethod<bool>('requestDefaultSmsApp');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> sendSms(String recipient, String body) async {
    try {
      final res = await _channel.invokeMethod<bool>('sendSms', {
        'recipient': recipient,
        'body': body,
      });
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  SmsPermissionState _parseState(String? state) {
    switch (state) {
      case 'granted':
        return SmsPermissionState.granted;
      case 'denied':
        return SmsPermissionState.denied;
      case 'permanentlyDenied':
        return SmsPermissionState.permanentlyDenied;
      default:
        return SmsPermissionState.unknown;
    }
  }
}

/// Provider for SmsPermissionService.
final smsPermissionServiceProvider = Provider<SmsPermissionService>((ref) {
  return AndroidSmsPermissionService();
});
