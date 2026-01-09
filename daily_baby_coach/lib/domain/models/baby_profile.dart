import 'package:hive/hive.dart';

part 'baby_profile.g.dart';

/// Baby's profile with age and developmental capabilities
@HiveType(typeId: 1)
class BabyProfile {
  @HiveField(0)
  final String id; // UUID

  @HiveField(1)
  final DateTime birthDate;

  @HiveField(2)
  final Map<String, bool> capabilities; // Developmental milestones

  @HiveField(3)
  final DateTime lastCapabilityUpdate;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  const BabyProfile({
    required this.id,
    required this.birthDate,
    required this.capabilities,
    required this.lastCapabilityUpdate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Age in days (computed)
  int get ageDays => DateTime.now().difference(birthDate).inDays;

  /// Age in months (computed, approximate)
  int get ageMonths => (ageDays / 30).floor();

  /// Age display string (e.g., "5 months 12 days")
  String get ageDisplay {
    final months = ageMonths;
    final days = ageDays - (months * 30);
    if (months == 0) {
      return '$days ${days == 1 ? 'day' : 'days'}';
    }
    return '$months ${months == 1 ? 'month' : 'months'} $days ${days == 1 ? 'day' : 'days'}';
  }

  /// Check if a capability is enabled
  bool hasCapability(String key) {
    return capabilities[key] ?? false;
  }

  /// Create a copy with updated fields
  BabyProfile copyWith({
    String? id,
    DateTime? birthDate,
    Map<String, bool>? capabilities,
    DateTime? lastCapabilityUpdate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BabyProfile(
      id: id ?? this.id,
      birthDate: birthDate ?? this.birthDate,
      capabilities: capabilities ?? this.capabilities,
      lastCapabilityUpdate: lastCapabilityUpdate ?? this.lastCapabilityUpdate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Standard capability keys
  static const String capRollsOver = 'rollsOver';
  static const String capSitsWithSupport = 'sitsWithSupport';
  static const String capSitsIndependently = 'sitsIndependently';
  static const String capCrawls = 'crawls';
  static const String capStandsWithSupport = 'standsWithSupport';
  static const String capBabbles = 'babbles';
  static const String capRespondsToName = 'respondsToName';
  static const String capSelfSoothes = 'selfSoothes';

  /// Get all standard capability keys
  static List<String> get allCapabilityKeys => [
        capRollsOver,
        capSitsWithSupport,
        capSitsIndependently,
        capCrawls,
        capStandsWithSupport,
        capBabbles,
        capRespondsToName,
        capSelfSoothes,
      ];

  @override
  String toString() {
    return 'BabyProfile(id: $id, age: $ageDisplay, capabilities: ${capabilities.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BabyProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
