/// Data Transfer Object representing raw, unclassified SMS records from native platform.
class RawSmsMessage {
  final String id;
  final String threadId;
  final String sender;
  final String body;
  final int receivedAtMillis;
  final bool isRead;
  final int? subId;
  final int? simSlot;
  final String? carrierName;

  const RawSmsMessage({
    required this.id,
    required this.threadId,
    required this.sender,
    required this.body,
    required this.receivedAtMillis,
    this.isRead = false,
    this.subId,
    this.simSlot,
    this.carrierName,
  });

  factory RawSmsMessage.fromMap(Map<dynamic, dynamic> map) {
    return RawSmsMessage(
      id: map['id']?.toString() ?? '',
      threadId: map['threadId']?.toString() ?? map['id']?.toString() ?? '',
      sender: map['sender']?.toString() ?? 'Unknown',
      body: map['body']?.toString() ?? '',
      receivedAtMillis: map['receivedAt'] is int
          ? map['receivedAt'] as int
          : int.tryParse(map['receivedAt']?.toString() ?? '') ??
                DateTime.now().millisecondsSinceEpoch,
      isRead: map['isRead'] == true || map['isRead'] == 1,
      subId: map['subId'] is int
          ? map['subId'] as int
          : int.tryParse(map['subId']?.toString() ?? ''),
      simSlot: map['simSlot'] is int
          ? map['simSlot'] as int
          : int.tryParse(map['simSlot']?.toString() ?? ''),
      carrierName: map['carrierName']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'threadId': threadId,
      'sender': sender,
      'body': body,
      'receivedAt': receivedAtMillis,
      'isRead': isRead,
      'subId': subId,
      'simSlot': simSlot,
      'carrierName': carrierName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RawSmsMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          threadId == other.threadId &&
          sender == other.sender &&
          body == other.body &&
          receivedAtMillis == other.receivedAtMillis &&
          isRead == other.isRead &&
          subId == other.subId &&
          simSlot == other.simSlot &&
          carrierName == other.carrierName;

  @override
  int get hashCode =>
      id.hashCode ^
      threadId.hashCode ^
      sender.hashCode ^
      body.hashCode ^
      receivedAtMillis.hashCode ^
      isRead.hashCode ^
      subId.hashCode ^
      simSlot.hashCode ^
      carrierName.hashCode;
}
