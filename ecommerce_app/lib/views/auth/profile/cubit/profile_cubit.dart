import 'dart:typed_data';

import 'package:ecommerce_app/models/user_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState.initial());

  late UserModel userModel;
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final streetCtrl = TextEditingController();

  get updateStreet => null;
  // Call on screen open if you have existing user data
  void loadExisting({required UserModel user}) {
    emit(
      state.copyWith(
        name: user.name,
        email: user.email,
        phone: user.phone ?? '',

        imageUrl: user.imageProfile,
        imageBytes: null,
        status: ProfileStatus.idle,
        error: '',
      ),
    );
  }

  void updateName(String v) => emit(state.copyWith(name: v));
  void updateEmail(String v) => emit(state.copyWith(email: v));
  void updatePhone(String v) => emit(state.copyWith(phone: v));
  void updateAddress(String v) => emit(state.copyWith());
  void updateCity(String v) => emit(state.copyWith(street: v));
  void setUserName(UserModel user) {
    userModel = user;
  }

  void setImageBytes(Uint8List? bytes) {
    // When choosing new image, clear old url preview
    emit(
      state.copyWith(
        imageBytes: bytes,
        imageUrl: bytes != null ? null : state.imageUrl,
      ),
    );
  }

  void removeImage() => emit(state.copyWith(imageBytes: null, imageUrl: null));

  Future<void> saveProfile(Future<void> Function(ProfileState s) onSave) async {
    // Simple validation
    if (state.name.trim().isEmpty) {
      emit(state.copyWith(error: 'Name is required'));
      return;
    }
    if (state.email.trim().isEmpty || !state.email.contains('@')) {
      emit(state.copyWith(error: 'Valid email is required'));
      return;
    }

    emit(state.copyWith(status: ProfileStatus.loading, error: ''));
    try {
      await onSave(state);
      emit(state.copyWith(status: ProfileStatus.success));
      // keep data as-is after success
      emit(state.copyWith(status: ProfileStatus.idle));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
      emit(state.copyWith(status: ProfileStatus.idle));
    }
  }
}
