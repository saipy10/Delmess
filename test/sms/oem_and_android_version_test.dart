import 'package:delmess/features/sim/domain/android_version_profile.dart';
import 'package:delmess/features/sim/domain/oem_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 6 — OEM Device Compatibility Testing', () {
    // -------------------------------------------------------------------------
    // 1. Google Pixel
    // -------------------------------------------------------------------------
    test('Google Pixel (Stock AOSP standard intent extras & clean lifecycle)', () {
      final profile = OemCompatibilityProfile.forManufacturer('Google');
      expect(profile.oem, DeviceOem.pixel);
      expect(profile.requiresAutostartPermission, isFalse);
      expect(profile.requiresBatteryOptimizationExemption, isFalse);

      final intentExtras = {
        'subscription': 1,
        'slot': 0,
        'android.telephony.extra.SUBSCRIPTION_INDEX': 1,
      };

      final subId = profile.extractSubscriptionId(intentExtras);
      final slot = profile.extractSlotIndex(intentExtras);
      expect(subId, 1);
      expect(slot, 0);
    });

    // -------------------------------------------------------------------------
    // 2. Samsung
    // -------------------------------------------------------------------------
    test('Samsung (One UI Knox extras, phoneId, simSlot, and background policies)', () {
      final profile = OemCompatibilityProfile.forManufacturer('samsung');
      expect(profile.oem, DeviceOem.samsung);
      expect(profile.customUiName, 'One UI');
      expect(profile.requiresBatteryOptimizationExemption, isTrue);

      // Samsung One UI dual SIM intent payload variations
      final intentExtrasSim1 = {
        'simSlot': 0,
        'phoneId': 0,
        'subId': 1,
      };
      expect(profile.extractSlotIndex(intentExtrasSim1), 0);
      expect(profile.extractSubscriptionId(intentExtrasSim1), 1);

      final intentExtrasSim2 = {
        'simSlot': 1,
        'phoneId': 1,
        'subId': 2,
      };
      expect(profile.extractSlotIndex(intentExtrasSim2), 1);
      expect(profile.extractSubscriptionId(intentExtrasSim2), 2);
    });

    // -------------------------------------------------------------------------
    // 3. OnePlus
    // -------------------------------------------------------------------------
    test('OnePlus (OxygenOS dual SIM quick toggle, subscription_id, and standby sleep)', () {
      final profile = OemCompatibilityProfile.forManufacturer('OnePlus');
      expect(profile.oem, DeviceOem.oneplus);
      expect(profile.customUiName, 'OxygenOS');
      expect(profile.requiresBatteryOptimizationExemption, isTrue);

      final intentExtras = {
        'subscription_id': 2,
        'sim_slot': 1,
      };
      expect(profile.extractSubscriptionId(intentExtras), 2);
      expect(profile.extractSlotIndex(intentExtras), 1);
    });

    // -------------------------------------------------------------------------
    // 4. Xiaomi / Redmi
    // -------------------------------------------------------------------------
    test('Xiaomi/Redmi (MIUI / HyperOS simId extra, autostart protection)', () {
      final xiaomi = OemCompatibilityProfile.forManufacturer('Xiaomi');
      final redmi = OemCompatibilityProfile.forManufacturer('Redmi');
      final poco = OemCompatibilityProfile.forManufacturer('Poco');

      expect(xiaomi.oem, DeviceOem.xiaomi);
      expect(redmi.oem, DeviceOem.xiaomi);
      expect(poco.oem, DeviceOem.xiaomi);
      expect(xiaomi.requiresAutostartPermission, isTrue);
      expect(xiaomi.requiresBatteryOptimizationExemption, isTrue);

      // MIUI/HyperOS specific incoming SMS extra format
      final miuiExtrasSim1 = {'simId': 0, 'subscription': 1};
      expect(xiaomi.extractSlotIndex(miuiExtrasSim1), 0);

      final miuiExtrasSim2 = {'simId': 1, 'subscription': 2};
      expect(xiaomi.extractSlotIndex(miuiExtrasSim2), 1);
    });

    // -------------------------------------------------------------------------
    // 5. Realme
    // -------------------------------------------------------------------------
    test('Realme (realme UI quick freeze defense and slot_id routing)', () {
      final profile = OemCompatibilityProfile.forManufacturer('realme');
      expect(profile.oem, DeviceOem.realme);
      expect(profile.customUiName, 'realme UI');
      expect(profile.requiresAutostartPermission, isTrue);
      expect(profile.requiresBatteryOptimizationExemption, isTrue);

      final intentExtras = {
        'slot_id': 1,
        'sim_slot': 1,
        'subscription': 2,
      };
      expect(profile.extractSlotIndex(intentExtras), 1);
      expect(profile.extractSubscriptionId(intentExtras), 2);
    });

    // -------------------------------------------------------------------------
    // 6. Vivo
    // -------------------------------------------------------------------------
    test('Vivo / iQOO (Funtouch OS / OriginOS iManager power optimization)', () {
      final vivo = OemCompatibilityProfile.forManufacturer('vivo');
      final iqoo = OemCompatibilityProfile.forManufacturer('iQOO');

      expect(vivo.oem, DeviceOem.vivo);
      expect(iqoo.oem, DeviceOem.vivo);
      expect(vivo.requiresAutostartPermission, isTrue);
      expect(vivo.requiresBatteryOptimizationExemption, isTrue);

      final intentExtras = {
        'phoneId': 0,
        'subId': 1,
      };
      expect(vivo.extractSlotIndex(intentExtras), 0);
      expect(vivo.extractSubscriptionId(intentExtras), 1);
    });

    // -------------------------------------------------------------------------
    // 7. Oppo
    // -------------------------------------------------------------------------
    test('Oppo (ColorOS battery freeze defense and dual SIM slot indexing)', () {
      final profile = OemCompatibilityProfile.forManufacturer('OPPO');
      expect(profile.oem, DeviceOem.oppo);
      expect(profile.customUiName, 'ColorOS');
      expect(profile.requiresAutostartPermission, isTrue);
      expect(profile.requiresBatteryOptimizationExemption, isTrue);

      final intentExtras = {
        'subscription': 2,
        'sim_slot': 1,
      };
      expect(profile.extractSubscriptionId(intentExtras), 2);
      expect(profile.extractSlotIndex(intentExtras), 1);
    });

    // -------------------------------------------------------------------------
    // 8. Motorola
    // -------------------------------------------------------------------------
    test('Motorola (My UX stock AOSP dual-SIM Telephony compliance)', () {
      final profile = OemCompatibilityProfile.forManufacturer('motorola');
      expect(profile.oem, DeviceOem.motorola);
      expect(profile.requiresAutostartPermission, isFalse);
      expect(profile.requiresBatteryOptimizationExemption, isFalse);

      final intentExtras = {
        'subscription': 1,
        'slot': 0,
      };
      expect(profile.extractSubscriptionId(intentExtras), 1);
      expect(profile.extractSlotIndex(intentExtras), 0);
    });
  });

  group('Phase 6 — Android OS Version Matrix Testing (13, 14, 15, 16)', () {
    // -------------------------------------------------------------------------
    // Android 13 (API 33 - Tiramisu)
    // -------------------------------------------------------------------------
    test('Android 13 (API 33 - Tiramisu runtime notification permissions & dual SIM)', () {
      final profile = AndroidVersionProfile.forApiLevel(33);
      expect(profile.release, AndroidRelease.android13);
      expect(profile.apiLevel, 33);
      expect(profile.codeName, 'Tiramisu');
      expect(profile.requiresNotificationPermission, isTrue);
      expect(profile.requiresExportedReceiverFlag, isFalse);
      expect(profile.supportsMultiActiveSim, isTrue);
      expect(profile.enforces16KbPageAlignment, isFalse);
    });

    // -------------------------------------------------------------------------
    // Android 14 (API 34 - Upside Down Cake)
    // -------------------------------------------------------------------------
    test('Android 14 (API 34 - Upside Down Cake RECEIVER_EXPORTED broadcast flag)', () {
      final profile = AndroidVersionProfile.forApiLevel(34);
      expect(profile.release, AndroidRelease.android14);
      expect(profile.apiLevel, 34);
      expect(profile.codeName, 'Upside Down Cake');
      expect(profile.requiresNotificationPermission, isTrue);
      expect(profile.requiresExportedReceiverFlag, isTrue);
      expect(profile.supportsMultiActiveSim, isTrue);
      expect(profile.enforces16KbPageAlignment, isFalse);
    });

    // -------------------------------------------------------------------------
    // Android 15 (API 35 - Vanilla Ice Cream)
    // -------------------------------------------------------------------------
    test('Android 15 (API 35 - Vanilla Ice Cream 16KB native page alignment & edge-to-edge)', () {
      final profile = AndroidVersionProfile.forApiLevel(35);
      expect(profile.release, AndroidRelease.android15);
      expect(profile.apiLevel, 35);
      expect(profile.codeName, 'Vanilla Ice Cream');
      expect(profile.requiresNotificationPermission, isTrue);
      expect(profile.requiresExportedReceiverFlag, isTrue);
      expect(profile.enforces16KbPageAlignment, isTrue);
      expect(profile.enforcesEdgeToEdge, isTrue);
      expect(profile.supportsMultiActiveSim, isTrue);
    });

    // -------------------------------------------------------------------------
    // Android 16 (API 36 - Baklava)
    // -------------------------------------------------------------------------
    test('Android 16 (API 36 - Baklava multi-active SIM modern Telephony)', () {
      final profile = AndroidVersionProfile.forApiLevel(36);
      expect(profile.release, AndroidRelease.android16);
      expect(profile.apiLevel, 36);
      expect(profile.codeName, 'Baklava');
      expect(profile.requiresNotificationPermission, isTrue);
      expect(profile.requiresExportedReceiverFlag, isTrue);
      expect(profile.enforces16KbPageAlignment, isTrue);
      expect(profile.enforcesEdgeToEdge, isTrue);
      expect(profile.supportsMultiActiveSim, isTrue);
    });
  });
}
