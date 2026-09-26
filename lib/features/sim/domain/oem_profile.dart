/// Major smartphone OEM device types prevalent in the Indian smartphone market.
enum DeviceOem {
  pixel,
  samsung,
  oneplus,
  xiaomi,
  realme,
  vivo,
  oppo,
  motorola,
  generic,
}

/// Compatibility specification and intent extra extraction rules for OEM-specific Android flavors.
class OemCompatibilityProfile {
  final DeviceOem oem;
  final String manufacturerName;
  final String customUiName;
  final List<String> subscriptionExtraKeys;
  final List<String> slotExtraKeys;
  final bool requiresAutostartPermission;
  final bool requiresBatteryOptimizationExemption;
  final String backgroundExecutionGuidance;

  const OemCompatibilityProfile({
    required this.oem,
    required this.manufacturerName,
    required this.customUiName,
    required this.subscriptionExtraKeys,
    required this.slotExtraKeys,
    this.requiresAutostartPermission = false,
    this.requiresBatteryOptimizationExemption = false,
    required this.backgroundExecutionGuidance,
  });

  /// Factory resolving OEM profile from Build.MANUFACTURER string.
  factory OemCompatibilityProfile.forManufacturer(String manufacturer) {
    final lower = manufacturer.toLowerCase();
    if (lower.contains('google')) {
      return pixelProfile;
    } else if (lower.contains('samsung')) {
      return samsungProfile;
    } else if (lower.contains('oneplus')) {
      return oneplusProfile;
    } else if (lower.contains('xiaomi') || lower.contains('redmi') || lower.contains('poco')) {
      return xiaomiProfile;
    } else if (lower.contains('realme')) {
      return realmeProfile;
    } else if (lower.contains('vivo') || lower.contains('iqoo')) {
      return vivoProfile;
    } else if (lower.contains('oppo')) {
      return oppoProfile;
    } else if (lower.contains('motorola') || lower.contains('moto')) {
      return motorolaProfile;
    }
    return genericProfile;
  }

  /// Extracts subscriptionId from OEM-customized incoming SMS intent extras.
  int extractSubscriptionId(Map<String, dynamic> extras, {int fallback = -1}) {
    for (final key in subscriptionExtraKeys) {
      if (extras.containsKey(key)) {
        final val = extras[key];
        if (val is int) return val;
        final parsed = int.tryParse(val?.toString() ?? '');
        if (parsed != null && parsed >= 0) return parsed;
      }
    }
    return fallback;
  }

  /// Extracts SIM slot index (0 for SIM 1, 1 for SIM 2) from OEM intent extras.
  int extractSlotIndex(Map<String, dynamic> extras, {int fallback = 0}) {
    for (final key in slotExtraKeys) {
      if (extras.containsKey(key)) {
        final val = extras[key];
        if (val is int) return val;
        final parsed = int.tryParse(val?.toString() ?? '');
        if (parsed != null && parsed >= 0) return parsed;
      }
    }
    // Fallback: If subscriptionId is available, slot 0 is subId 1, slot 1 is subId 2
    final subId = extractSubscriptionId(extras);
    if (subId > 0) {
      return (subId - 1).clamp(0, 1);
    }
    return fallback;
  }

  // Pre-configured profiles for all requested OEMs

  static const OemCompatibilityProfile pixelProfile = OemCompatibilityProfile(
    oem: DeviceOem.pixel,
    manufacturerName: 'Google',
    customUiName: 'Pixel Stock Android',
    subscriptionExtraKeys: ['subscription', 'android.telephony.extra.SUBSCRIPTION_INDEX'],
    slotExtraKeys: ['slot', 'simId'],
    requiresAutostartPermission: false,
    requiresBatteryOptimizationExemption: false,
    backgroundExecutionGuidance: 'Stock AOSP behavior. Follows standard JobScheduler and WorkManager.',
  );

  static const OemCompatibilityProfile samsungProfile = OemCompatibilityProfile(
    oem: DeviceOem.samsung,
    manufacturerName: 'Samsung',
    customUiName: 'One UI',
    subscriptionExtraKeys: ['subscription', 'subId', 'simSlot', 'phoneId'],
    slotExtraKeys: ['simSlot', 'phoneId', 'slotId', 'slot'],
    requiresAutostartPermission: false,
    requiresBatteryOptimizationExemption: true,
    backgroundExecutionGuidance: 'Samsung One UI Device Care put unused apps to sleep. Exemption recommended.',
  );

  static const OemCompatibilityProfile oneplusProfile = OemCompatibilityProfile(
    oem: DeviceOem.oneplus,
    manufacturerName: 'OnePlus',
    customUiName: 'OxygenOS',
    subscriptionExtraKeys: ['subscription', 'subscription_id', 'sim_id'],
    slotExtraKeys: ['slot', 'sim_slot', 'slotId'],
    requiresAutostartPermission: false,
    requiresBatteryOptimizationExemption: true,
    backgroundExecutionGuidance: 'OxygenOS Deep Optimization and Sleep Standby Optimization requires exemption.',
  );

  static const OemCompatibilityProfile xiaomiProfile = OemCompatibilityProfile(
    oem: DeviceOem.xiaomi,
    manufacturerName: 'Xiaomi/Redmi',
    customUiName: 'MIUI / HyperOS',
    subscriptionExtraKeys: ['simId', 'subscription', 'extra_sim_id'],
    slotExtraKeys: ['simId', 'slot', 'sim_slot'],
    requiresAutostartPermission: true,
    requiresBatteryOptimizationExemption: true,
    backgroundExecutionGuidance: 'MIUI/HyperOS kills background SMS receivers without explicit Autostart permission.',
  );

  static const OemCompatibilityProfile realmeProfile = OemCompatibilityProfile(
    oem: DeviceOem.realme,
    manufacturerName: 'Realme',
    customUiName: 'realme UI',
    subscriptionExtraKeys: ['subscription', 'sim_id', 'slot_id'],
    slotExtraKeys: ['sim_slot', 'slot', 'phone_id'],
    requiresAutostartPermission: true,
    requiresBatteryOptimizationExemption: true,
    backgroundExecutionGuidance: 'realme UI App Quick Freeze kills non-exempt background broadcast handlers.',
  );

  static const OemCompatibilityProfile vivoProfile = OemCompatibilityProfile(
    oem: DeviceOem.vivo,
    manufacturerName: 'Vivo',
    customUiName: 'Funtouch OS / OriginOS',
    subscriptionExtraKeys: ['subscription', 'sim_id', 'subId'],
    slotExtraKeys: ['slot', 'sim_slot', 'phoneId'],
    requiresAutostartPermission: true,
    requiresBatteryOptimizationExemption: true,
    backgroundExecutionGuidance: 'Vivo iManager requires High Background Power Consumption permission.',
  );

  static const OemCompatibilityProfile oppoProfile = OemCompatibilityProfile(
    oem: DeviceOem.oppo,
    manufacturerName: 'Oppo',
    customUiName: 'ColorOS',
    subscriptionExtraKeys: ['subscription', 'sim_id', 'subscription_id'],
    slotExtraKeys: ['sim_slot', 'slot', 'slot_id'],
    requiresAutostartPermission: true,
    requiresBatteryOptimizationExemption: true,
    backgroundExecutionGuidance: 'ColorOS aggressive battery freezing blocks real-time SMS broadcasts without auto-launch.',
  );

  static const OemCompatibilityProfile motorolaProfile = OemCompatibilityProfile(
    oem: DeviceOem.motorola,
    manufacturerName: 'Motorola',
    customUiName: 'My UX',
    subscriptionExtraKeys: ['subscription', 'android.telephony.extra.SUBSCRIPTION_INDEX'],
    slotExtraKeys: ['slot', 'simId'],
    requiresAutostartPermission: false,
    requiresBatteryOptimizationExemption: false,
    backgroundExecutionGuidance: 'Near-stock Motorola UX behaves identically to standard AOSP.',
  );

  static const OemCompatibilityProfile genericProfile = OemCompatibilityProfile(
    oem: DeviceOem.generic,
    manufacturerName: 'Generic Android',
    customUiName: 'AOSP',
    subscriptionExtraKeys: ['subscription', 'android.telephony.extra.SUBSCRIPTION_INDEX', 'simId', 'slot'],
    slotExtraKeys: ['slot', 'simSlot', 'simId'],
    requiresAutostartPermission: false,
    requiresBatteryOptimizationExemption: false,
    backgroundExecutionGuidance: 'Standard AOSP compliance.',
  );
}
