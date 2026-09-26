import 'dart:async';

import 'package:delmess/features/messages/domain/raw_sms_message.dart';
import 'package:delmess/features/sim/domain/sim_info.dart';

/// Service responsible for managing Dual-SIM subscriptions, SIM lifecycle transitions,
/// carrier mappings, and incoming SMS routing per slot.
class DualSimService {
  final Map<int, SimInfo> _activeSims = {};
  final StreamController<SimStateEvent> _simEventController =
      StreamController<SimStateEvent>.broadcast();

  DualSimService({List<SimInfo>? initialSims}) {
    if (initialSims != null) {
      for (final sim in initialSims) {
        _activeSims[sim.slotIndex] = sim;
      }
    } else {
      // Default initial dual-SIM configuration typical for India (Jio + Airtel)
      _activeSims[0] = const SimInfo(
        subscriptionId: 1,
        slotIndex: 0,
        displayName: 'SIM 1',
        carrierName: 'Jio',
        isDefaultData: true,
        isDefaultSms: true,
        isActive: true,
      );
      _activeSims[1] = const SimInfo(
        subscriptionId: 2,
        slotIndex: 1,
        displayName: 'SIM 2',
        carrierName: 'Airtel',
        isDefaultData: false,
        isDefaultSms: false,
        isActive: true,
      );
    }
  }

  /// Stream of SIM lifecycle events (inserted, removed, replaced, default changed, reboot).
  Stream<SimStateEvent> get simEventsStream => _simEventController.stream;

  /// Returns list of all currently active SIM subscriptions.
  Future<List<SimInfo>> getActiveSims() async {
    return _activeSims.values.where((s) => s.isActive).toList()
      ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));
  }

  /// Returns SIM metadata for specific physical slot index (0 or 1).
  Future<SimInfo?> getSimBySlot(int slotIndex) async {
    return _activeSims[slotIndex];
  }

  /// Returns SIM metadata for specific Android Telephony Subscription ID.
  Future<SimInfo?> getSimBySubscriptionId(int subscriptionId) async {
    for (final sim in _activeSims.values) {
      if (sim.subscriptionId == subscriptionId && sim.isActive) {
        return sim;
      }
    }
    return null;
  }

  /// Returns the current default SIM designated for sending/receiving SMS.
  Future<SimInfo?> getDefaultSmsSim() async {
    for (final sim in _activeSims.values) {
      if (sim.isDefaultSms && sim.isActive) {
        return sim;
      }
    }
    // Fallback: slot 0
    return _activeSims[0];
  }

  /// Updates the default SIM for SMS.
  Future<bool> setDefaultSmsSim(int slotIndex) async {
    if (!_activeSims.containsKey(slotIndex) || !_activeSims[slotIndex]!.isActive) {
      return false;
    }

    final updatedSims = <int, SimInfo>{};
    for (final entry in _activeSims.entries) {
      final isTarget = entry.key == slotIndex;
      updatedSims[entry.key] = entry.value.copyWith(isDefaultSms: isTarget);
    }

    _activeSims.clear();
    _activeSims.addAll(updatedSims);

    _simEventController.add(
      SimStateEvent(
        type: SimStateEventType.defaultChanged,
        slotIndex: slotIndex,
        simInfo: _activeSims[slotIndex],
      ),
    );

    return true;
  }

  /// Handles SIM card ejection / removal from a slot.
  void handleSimRemoval(int slotIndex) {
    final previous = _activeSims[slotIndex];
    if (previous != null) {
      _activeSims[slotIndex] = previous.copyWith(
        isActive: false,
        simState: SimCardState.absent,
      );

      _simEventController.add(
        SimStateEvent(
          type: SimStateEventType.removed,
          slotIndex: slotIndex,
          previousSimInfo: previous,
          simInfo: _activeSims[slotIndex],
        ),
      );

      // If the removed SIM was default SMS, transfer default to remaining active SIM
      if (previous.isDefaultSms) {
        for (final other in _activeSims.values) {
          if (other.slotIndex != slotIndex && other.isActive) {
            setDefaultSmsSim(other.slotIndex);
            break;
          }
        }
      }
    }
  }

  /// Handles SIM card replacement / swapping with a new carrier or ICCID.
  void handleSimReplacement(int slotIndex, SimInfo newSim) {
    final previous = _activeSims[slotIndex];
    _activeSims[slotIndex] = newSim;

    _simEventController.add(
      SimStateEvent(
        type: SimStateEventType.replaced,
        slotIndex: slotIndex,
        previousSimInfo: previous,
        simInfo: newSim,
      ),
    );
  }

  /// Handles newly inserted SIM card into an empty slot.
  void handleSimInserted(SimInfo sim) {
    _activeSims[sim.slotIndex] = sim;

    _simEventController.add(
      SimStateEvent(
        type: SimStateEventType.inserted,
        slotIndex: sim.slotIndex,
        simInfo: sim,
      ),
    );
  }

  /// Handles device boot / reboot completion restoring SIM state.
  void handleDeviceReboot(List<SimInfo> restoredSims) {
    _activeSims.clear();
    for (final sim in restoredSims) {
      _activeSims[sim.slotIndex] = sim;
    }

    for (final sim in restoredSims) {
      _simEventController.add(
        SimStateEvent(
          type: SimStateEventType.rebootRestored,
          slotIndex: sim.slotIndex,
          simInfo: sim,
        ),
      );
    }
  }

  /// Filters SMS collection for a specific SIM slot (e.g. view only SIM 1 messages).
  List<RawSmsMessage> filterMessagesBySim(List<RawSmsMessage> messages, int slotIndex) {
    return messages.where((m) => m.simSlot == slotIndex).toList();
  }

  /// Filters SMS collection for a specific carrier name (e.g. "Jio", "Airtel", "Vi", "BSNL").
  List<RawSmsMessage> filterMessagesByCarrier(List<RawSmsMessage> messages, String carrierName) {
    final lowerTarget = carrierName.toLowerCase();
    return messages.where((m) => (m.carrierName ?? '').toLowerCase().contains(lowerTarget)).toList();
  }

  void dispose() {
    _simEventController.close();
  }
}
