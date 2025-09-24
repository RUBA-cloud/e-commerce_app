import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("name", name);
    prefs.setString("email", email);
    prefs.setString("phone", phone);
    prefs.setString("address", address);
    prefs.setString("street", street);

    prefs.setString("profile_image", avatarUrl ?? "");

    //   await prefs;
  }
}
