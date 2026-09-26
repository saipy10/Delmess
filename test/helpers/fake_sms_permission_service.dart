import 'package:delmess/core/services/sms_permission_service.dart';

/// Fake SMS permission service strictly for testing and development.
class FakeSmsPermissionService implements SmsPermissionService {
  SmsPermissionState _state;
  final bool autoGrant;
  bool _isDefaultApp;

  FakeSmsPermissionService({
    SmsPermissionState initialState = SmsPermissionState.unknown,
    this.autoGrant = true,
    this._isDefaultApp = false,
  }) : _state = initialState;

  void setState(SmsPermissionState newState) {
    _state = newState;
  }

  void setDefaultAppState(bool isDefault) {
    _isDefaultApp = isDefault;
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

  @override
  Future<bool> isDefaultSmsApp() async => _isDefaultApp;

  @override
  Future<bool> requestDefaultSmsApp() async {
    _isDefaultApp = true;
    return true;
  }

  @override
  Future<bool> sendSms(String recipient, String body) async {
    return true;
  }
}
