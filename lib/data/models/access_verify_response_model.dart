/// Access Verify Response Model
///
/// Response from POST /api/access/verify
///
/// Status can be:
/// - GRANTED: Access is granted (zones LOW/MEDIUM)
/// - PENDING_PIN: Access requires PIN verification (zones HIGH)
/// - DENIED: Access is denied
class AccessVerifyResponseModel {
  /// Status: GRANTED, PENDING_PIN, DENIED
  final String status;

  /// Whether PIN is required (status = PENDING_PIN)
  final bool requiresPin;

  /// Event ID for this access attempt
  /// Used for PIN verification when status = PENDING_PIN
  final int? eventId;

  /// Zone name
  final String? zoneName;

  /// Timestamp of the access attempt
  final String? timestamp;

  /// Reason for denial (only present when status = DENIED)
  final String? reason;

  /// Device unlocked status (returned from verify PIN)
  final bool? deviceUnlocked;

  const AccessVerifyResponseModel({
    required this.status,
    this.requiresPin = false,
    this.eventId,
    this.zoneName,
    this.timestamp,
    this.reason,
    this.deviceUnlocked,
  });

  factory AccessVerifyResponseModel.fromJson(Map<String, dynamic> json) {
    return AccessVerifyResponseModel(
      status: json['status'] as String,
      requiresPin: json['requiresPin'] as bool? ?? false,
      eventId: json['eventId'] as int?,
      zoneName: json['zoneName'] as String?,
      timestamp: json['timestamp'] as String?,
      reason: json['reason'] as String?,
      deviceUnlocked: json['deviceUnlocked'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'requiresPin': requiresPin,
      if (eventId != null) 'eventId': eventId,
      if (zoneName != null) 'zoneName': zoneName,
      if (timestamp != null) 'timestamp': timestamp,
      if (reason != null) 'reason': reason,
      if (deviceUnlocked != null) 'deviceUnlocked': deviceUnlocked,
    };
  }

  AccessVerifyResponseModel copyWith({
    String? status,
    bool? requiresPin,
    int? eventId,
    String? zoneName,
    String? timestamp,
    String? reason,
    bool? deviceUnlocked,
  }) {
    return AccessVerifyResponseModel(
      status: status ?? this.status,
      requiresPin: requiresPin ?? this.requiresPin,
      eventId: eventId ?? this.eventId,
      zoneName: zoneName ?? this.zoneName,
      timestamp: timestamp ?? this.timestamp,
      reason: reason ?? this.reason,
      deviceUnlocked: deviceUnlocked ?? this.deviceUnlocked,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccessVerifyResponseModel &&
        other.status == status &&
        other.requiresPin == requiresPin &&
        other.eventId == eventId &&
        other.zoneName == zoneName &&
        other.timestamp == timestamp &&
        other.reason == reason &&
        other.deviceUnlocked == deviceUnlocked;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        requiresPin.hashCode ^
        eventId.hashCode ^
        zoneName.hashCode ^
        timestamp.hashCode ^
        reason.hashCode ^
        deviceUnlocked.hashCode;
  }

  @override
  String toString() {
    return 'AccessVerifyResponseModel(status: $status, requiresPin: $requiresPin, eventId: $eventId, zoneName: $zoneName, timestamp: $timestamp, reason: $reason, deviceUnlocked: $deviceUnlocked)';
  }
}
