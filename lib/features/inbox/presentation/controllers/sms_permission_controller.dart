import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier managing application SMS permission status.
class SmsPermissionNotifier extends Notifier<SmsPermissionState> {
  SmsPermissionService get _service => ref.read(smsPermissionServiceProvider);

  @override
  SmsPermissionState build() {
    // Check initial permission asynchronously
    Future.microtask(() => checkPermission());
    return SmsPermissionState.unknown;
  }

  Future<SmsPermissionState> checkPermission() async {
    final stateResult = await _service.getPermissionState();
    state = stateResult;
    return stateResult;
  }

  Future<SmsPermissionState> requestPermission() async {
    final stateResult = await _service.requestSmsPermission();
    state = stateResult;
    return stateResult;
  }

  Future<bool> openSettings() async {
    return _service.openAppSettings();
  }
}

final smsPermissionControllerProvider =
    NotifierProvider<SmsPermissionNotifier, SmsPermissionState>(
      () => SmsPermissionNotifier(),
    );
