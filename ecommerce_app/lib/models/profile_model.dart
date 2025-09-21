import 'dart:typed_data';

class ProfileRepository {
  Future<String?> uploadAvatar(Uint8List bytes) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return 'https://example.com/avatar_${DateTime.now().millisecondsSinceEpoch}.png';
  }

  Future<void> saveProfileData({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String street,
    String? avatarUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
  }
}
