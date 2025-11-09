import 'package:equatable/equatable.dart';

/// Zone Entity
///
/// Pure business object representing a physical zone
/// ⭐ MULTI-POSTES: allowedPosts is a List<String>
class Zone extends Equatable {
  final String id;
  final String name;
  final String building;
  final int floor;
  final String securityLevel;
  final String qrCode;
  final bool isActive;
  final bool isOpenToAll;

  /// ⭐ MULTI-POSTES: List of allowed posts
  final List<String> allowedPosts;

  final DateTime? createdAt;
  final String? description;

  const Zone({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.securityLevel,
    required this.qrCode,
    required this.isActive,
    required this.isOpenToAll,
    required this.allowedPosts,
    this.createdAt,
    this.description,
  });

  /// Check if security level is HIGH
  bool get isHighSecurity => securityLevel.toUpperCase() == 'HIGH';

  /// Check if security level is MEDIUM
  bool get isMediumSecurity => securityLevel.toUpperCase() == 'MEDIUM';

  /// Check if security level is LOW
  bool get isLowSecurity => securityLevel.toUpperCase() == 'LOW';

  /// Get full location string
  String get fullLocation => '$building - Étage $floor';

  @override
  List<Object?> get props => [
        id,
        name,
        building,
        floor,
        securityLevel,
        qrCode,
        isActive,
        isOpenToAll,
        allowedPosts,
        createdAt,
        description,
      ];
}
