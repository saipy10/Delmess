import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmsPermissionService Tests', () {
    test('FakeSmsPermissionService manages state transitions', () async {
      final service = FakeSmsPermissionService(
        initialState: SmsPermissionState.unknown,
      );

      expect(await service.getPermissionState(), SmsPermissionState.unknown);

      // Request transitions to granted
      final requested = await service.requestSmsPermission();
      expect(requested, SmsPermissionState.granted);
      expect(await service.getPermissionState(), SmsPermissionState.granted);
    });

    test('FakeSmsPermissionService respects permanentlyDenied state', () async {
      final service = FakeSmsPermissionService(
        initialState: SmsPermissionState.permanentlyDenied,
      );

      final requested = await service.requestSmsPermission();
      expect(requested, SmsPermissionState.permanentlyDenied);
      expect(await service.openAppSettings(), true);
    });
  });
}
