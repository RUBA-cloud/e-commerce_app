import 'dart:io';


import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/auth_services.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  ProfileRepository({AuthServices? authServices})
      : _authServices = authServices ?? AuthServices.I;

  final AuthServices _authServices;

  // SharedPreferences keys
  static const String _kId = 'id';
  static const String _kName = 'name';
  static const String _kEmail = 'email';
  static const String _kPhone = 'phone';
  static const String _kAddress = 'address';
  static const String _kStreet = 'street';
  static const String _kProfileImage = 'profile_image';
  static const String _kRole = 'role';
  static const String _kAccessToken = 'access_token';
  static const String _kLanguage = 'language';
  static const String _kTheme = 'theme';
    static const String _kCountry = 'country';
    static const String _kCity = 'city';

  static const String _kNotificationEnable = 'notificationEnable';

  static const String _kBuildingNumber = 'building_number';
// لو احتجتيه لاحقاً
  static const String _kLat = 'lat';
  static const String _kLong = 'long';

  /// Optional: mock upload to remote storage (you can replace this with real API)
  Future<String?> uploadAvatar(File bytes) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return 'https://example.com/avatar_${DateTime.now().millisecondsSinceEpoch}.png';
  }

  /// Update user profile on the backend (name/phone/address/street/avatar)
  Future<bool> updateUser({
    File? avatarFile,
    String?name ,
    String?email,
     String?street,
    String?address,
    String?country,
    String?city,

    String?phone
  }) async {

    if (!await checkConnectivity()) {
      return false;
    }

    final result = await _authServices.updateProfile(
      name: name,
      phone: phone,
      street: street,
      address: address,
      avatarFile: avatarFile,
      city:city,
      country:country
    );
    if(result.isOk && result.data != null){
      debugPrint('Profile updated successfully on server.');
      //UserModel.currentUser!.imageProfile = result.data!['avatar_path']??'';
    } else {
      debugPrint('Failed to update profile: ${result.error}');
    }


    return result.isOk;
  }

  /// Save / update address locally
  Future<bool> saveAddress({
    required String address,
    required String buildingNumber,
    required String lat,
    required String long,
    required String street,
  }) async {
    final user = UserModel.currentUser;
    if (user == null) return false;

    // حدّث نسخة الميموري
    user.address = address;
    user.streetName = street;

    // تأكد إن UserModel يحتوي هذي الحقول
    user.buildingNumber = buildingNumber;
    user.lat = lat;
    user.long = long;

    // خزّن في SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAddress, address);
    await prefs.setString(_kStreet, street);
    await prefs.setString(_kBuildingNumber, buildingNumber);
    await prefs.setString(_kLat, lat);
    await prefs.setString(_kLong, long);

    return true;
  }

  /// Load user from SharedPreferences into [UserModel.currentUser]
  Future<bool> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final int? id = prefs.getInt(_kId);
    if (id == null) {
      return false;
    }

    UserModel.currentUser = UserModel(
      id: id,
      name: prefs.getString(_kName),
      email: prefs.getString(_kEmail),
      phone: prefs.getString(_kPhone),
      address: prefs.getString(_kAddress),
      streetName: prefs.getString(_kStreet),
      imageProfile: prefs.getString(_kProfileImage),
      role: prefs.getString(_kRole),
      accessToken: prefs.getString(_kAccessToken),
      language: prefs.getString(_kLanguage),
      themee: prefs.getString(_kTheme),
      notificationEnabled: prefs.getBool(_kNotificationEnable) ?? false, 
      country:prefs.getString(_kCountry),
       city: prefs.getString(_kCity)??'',
    );

    // لو حابة تتأكدي إن العنوان التفصيلي محدث
    await getAddress();

    return UserModel.currentUser != null;
  }

  /// ✅ getAddress: يرجّع العنوان من SharedPreferences ويحدّث UserModel.currentUser
  Future<void> getAddress() async {
    final prefs = await SharedPreferences.getInstance();

    final address = prefs.getString(_kAddress);
    final street = prefs.getString(_kStreet);
    final buildingNumber = prefs.getString(_kBuildingNumber);
    final lat = prefs.getString(_kLat);
    final long = prefs.getString(_kLong);

    final user = UserModel.currentUser;
    if (user != null) {
      user.address = address;
      user.streetName = street;
      user.buildingNumber = buildingNumber;
      user.lat = lat;
      user.long = long;
    }

    
  }

  /// Save profile data to memory + SharedPreferences
  Future<void> saveProfileData({
    required int id,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String street,
    required String accessToken,
    required String? country,
  required String city,

    String? avatarUrl,
    File? image,
    String? language,
    bool? notificationEnable,
    String? theme,
    String role = 'customer',
  }) async {
    // Update in-memory user
    UserModel.currentUser = UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      streetName: street,
      imageProfile: avatarUrl ?? '',
      role: role,
      accessToken: accessToken,
      language: language ?? 'en',
      themee: theme ?? 'light',
      notificationEnabled: notificationEnable ?? false,
       country: country,
       city:city,
      
    );

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kId, id);
    await prefs.setString(_kName, name);
    await prefs.setString(_kEmail, email);
    await prefs.setString(_kPhone, phone);
    await prefs.setString(_kAddress, address);
    await prefs.setString(_kStreet, street);
    await prefs.setString(_kProfileImage, avatarUrl ?? '');
    await prefs.setString(_kRole, role);
    await prefs.setString(_kAccessToken, accessToken);
    await prefs.setString(_kLanguage, language ?? 'en');
    await prefs.setString(_kTheme, theme ?? 'light');
    await prefs.setBool(_kNotificationEnable, notificationEnable ?? false);
  }

  void saveAccessToken(String accessToken) {
    final user = UserModel.currentUser;
    if (user != null) {
      user.accessToken = accessToken;
    }

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_kAccessToken, accessToken);
    });
  }

  Future<void> logout() async {
    UserModel.currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed('/login');
  }
}
