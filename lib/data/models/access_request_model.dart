import 'user_model.dart';
import 'zone_model.dart';

/// Access Request Model
///
/// Represents a request for temporary access to a zone
class AccessRequestModel {
  final String id;

  /// User who made the request (nullable when not included in API response)
  final UserModel? user;

  /// Zone requested (nullable when not included in API response)
  final ZoneModel? zone;

  /// Start date of temporary access
  final DateTime startDate;

  /// End date of temporary access
  final DateTime endDate;

  /// Justification for the request
  final String justification;

  /// Status: PENDING, APPROVED, REJECTED
  final String status;

  /// Admin note (reason for approval/rejection)
  final String? adminNote;

  /// When the request was created
  final DateTime? createdAt;

  /// When the request was reviewed (approved/rejected)
  final DateTime? reviewedAt;

  /// ID of the admin who reviewed the request
  final String? reviewedBy;

  // Simplified fields (when user/zone objects are not included)
  final String? userId;
  final String? zoneId;
  final String? userName;
  final String? zoneName;

  const AccessRequestModel({
    required this.id,
    this.user,  // Optional: may be null if not included in API response
    this.zone,  // Optional: may be null if not included in API response
    required this.startDate,
    required this.endDate,
    required this.justification,
    required this.status,
    this.adminNote,
    this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.userId,
    this.zoneId,
    this.userName,
    this.zoneName,
  });

  factory AccessRequestModel.fromJson(Map<String, dynamic> json) {
    try {
      return AccessRequestModel(
        id: json['id'].toString(), // Convert to String (handles both int and String)
        // Parse user only if present (may be null in list responses)
        user: json['user'] != null
            ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        // Parse zone only if present (may be null in list responses)
        zone: json['zone'] != null
            ? ZoneModel.fromJson(json['zone'] as Map<String, dynamic>)
            : null,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        justification: json['justification'] as String,
        status: json['status'] as String,
        adminNote: json['adminNote'] as String?,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt'] as String) : null,
        reviewedBy: json['reviewedBy']?.toString(),
        userId: json['userId']?.toString(),
        zoneId: json['zoneId']?.toString(),
        userName: json['userName'] as String?,
        zoneName: json['zoneName'] as String?,
      );
    } catch (e) {
      print('❌ AccessRequestModel.fromJson error: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (user != null) 'user': user!.toJson(),
      if (zone != null) 'zone': zone!.toJson(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'justification': justification,
      'status': status,
      if (adminNote != null) 'adminNote': adminNote,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (userId != null) 'userId': userId,
      if (zoneId != null) 'zoneId': zoneId,
      if (userName != null) 'userName': userName,
      if (zoneName != null) 'zoneName': zoneName,
    };
  }

  AccessRequestModel copyWith({
    String? id,
    UserModel? user,
    ZoneModel? zone,
    DateTime? startDate,
    DateTime? endDate,
    String? justification,
    String? status,
    String? adminNote,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? userId,
    String? zoneId,
    String? userName,
    String? zoneName,
  }) {
    return AccessRequestModel(
      id: id ?? this.id,
      user: user ?? this.user,
      zone: zone ?? this.zone,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      justification: justification ?? this.justification,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      userId: userId ?? this.userId,
      zoneId: zoneId ?? this.zoneId,
      userName: userName ?? this.userName,
      zoneName: zoneName ?? this.zoneName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccessRequestModel &&
        other.id == id &&
        other.user == user &&
        other.zone == zone &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.justification == justification &&
        other.status == status &&
        other.adminNote == adminNote &&
        other.createdAt == createdAt &&
        other.reviewedAt == reviewedAt &&
        other.reviewedBy == reviewedBy &&
        other.userId == userId &&
        other.zoneId == zoneId &&
        other.userName == userName &&
        other.zoneName == zoneName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user.hashCode ^
        zone.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        justification.hashCode ^
        status.hashCode ^
        adminNote.hashCode ^
        createdAt.hashCode ^
        reviewedAt.hashCode ^
        reviewedBy.hashCode ^
        userId.hashCode ^
        zoneId.hashCode ^
        userName.hashCode ^
        zoneName.hashCode;
  }

  @override
  String toString() {
    return 'AccessRequestModel(id: $id, user: $user, zone: $zone, startDate: $startDate, endDate: $endDate, justification: $justification, status: $status, adminNote: $adminNote, createdAt: $createdAt, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, userId: $userId, zoneId: $zoneId, userName: $userName, zoneName: $zoneName)';
  }
}
