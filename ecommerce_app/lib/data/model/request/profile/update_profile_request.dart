import 'dart:io';

import 'package:dio/dio.dart';

class UpdateProfileRequest {
  final String? name;
  final String? email;
  final String? street;
  final String? address;
  final String? phone;
  final File? avatar;
  final String? country;
  final String? city;

  UpdateProfileRequest({
    this.name,
    this.email,
    this.street,
    this.address,
    this.phone,
    this.avatar,
    this.country,
    this.city,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (street != null) 'street': street,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (country != null) 'country': country,
      if (city != null) 'city': city,
      if (avatar != null)
        'avatar': await MultipartFile.fromFile(
          avatar!.path,
          filename: avatar!.path.split('/').last,
        ),
    });
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (street != null) 'street': street,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (country != null) 'country': country,
      if (city != null) 'city': city,
      // avatar is a File — not JSON serializable.
      // Use toFormData() instead when avatar is included.
    };
  }
}