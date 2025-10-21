import 'dart:typed_data';

import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  Future<String?> uploadAvatar(Uint8List bytes) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return 'https://example.com/avatar_${DateTime.now().millisecondsSinceEpoch}.png';
  }

  Future<bool> updateUser() async {
    var user = UserModel.currentUser;
    var auth = await AuthServices.I.updateProfile(
      name: user!.name,
      phone: user.phone,
    );

    return auth.isOk;
  }

  Future<void> getUserData() async {
    SharedPreferences userData = await SharedPreferences.getInstance();
    UserModel.currentUser = UserModel(
        name: userData.getString('name'),
        email: userData.getString('phone'),
        id: userData.getInt('id'),
        address: '',
        streetName: 'streetName',
        phone: '07997879679',
        imageProfile: 'imageProfile',
        role: userData.getString('role'));
  }

  Future<void> saveProfileData({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String street,
    String? avatarUrl,
    required id,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final prefs = await SharedPreferences.getInstance();
    UserModel.currentUser = UserModel(
        name: name,
        email: email,
        id: id,
        address: address,
        streetName: "",
        phone: phone,
        imageProfile: "imageProfile",
        role: "role");
    prefs.setInt("id", id);
    prefs.setString("name", name);
    prefs.setString("email", email);
    prefs.setString("phone", phone);
    prefs.setString("address", address);
    prefs.setString("street", street);
    prefs.setString("profile_image", avatarUrl ?? "");

    //   await prefs;
  }
}
