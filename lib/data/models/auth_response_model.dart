import 'user_model.dart';

/// Auth Response Model
///
/// Response from POST /auth/login
class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }

  AuthResponseModel copyWith({
    String? accessToken,
    String? refreshToken,
    UserModel? user,
  }) {
    return AuthResponseModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthResponseModel &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.user == user;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^ refreshToken.hashCode ^ user.hashCode;
  }

  @override
  String toString() {
    return 'AuthResponseModel(accessToken: $accessToken, refreshToken: $refreshToken, user: $user)';
  }
}
