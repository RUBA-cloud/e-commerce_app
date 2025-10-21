import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/repostery%20/profile_repoiistery.dart';
import 'package:ecommerce_app/views/auth/profile/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List;
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  // Text controllers live in the Cubit to keep Stateless widget clean.
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final streetCtrl = TextEditingController();

  // Load existing user into state + controllers
  void loadExisting({required UserModel user}) {
    final n = user.name ?? '';
    final e = user.email ?? '';
    final p = user.phone ?? '';
    final a = user.address ?? '';
    //final s = user.street ?? '';
    //final url = user.avatarUrl;

    nameCtrl.text = n;
    emailCtrl.text = e;
    phoneCtrl.text = p;
    addressCtrl.text = a;
    streetCtrl.text = '';

    emit(state.copyWith(
      name: n,
      email: e,
      phone: p,
      address: a,
      street: '',
      imageUrl: '',
      imageBytes: state.imageBytes, // keep if user already picked
      status: ProfileStatus.idle,
      error: '',
    ));
  }

  // Update “draft” as user types
  void updateName(String v) => emit(state.copyWith(name: v, error: ''));
  void updateEmail(String v) => emit(state.copyWith(email: v, error: ''));
  void updatePhone(String v) => emit(state.copyWith(phone: v, error: ''));
  void updateAddress(String v) => emit(state.copyWith(address: v, error: ''));
  void updateStreet(String v) => emit(state.copyWith(street: v, error: ''));

  void setImageBytes(Uint8List bytes) {
    emit(
        state.copyWith(imageBytes: bytes, imageUrl: state.imageUrl, error: ''));
  }

  void removeImage() {
    emit(state.copyWith(imageBytes: null, imageUrl: '', error: ''));
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
    // Optional phone quick check
    if (state.phone.trim().isNotEmpty &&
        !RegExp(r'^\+?[0-9\s\-\(\)]{7,20}$').hasMatch(state.phone.trim())) {
      emit(state.copyWith(error: 'invalid_phone'));
      return false;
    }
    return true;
  }

  /// Persists the profile via the provided callback.
  /// - [persist] receives the latest state and should perform storage (upload avatar, save fields).
  Future<void> saveProfile(
    Future<void> Function(ProfileState s) persist,
  ) async {
    if (!_validate()) return;

    emit(state.copyWith(status: ProfileStatus.loading, error: ''));

    try {
      await persist(state);
      ProfileRepository().saveProfileData(
          id: UserModel.currentUser,
          name: state.name,
          email: state.email,
          phone: state.phone,
          address: '',
          street: '');
      ProfileRepository().updateUser();
      emit(state.copyWith(status: ProfileStatus.idle, error: ''));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.idle,
        error: e.toString().isEmpty ? 'save_failed' : e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    streetCtrl.dispose();
    return super.close();
  }
}
