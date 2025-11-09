import 'package:equatable/equatable.dart';

/// Access Event Entity
///
/// Pure business object representing an access attempt
class AccessEvent extends Equatable {
  final String id;
  final String userId;
  final String zoneId;
  final DateTime timestamp;
  final String status;
  final String method;
  final String? reason;

  /// ⭐ IMPORTANT: Whether device was unlocked
  final bool deviceUnlocked;

  const AccessEvent({
    required this.id,
    required this.userId,
    required this.zoneId,
    required this.timestamp,
    required this.status,
    required this.method,
    this.reason,
    required this.deviceUnlocked,
  });

  /// Check if access was granted
  bool get isGranted => status.toUpperCase() == 'GRANTED';

  /// Check if access was denied
  bool get isDenied => status.toUpperCase() == 'DENIED';

  @override
  List<Object?> get props => [
        id,
        userId,
        zoneId,
        timestamp,
        status,
        method,
        reason,
        deviceUnlocked,
      ];
}
