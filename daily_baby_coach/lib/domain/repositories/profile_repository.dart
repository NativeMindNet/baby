import '../models/baby_profile.dart';

/// Repository interface for baby profile data
abstract class ProfileRepository {
  /// Get the current baby profile
  Future<BabyProfile?> getProfile();

  /// Save or update the baby profile
  Future<void> saveProfile(BabyProfile profile);

  /// Update only capabilities
  Future<void> updateCapabilities(Map<String, bool> capabilities);

  /// Check if profile exists
  Future<bool> hasProfile();

  /// Delete profile (for testing or reset)
  Future<void> deleteProfile();
}
