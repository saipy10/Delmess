import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents Android SMS runtime permission status.
enum SmsPermissionState { unknown, granted, denied, permanentlyDenied }

/// Abstract service handling SMS permissions.
abstract class SmsPermissionService {
  Future<SmsPermissionState> getPermissionState();
  Future<SmsPermissionState> requestSmsPermission();
  Future<bool> openAppSettings();
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

/// Fake SMS permission service for testing and development.
class FakeSmsPermissionService implements SmsPermissionService {
  SmsPermissionState _state;
  final bool autoGrant;

  FakeSmsPermissionService({
    SmsPermissionState initialState = SmsPermissionState.unknown,
    this.autoGrant = true,
  }) : _state = initialState;

  void setState(SmsPermissionState newState) {
    _state = newState;
  }

  @override
  Future<SmsPermissionState> getPermissionState() async => _state;

  @override
  Future<SmsPermissionState> requestSmsPermission() async {
    if (_state == SmsPermissionState.permanentlyDenied) {
      return SmsPermissionState.permanentlyDenied;
    }
    if (autoGrant) {
      _state = SmsPermissionState.granted;
    }
    return _state;
  }

  @override
  Future<bool> openAppSettings() async {
    return true;
  }
}

/// Provider for SmsPermissionService.
final smsPermissionServiceProvider = Provider<SmsPermissionService>((ref) {
  return AndroidSmsPermissionService();
});
