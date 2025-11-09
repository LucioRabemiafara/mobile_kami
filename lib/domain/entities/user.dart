import 'package:equatable/equatable.dart';

/// User Entity
///
/// Pure business object representing a user
/// ⭐ MULTI-POSTES: posts is a List<String>
class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  /// ⭐ MULTI-POSTES: List of posts
  final List<String> posts;

  final String department;
  final bool isActive;
  final bool isAdmin;

  final String? photoUrl;
  final DateTime? hireDate;
  final DateTime? createdAt;

  const User({
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
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get initials
  String get initials {
    if (firstName.isEmpty && lastName.isEmpty) return '';
    if (firstName.isEmpty) return lastName[0].toUpperCase();
    if (lastName.isEmpty) return firstName[0].toUpperCase();
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        role,
        posts,
        department,
        isActive,
        isAdmin,
        photoUrl,
        hireDate,
        createdAt,
      ];
}
