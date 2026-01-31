import 'dart:io';

import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/repostery%20/profile_repoiistery.dart';
// ✅ عدلي هذا المسار لمسارك الحقيقي (بدون %20 وبدون مسافات)

import 'package:ecommerce_app/views/auth/profile/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final countryCtrl = TextEditingController();

  // ✅ لو عندك stateCtrl بالمشروع أضيفيه
  // final stateCtrl = TextEditingController();

  ProfileCubit() : super(ProfileState(status: ProfileStatus.idle));

  void loadExisting({required UserModel user}) {
    nameCtrl.text = user.name ?? '';
    emailCtrl.text = user.email ?? '';
    phoneCtrl.text = user.phone ?? '';
    addressCtrl.text = user.address ?? '';
    streetCtrl.text = user.streetName ?? '';

    // ✅ لا تصفّرهم — عبّيهم من اليوزر إن وجد
    countryCtrl.text = user.country?? '';
    cityCtrl.text = user.city ?? '';

    emit(state.copyWith(
      name: nameCtrl.text,
      email: emailCtrl.text,
      phone: phoneCtrl.text,
      address: addressCtrl.text,
      street: streetCtrl.text,
      country: countryCtrl.text,
      city: cityCtrl.text,
      imageUrl: user.imageProfile ?? '',
      status: ProfileStatus.idle,
      error: '',
    ));
  }

  void updateName(String v) => emit(state.copyWith(name: v, error: ''));
  void updateEmail(String v) => emit(state.copyWith(email: v, error: ''));
  void updatePhone(String v) => emit(state.copyWith(phone: v, error: ''));
  void updateAddress(String v) => emit(state.copyWith(address: v, error: ''));
  void updateStreet(String v) => emit(state.copyWith(street: v, error: ''));
  void updateCountry(String v) => emit(state.copyWith(country: v, error: ''));
  void updateCity(String v) => emit(state.copyWith(city: v, error: ''));

  void setImageFile(File file) {
    emit(state.copyWith(imageBytes: file, error: ''));
    debugPrint(state.imageBytes != null ? "true" : "false");
  }

  void removeImage() {
    emit(state.copyWith(imageBytes: null, imageUrl: '', error: ''));
  }

  // ✅ تستخدمها مع country_state_city_picker
  void setCountryStateCity({
    required String country,
    required String city,
  }) {
    countryCtrl.text = country;
    cityCtrl.text = city;

    emit(state.copyWith(
      country: country,
      city: city,
      error: '',
    ));
  }

  bool _validate() {
    final email = state.email.trim();
    final name = state.name.trim();

    if (name.isEmpty) {
      emit(state.copyWith(error: 'name_required'));
      return false;
    }

    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(email)) {
      emit(state.copyWith(error: 'invalid_email'));
      return false;
    }

    if (state.phone.trim().isNotEmpty &&
        !RegExp(r'^\+?[0-9\s\-\(\)]{7,20}$')
            .hasMatch(state.phone.trim())) {
      emit(state.copyWith(error: 'invalid_phone'));
      return false;
    }

    // ✅ تحقق بسيط للدولة/المدينة (اختياري)
    if (state.country.trim().isEmpty || state.city.trim().isEmpty) {
      emit(state.copyWith(error: 'please_select_country_city'));
      return false;
    }

    return true;
  }

  Future<void> saveProfile() async {
    // ✅ حدّث state من الكنترولرز قبل الحفظ
    emit(state.copyWith(
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      street: streetCtrl.text.trim(),
      country: countryCtrl.text.trim(),
      city: cityCtrl.text.trim(),
      imageBytes: state.imageBytes,
      error: '',
    ));

    if (!_validate()) return;

    emit(state.copyWith(status: ProfileStatus.loading, error: ''));

    try {
      final res = await ProfileRepository().updateUser(
        name: state.name,
        email: state.email,
        phone: state.phone,
        street: state.street,
        address: state.address,
        country: state.country, // ✅ أضفها لو API يدعم
        city: state.city,       // ✅ أضفها لو API يدعم
        avatarFile: state.imageBytes,
      );

      if (res) {
        emit(state.copyWith(status: ProfileStatus.success, error: ''));
        emit(state.copyWith(status: ProfileStatus.idle));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.failure,
          error: 'update_failed',
        ));
        emit(state.copyWith(status: ProfileStatus.idle));
      }
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.idle, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    streetCtrl.dispose();
    cityCtrl.dispose();
    countryCtrl.dispose();
    // stateCtrl.dispose();
    return super.close();
  }
}
