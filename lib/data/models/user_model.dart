/// User Model
///
/// ⭐ MULTI-POSTES: posts is a List<String>
/// A user can have MULTIPLE posts (e.g., ['DEVELOPER', 'DEVOPS', 'SECURITY_AGENT'])
class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  /// ⭐ MULTI-POSTES: List of posts (NOT a single String)
  /// Example: ['DEVELOPER', 'DEVOPS', 'SECURITY_AGENT']
  final List<String> posts;

  final String department;
  final bool isActive;
  final bool isAdmin;

  final String? photoUrl;
  final DateTime? hireDate;
  final DateTime? createdAt;

  // Optional fields for auth/account management
  final String? pinCode;
  final bool? accountLocked;
  final DateTime? accountLockedUntil;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.posts,
    required this.department,
    required this.isActive,
    required this.isAdmin,
    this.photoUrl,
    this.hireDate,
    this.createdAt,
    this.pinCode,
    this.accountLocked,
    this.accountLockedUntil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseIntSafely(json['id']),
      email: json['email'] as String,
      firstName: json['firstname'] as String,
      lastName: json['lastname'] as String,
      role: 'role' ,// json['role'] as String,
      posts: _parseListSafely(json['posts']),
      department: json['department'] as String,
      isActive: _parseBoolSafely(json['isActive']),
      isAdmin: false, //json['isAdmin'] as bool,
      photoUrl: json['photoUrl'] as String?,
      hireDate: json['hireDate'] != null ? DateTime.parse(json['hireDate'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      pinCode: json['pinCode'] as String?,
      accountLocked: json['accountLocked'] as bool?,
      accountLockedUntil: json['accountLockedUntil'] != null
          ? DateTime.parse(json['accountLockedUntil'] as String)
          : null,
    );
  }

  /// Helper method to safely parse int from dynamic (handles both int and String)
  static int _parseIntSafely(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.parse(value);
    } else if (value is double) {
      return value.toInt();
    } else {
      throw FormatException('Cannot parse $value to int');
    }
  }

  /// Helper method to safely parse bool from dynamic
  static bool _parseBoolSafely(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is int) {
      return value != 0;
    } else if (value is String) {
      final lowerValue = value.toLowerCase();
      return lowerValue == 'true' || lowerValue == '1';
    } else {
      return false;
    }
  }

  /// Helper method to safely parse List<String> from dynamic
  static List<String> _parseListSafely(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is List) {
      return value.map((e) => e.toString()).toList();
    } else if (value is String) {
      if (value.trim().isEmpty) {
        return [];
      }
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'posts': posts,
      'department': department,
      'isActive': isActive,
      'isAdmin': isAdmin,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (hireDate != null) 'hireDate': hireDate!.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (pinCode != null) 'pinCode': pinCode,
      if (accountLocked != null) 'accountLocked': accountLocked,
      if (accountLockedUntil != null) 'accountLockedUntil': accountLockedUntil!.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    List<String>? posts,
    String? department,
    bool? isActive,
    bool? isAdmin,
    String? photoUrl,
    DateTime? hireDate,
    DateTime? createdAt,
    String? pinCode,
    bool? accountLocked,
    DateTime? accountLockedUntil,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      posts: posts ?? this.posts,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
      isAdmin: isAdmin ?? this.isAdmin,
      photoUrl: photoUrl ?? this.photoUrl,
      hireDate: hireDate ?? this.hireDate,
      createdAt: createdAt ?? this.createdAt,
      pinCode: pinCode ?? this.pinCode,
      accountLocked: accountLocked ?? this.accountLocked,
      accountLockedUntil: accountLockedUntil ?? this.accountLockedUntil,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.role == role &&
        _listEquals(other.posts, posts) &&
        other.department == department &&
        other.isActive == isActive &&
        other.isAdmin == isAdmin &&
        other.photoUrl == photoUrl &&
        other.hireDate == hireDate &&
        other.createdAt == createdAt &&
        other.pinCode == pinCode &&
        other.accountLocked == accountLocked &&
        other.accountLockedUntil == accountLockedUntil;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        role.hashCode ^
        posts.hashCode ^
        department.hashCode ^
        isActive.hashCode ^
        isAdmin.hashCode ^
        photoUrl.hashCode ^
        hireDate.hashCode ^
        createdAt.hashCode ^
        pinCode.hashCode ^
        accountLocked.hashCode ^
        accountLockedUntil.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName, role: $role, posts: $posts, department: $department, isActive: $isActive, isAdmin: $isAdmin, photoUrl: $photoUrl, hireDate: $hireDate, createdAt: $createdAt, pinCode: $pinCode, accountLocked: $accountLocked, accountLockedUntil: $accountLockedUntil)';
  }

  /// Helper function to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
