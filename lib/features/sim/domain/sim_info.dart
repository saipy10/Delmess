/// State of a physical or eSIM card on the device.
enum SimCardState {
  ready,
  absent,
  notReady,
  pinRequired,
  unknown,
}

/// Representation of a SIM subscription on a dual-SIM or multi-SIM device.
class SimInfo {
  final int subscriptionId;
  final int slotIndex; // 0 = SIM 1, 1 = SIM 2
  final String displayName;
  final String carrierName;
  final String countryIso;
  final bool isDefaultData;
  final bool isDefaultSms;
  final bool isActive;
  final SimCardState simState;

  const SimInfo({
    required this.subscriptionId,
    required this.slotIndex,
    required this.displayName,
    required this.carrierName,
    this.countryIso = 'in',
    this.isDefaultData = false,
    this.isDefaultSms = false,
    this.isActive = true,
    this.simState = SimCardState.ready,
  });

  /// User-friendly label (e.g. "SIM 1: Jio 5G" or "SIM 2: Airtel")
  String get formattedLabel => 'SIM ${slotIndex + 1}: $carrierName';

  SimInfo copyWith({
    int? subscriptionId,
    int? slotIndex,
    String? displayName,
    String? carrierName,
    String? countryIso,
    bool? isDefaultData,
    bool? isDefaultSms,
    bool? isActive,
    SimCardState? simState,
  }) {
    return SimInfo(
      subscriptionId: subscriptionId ?? this.subscriptionId,
      slotIndex: slotIndex ?? this.slotIndex,
      displayName: displayName ?? this.displayName,
      carrierName: carrierName ?? this.carrierName,
      countryIso: countryIso ?? this.countryIso,
      isDefaultData: isDefaultData ?? this.isDefaultData,
      isDefaultSms: isDefaultSms ?? this.isDefaultSms,
      isActive: isActive ?? this.isActive,
      simState: simState ?? this.simState,
    );
  }

  factory SimInfo.fromMap(Map<dynamic, dynamic> map) {
    return SimInfo(
      subscriptionId: map['subscriptionId'] is int
          ? map['subscriptionId'] as int
          : int.tryParse(map['subscriptionId']?.toString() ?? '1') ?? 1,
      slotIndex: map['slotIndex'] is int
          ? map['slotIndex'] as int
          : int.tryParse(map['slotIndex']?.toString() ?? '0') ?? 0,
      displayName: map['displayName']?.toString() ?? 'SIM',
      carrierName: map['carrierName']?.toString() ?? 'Carrier',
      countryIso: map['countryIso']?.toString() ?? 'in',
      isDefaultData: map['isDefaultData'] == true,
      isDefaultSms: map['isDefaultSms'] == true,
      isActive: map['isActive'] != false,
      simState: _parseState(map['simState']?.toString()),
    );
  }

  static SimCardState _parseState(String? state) {
    switch (state?.toLowerCase()) {
      case 'ready':
        return SimCardState.ready;
      case 'absent':
        return SimCardState.absent;
      case 'notready':
        return SimCardState.notReady;
      case 'pinrequired':
        return SimCardState.pinRequired;
      default:
        return SimCardState.ready;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'subscriptionId': subscriptionId,
      'slotIndex': slotIndex,
      'displayName': displayName,
      'carrierName': carrierName,
      'countryIso': countryIso,
      'isDefaultData': isDefaultData,
      'isDefaultSms': isDefaultSms,
      'isActive': isActive,
      'simState': simState.name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimInfo &&
          runtimeType == other.runtimeType &&
          subscriptionId == other.subscriptionId &&
          slotIndex == other.slotIndex &&
          displayName == other.displayName &&
          carrierName == other.carrierName &&
          isDefaultSms == other.isDefaultSms &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      subscriptionId.hashCode ^
      slotIndex.hashCode ^
      displayName.hashCode ^
      carrierName.hashCode ^
      isDefaultSms.hashCode ^
      isActive.hashCode;
}

/// Lifecycle event types for SIM cards.
enum SimStateEventType {
  inserted,
  removed,
  replaced,
  defaultChanged,
  rebootRestored,
}

/// Event model representing SIM state changes.
class SimStateEvent {
  final SimStateEventType type;
  final int slotIndex;
  final SimInfo? simInfo;
  final SimInfo? previousSimInfo;
  final DateTime timestamp;

  SimStateEvent({
    required this.type,
    required this.slotIndex,
    this.simInfo,
    this.previousSimInfo,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
