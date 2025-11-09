/// Access Event Model
///
/// Represents a single access attempt (granted or denied)
class AccessEventModel {
  final String id;
  final String userId;
  final String zoneId;
  final DateTime timestamp;

  /// Status: GRANTED, DENIED
  final String status;

  /// Method: QR, QR_PIN
  final String method;

  /// Reason for denial (if status = DENIED)
  final String? reason;

  /// ⭐ IMPORTANT: Whether device was unlocked with native security
  /// This is sent by the mobile app to confirm the user unlocked their phone
  final bool deviceUnlocked;

  // Optional fields
  final String? zoneName;
  final String? userEmail;

  const AccessEventModel({
    required this.id,
    required this.userId,
    required this.zoneId,
    required this.timestamp,
    required this.status,
    required this.method,
    this.reason,
    this.deviceUnlocked = false,
    this.zoneName,
    this.userEmail,
  });

  factory AccessEventModel.fromJson(Map<String, dynamic> json) {
    return AccessEventModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      zoneId: json['zoneId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      method: json['method'] as String,
      reason: json['reason'] as String?,
      deviceUnlocked: json['deviceUnlocked'] as bool? ?? false,
      zoneName: json['zoneName'] as String?,
      userEmail: json['userEmail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'zoneId': zoneId,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'method': method,
      if (reason != null) 'reason': reason,
      'deviceUnlocked': deviceUnlocked,
      if (zoneName != null) 'zoneName': zoneName,
      if (userEmail != null) 'userEmail': userEmail,
    };
  }

  AccessEventModel copyWith({
    String? id,
    String? userId,
    String? zoneId,
    DateTime? timestamp,
    String? status,
    String? method,
    String? reason,
    bool? deviceUnlocked,
    String? zoneName,
    String? userEmail,
  }) {
    return AccessEventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      zoneId: zoneId ?? this.zoneId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      method: method ?? this.method,
      reason: reason ?? this.reason,
      deviceUnlocked: deviceUnlocked ?? this.deviceUnlocked,
      zoneName: zoneName ?? this.zoneName,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccessEventModel &&
        other.id == id &&
        other.userId == userId &&
        other.zoneId == zoneId &&
        other.timestamp == timestamp &&
        other.status == status &&
        other.method == method &&
        other.reason == reason &&
        other.deviceUnlocked == deviceUnlocked &&
        other.zoneName == zoneName &&
        other.userEmail == userEmail;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        zoneId.hashCode ^
        timestamp.hashCode ^
        status.hashCode ^
        method.hashCode ^
        reason.hashCode ^
        deviceUnlocked.hashCode ^
        zoneName.hashCode ^
        userEmail.hashCode;
  }

  @override
  String toString() {
    return 'AccessEventModel(id: $id, userId: $userId, zoneId: $zoneId, timestamp: $timestamp, status: $status, method: $method, reason: $reason, deviceUnlocked: $deviceUnlocked, zoneName: $zoneName, userEmail: $userEmail)';
  }
}
