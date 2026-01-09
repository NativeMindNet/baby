import 'package:hive/hive.dart';
import '../../domain/models/baby_profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Implementation of ProfileRepository using Hive
class ProfileRepositoryImpl implements ProfileRepository {
  final Box _profileBox = Hive.box('babyProfile');
  static const String _currentProfileKey = 'current';

  @override
  Future<BabyProfile?> getProfile() async {
    return _profileBox.get(_currentProfileKey) as BabyProfile?;
  }

  @override
  Future<void> saveProfile(BabyProfile profile) async {
    await _profileBox.put(_currentProfileKey, profile);
  }

  @override
  Future<void> updateCapabilities(Map<String, bool> capabilities) async {
    final profile = await getProfile();
    if (profile == null) return;

    final updated = profile.copyWith(
      capabilities: capabilities,
      lastCapabilityUpdate: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveProfile(updated);
  }

  @override
  Future<bool> hasProfile() async {
    return _profileBox.containsKey(_currentProfileKey);
  }

  @override
  Future<void> deleteProfile() async {
    await _profileBox.delete(_currentProfileKey);
  }
}
