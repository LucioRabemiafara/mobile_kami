/// Attendance Model (Pointage)
///
/// Represents a single day's attendance record
class AttendanceModel {
  final String id;
  final String userId;
  final DateTime date;

  /// Check-in time
  final DateTime? checkIn;

  /// Check-out time
  final DateTime? checkOut;

  /// Hours worked (calculated by backend)
  /// Only present when checkOut is not null
  final double hoursWorked;

  /// Whether user was late (checkIn after 9:00 AM)
  final bool isLate;

  final DateTime? createdAt;

  // Optional fields
  final String? userName;
  final String? userEmail;

  const AttendanceModel({
    required this.id,
    required this.userId,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.hoursWorked = 0.0,
    this.isLate = false,
    this.createdAt,
    this.userName,
    this.userEmail,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn'] as String) : null,
      checkOut: json['checkOut'] != null ? DateTime.parse(json['checkOut'] as String) : null,
      hoursWorked: (json['hoursWorked'] as num?)?.toDouble() ?? 0.0,
      isLate: json['isLate'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      if (checkIn != null) 'checkIn': checkIn!.toIso8601String(),
      if (checkOut != null) 'checkOut': checkOut!.toIso8601String(),
      'hoursWorked': hoursWorked,
      'isLate': isLate,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (userName != null) 'userName': userName,
      if (userEmail != null) 'userEmail': userEmail,
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    DateTime? checkIn,
    DateTime? checkOut,
    double? hoursWorked,
    bool? isLate,
    DateTime? createdAt,
    String? userName,
    String? userEmail,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      isLate: isLate ?? this.isLate,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttendanceModel &&
        other.id == id &&
        other.userId == userId &&
        other.date == date &&
        other.checkIn == checkIn &&
        other.checkOut == checkOut &&
        other.hoursWorked == hoursWorked &&
        other.isLate == isLate &&
        other.createdAt == createdAt &&
        other.userName == userName &&
        other.userEmail == userEmail;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        date.hashCode ^
        checkIn.hashCode ^
        checkOut.hashCode ^
        hoursWorked.hashCode ^
        isLate.hashCode ^
        createdAt.hashCode ^
        userName.hashCode ^
        userEmail.hashCode;
  }

  @override
  String toString() {
    return 'AttendanceModel(id: $id, userId: $userId, date: $date, checkIn: $checkIn, checkOut: $checkOut, hoursWorked: $hoursWorked, isLate: $isLate, createdAt: $createdAt, userName: $userName, userEmail: $userEmail)';
  }
}
