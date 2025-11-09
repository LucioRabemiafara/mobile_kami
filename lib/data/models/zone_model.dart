/// Zone Model
///
/// ⭐ MULTI-POSTES: allowedPosts is a List<String>
/// A zone can allow MULTIPLE posts (e.g., ['DEVELOPER', 'DEVOPS'])
class ZoneModel {
  final String id;
  final String name;
  final String building;
  final int floor;

  /// Security level: LOW, MEDIUM, HIGH
  final String securityLevel;

  final String qrCode;
  final bool isActive;

  /// If true, zone is open to all users (regardless of posts)
  final bool isOpenToAll;

  /// ⭐ MULTI-POSTES: List of allowed posts (NOT a single String)
  /// Example: ['DEVELOPER', 'DEVOPS']
  /// Empty list means no specific posts allowed (only if isOpenToAll = true)
  final List<String> allowedPosts;

  final DateTime? createdAt;

  // Optional fields
  final String? description;
  final int? capacity;

  const ZoneModel({
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
    this.capacity,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    try {
      return ZoneModel(
        id: json['id'].toString(), // Convert to String (handles both int and String from API)
        name: json['name'] as String,
        building: json['building'] as String,
        floor: _parseIntSafely(json['floor'], defaultValue: 0), // Safe int parsing with default
        securityLevel: json['securityLevel'] as String,
        qrCode: json['qrCode'] as String,
        isActive: _parseBoolSafely(json['isActive'], defaultValue: true), // Safe bool parsing with default
        isOpenToAll: _parseBoolSafely(json['isOpenToAll'], defaultValue: false), // Safe bool parsing with default
        allowedPosts: _parseListSafely(json['allowedPosts']), // Safe list parsing
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        description: json['description'] as String?,
        capacity: _parseIntNullable(json['capacity']), // Nullable int parsing
      );
    } catch (e) {
      print('❌ ZoneModel.fromJson error: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  /// Helper method to safely parse int from dynamic (handles both int and String)
  static int _parseIntSafely(dynamic value, {int defaultValue = 0}) {
    if (value == null) {
      return defaultValue;
    }

    if (value is int) {
      return value;
    } else if (value is String) {
      // Handle empty strings or whitespace
      if (value.trim().isEmpty) {
        return defaultValue;
      }

      try {
        return int.parse(value);
      } catch (e) {
        print('⚠️ Failed to parse "$value" as int, using default: $defaultValue');
        return defaultValue;
      }
    } else if (value is double) {
      return value.toInt();
    } else {
      print('⚠️ Cannot parse $value (${value.runtimeType}) to int, using default: $defaultValue');
      return defaultValue;
    }
  }

  /// Helper method to safely parse bool from dynamic (handles bool, int, String)
  static bool _parseBoolSafely(dynamic value, {bool defaultValue = false}) {
    if (value == null) {
      return defaultValue;
    }

    if (value is bool) {
      return value;
    } else if (value is int) {
      return value != 0; // 0 = false, non-zero = true
    } else if (value is String) {
      if (value.trim().isEmpty) {
        return defaultValue;
      }
      final lowerValue = value.toLowerCase().trim();
      return lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes';
    } else {
      print('⚠️ Cannot parse $value (${value.runtimeType}) to bool, using default: $defaultValue');
      return defaultValue;
    }
  }

  /// Helper method to safely parse nullable int from dynamic
  static int? _parseIntNullable(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    } else if (value is String) {
      if (value.trim().isEmpty) {
        return null;
      }
      try {
        return int.parse(value);
      } catch (e) {
        print('⚠️ Failed to parse "$value" as int, returning null');
        return null;
      }
    } else if (value is double) {
      return value.toInt();
    } else {
      print('⚠️ Cannot parse $value (${value.runtimeType}) to int, returning null');
      return null;
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
      // Handle comma-separated string
      if (value.trim().isEmpty) {
        return [];
      }
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else {
      print('⚠️ Cannot parse $value (${value.runtimeType}) to List<String>, returning empty list');
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'building': building,
      'floor': floor,
      'securityLevel': securityLevel,
      'qrCode': qrCode,
      'isActive': isActive,
      'isOpenToAll': isOpenToAll,
      'allowedPosts': allowedPosts,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (description != null) 'description': description,
      if (capacity != null) 'capacity': capacity,
    };
  }

  ZoneModel copyWith({
    String? id,
    String? name,
    String? building,
    int? floor,
    String? securityLevel,
    String? qrCode,
    bool? isActive,
    bool? isOpenToAll,
    List<String>? allowedPosts,
    DateTime? createdAt,
    String? description,
    int? capacity,
  }) {
    return ZoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      securityLevel: securityLevel ?? this.securityLevel,
      qrCode: qrCode ?? this.qrCode,
      isActive: isActive ?? this.isActive,
      isOpenToAll: isOpenToAll ?? this.isOpenToAll,
      allowedPosts: allowedPosts ?? this.allowedPosts,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ZoneModel &&
        other.id == id &&
        other.name == name &&
        other.building == building &&
        other.floor == floor &&
        other.securityLevel == securityLevel &&
        other.qrCode == qrCode &&
        other.isActive == isActive &&
        other.isOpenToAll == isOpenToAll &&
        _listEquals(other.allowedPosts, allowedPosts) &&
        other.createdAt == createdAt &&
        other.description == description &&
        other.capacity == capacity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        building.hashCode ^
        floor.hashCode ^
        securityLevel.hashCode ^
        qrCode.hashCode ^
        isActive.hashCode ^
        isOpenToAll.hashCode ^
        allowedPosts.hashCode ^
        createdAt.hashCode ^
        description.hashCode ^
        capacity.hashCode;
  }

  @override
  String toString() {
    return 'ZoneModel(id: $id, name: $name, building: $building, floor: $floor, securityLevel: $securityLevel, qrCode: $qrCode, isActive: $isActive, isOpenToAll: $isOpenToAll, allowedPosts: $allowedPosts, createdAt: $createdAt, description: $description, capacity: $capacity)';
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
