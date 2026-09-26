/// Target Android API releases.
enum AndroidRelease {
  android13, // API 33 (Tiramisu)
  android14, // API 34 (Upside Down Cake)
  android15, // API 35 (Vanilla Ice Cream)
  android16, // API 36 (Baklava)
}

/// Specifications and security constraints enforced per Android OS release.
class AndroidVersionProfile {
  final AndroidRelease release;
  final int apiLevel;
  final String codeName;
  final bool requiresNotificationPermission;
  final bool requiresExportedReceiverFlag;
  final bool enforces16KbPageAlignment;
  final bool supportsMultiActiveSim;
  final bool enforcesEdgeToEdge;

  const AndroidVersionProfile({
    required this.release,
    required this.apiLevel,
    required this.codeName,
    required this.requiresNotificationPermission,
    required this.requiresExportedReceiverFlag,
    required this.enforces16KbPageAlignment,
    required this.supportsMultiActiveSim,
    required this.enforcesEdgeToEdge,
  });

  /// Factory resolving profile by Android SDK API level.
  factory AndroidVersionProfile.forApiLevel(int apiLevel) {
    if (apiLevel >= 36) {
      return android16;
    } else if (apiLevel == 35) {
      return android15;
    } else if (apiLevel == 34) {
      return android14;
    } else {
      return android13;
    }
  }

  static const AndroidVersionProfile android13 = AndroidVersionProfile(
    release: AndroidRelease.android13,
    apiLevel: 33,
    codeName: 'Tiramisu',
    requiresNotificationPermission: true,
    requiresExportedReceiverFlag: false,
    enforces16KbPageAlignment: false,
    supportsMultiActiveSim: true,
    enforcesEdgeToEdge: false,
  );

  static const AndroidVersionProfile android14 = AndroidVersionProfile(
    release: AndroidRelease.android14,
    apiLevel: 34,
    codeName: 'Upside Down Cake',
    requiresNotificationPermission: true,
    requiresExportedReceiverFlag: true, // Context.RECEIVER_EXPORTED / RECEIVER_NOT_EXPORTED
    enforces16KbPageAlignment: false,
    supportsMultiActiveSim: true,
    enforcesEdgeToEdge: false,
  );

  static const AndroidVersionProfile android15 = AndroidVersionProfile(
    release: AndroidRelease.android15,
    apiLevel: 35,
    codeName: 'Vanilla Ice Cream',
    requiresNotificationPermission: true,
    requiresExportedReceiverFlag: true,
    enforces16KbPageAlignment: true, // 16KB native memory page size enforcement
    supportsMultiActiveSim: true,
    enforcesEdgeToEdge: true,
  );

  static const AndroidVersionProfile android16 = AndroidVersionProfile(
    release: AndroidRelease.android16,
    apiLevel: 36,
    codeName: 'Baklava',
    requiresNotificationPermission: true,
    requiresExportedReceiverFlag: true,
    enforces16KbPageAlignment: true,
    supportsMultiActiveSim: true,
    enforcesEdgeToEdge: true,
  );
}
