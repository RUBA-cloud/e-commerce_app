// lib/services/profile/profile_cubit.dart

import 'dart:io';

import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/request/profile/change_password_request.dart';
import 'package:ecommerce_app/data/model/request/profile/update_profile_request.dart';
import 'package:ecommerce_app/data/model/request/update_payment_request.dart';
import 'package:ecommerce_app/data/model/response/carts/company_branch_entity.dart';
import 'package:ecommerce_app/data/model/response/company_info_entity.dart';
import 'package:ecommerce_app/data/model/response/profile/payment_entity.dart';
import 'package:ecommerce_app/data/model/response/profile/profile_entity.dart';
import 'package:ecommerce_app/data/model/response/user_payment_entity.dart';
import 'package:ecommerce_app/domain/usecases/auth_use_case/change_password_use_case.dart';
import 'package:ecommerce_app/domain/usecases/company_info_use_cases.dart';
import 'package:ecommerce_app/domain/usecases/get_company_branches_use_cases.dart';
import 'package:ecommerce_app/domain/usecases/payment/payment_use_case.dart';
import 'package:ecommerce_app/domain/usecases/payment/submit_payment_option_use_case.dart';
import 'package:ecommerce_app/domain/usecases/shared_pref_usecases/shared_prefs_clear_use_case.dart';
import 'package:ecommerce_app/domain/usecases/shared_pref_usecases/shared_prefs_get_string_use_case.dart';
import 'package:ecommerce_app/domain/usecases/shared_pref_usecases/shared_prefs_string_use_case.dart';
import 'package:ecommerce_app/domain/usecases/auth_use_case/udpdate_profile_use_case.dart';
import 'package:ecommerce_app/services/profile/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constant/shared_prefence_keys.dart' show SharedPrefKeys;

// ─────────────────────────────────────────────────────────────
// CachedUser
// ─────────────────────────────────────────────────────────────
class CachedUser {
  final String  name;
  final String  email;
  final String? phone;
  final String? avatar;
  final String? country;
  final String? city;
  final String? street;
  final String? address;

  const CachedUser({
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.country,
    this.city,
    this.street,
    this.address,
  });

  CachedUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? country,
    String? city,
    String? street,
    String? address,
  }) =>
      CachedUser(
        name:    name    ?? this.name,
        email:   email   ?? this.email,
        phone:   phone   ?? this.phone,
        avatar:  avatar  ?? this.avatar,
        country: country ?? this.country,
        city:    city    ?? this.city,
        street:  street  ?? this.street,
        address: address ?? this.address,
      );
}

// ─────────────────────────────────────────────────────────────
// ProfileCubit
// ─────────────────────────────────────────────────────────────
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitialState());

  static ProfileCubit get(BuildContext context) =>
      BlocProvider.of<ProfileCubit>(context);

  // ── Use-cases ──────────────────────────────────────────────
  final SharedPrefsClearUseCase     _clearUseCase               = getIt<SharedPrefsClearUseCase>();
  final GetCompanyInfoUseCase       _getCompanyInfoUseCase      = getIt<GetCompanyInfoUseCase>();
  final GetCompanyBranchesUseCases  _getCompanyBranchesUseCases = getIt<GetCompanyBranchesUseCases>();
  final UpdateProfileUseCase        updateProfileUseCase        = getIt<UpdateProfileUseCase>();
  final SharedPrefsStringUseCase    _write                      = getIt<SharedPrefsStringUseCase>();
  final SharedPrefsGetStringUseCase _read                       = getIt<SharedPrefsGetStringUseCase>();
  final ChangePasswordUseCase       _changePasswordUseCase      = getIt<ChangePasswordUseCase>();
  final PaymentUseCase              _paymentUseCase             = getIt<PaymentUseCase>();
  final SubmitPaymentOptionUseCase  _submitPaymentOptionUseCase = getIt<SubmitPaymentOptionUseCase>();

  // ── In-memory cached user ──────────────────────────────────
  CachedUser? _cachedUser;
  CachedUser? get currentUser => _cachedUser;

  // ── Change password internal UI state ─────────────────────
  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;

  // ── Payment selection ──────────────────────────────────────
  int? _selectedId;
  int? get selectedId => _selectedId;

  // ═══════════════════════════════════════════════════════════
  // 1. LOAD COMPANY INFO
  // ═══════════════════════════════════════════════════════════
  Future<void> loadCompanyInfo() async {
    emit(ProfileLoadingState());
    try {
      final result = await _getCompanyInfoUseCase.execute();
      switch (result) {
        case Success<CompanyInfoEntity>(:final data):
          final company = data.company;
          emit(ProfileLoadedState(
            name:           company.nameEn,
            email:          company.email,
            phone:          company.phone,
            avatarInitials: _initials(company.nameEn),
            company:        company,
          ));
        case Failure(:final error):
          emit(ProfileLoadFailedState(message: error));
      }
    } catch (e) {
      emit(ProfileLoadFailedState(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 2. LOAD USER PROFILE FROM SHARED PREFS
  // ═══════════════════════════════════════════════════════════
  Future<void> loadUserProfile() async {
    emit(ProfileLoadingState());
    try {
      final name    = await _read.execute(SharedPrefKeys.userName)    ?? '';
      final email   = await _read.execute(SharedPrefKeys.userEmail)   ?? '';
      final phone   = await _read.execute(SharedPrefKeys.userPhone);
      final avatar  = await _read.execute(SharedPrefKeys.userAvatar);
      final country = await _read.execute(SharedPrefKeys.userCountry);
      final city    = await _read.execute(SharedPrefKeys.userCity);
      final street  = await _read.execute(SharedPrefKeys.userStreet);
      final address = await _read.execute(SharedPrefKeys.userAddress);

      _cachedUser = CachedUser(
        name:    name,
        email:   email,
        phone:   _nullIfEmpty(phone),
        avatar:  _nullIfEmpty(avatar),
        country: _nullIfEmpty(country),
        city:    _nullIfEmpty(city),
        street:  _nullIfEmpty(street),
        address: _nullIfEmpty(address),
      );

      emit(ProfileLoadedState(
        name:           name,
        email:          email,
        phone:          _cachedUser!.phone,
        avatar:         _cachedUser!.avatar,
        avatarInitials: _initials(name),
      ));
    } catch (e) {
      emit(ProfileLoadFailedState(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 3. UPDATE PROFILE  (with optional avatar upload)
  // ═══════════════════════════════════════════════════════════
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String country,
    required String city,
    required String street,
    required String address,
    File?           avatar,   // ✅ nullable — only sent when user picked a new image
  }) async {
    if (isClosed) return;
    emit(ProfileUpdateLoading());
    try {
      final result = await updateProfileUseCase.execute(
        UpdateProfileRequest(
          name:    name,
          email:   email,
          phone:   phone,
          country: country,
          city:    city,
          street:  street,
          avatar:  avatar,   // ✅ fixed — was `avatar: File().` (invalid syntax)
        ),
      );
      if (isClosed) return;

      switch (result) {
        case Success<ProfileEntity>():
        // Persist updated fields to SharedPrefs
          await Future.wait([
            _write.execute(SharedPrefKeys.userName,    name),
            _write.execute(SharedPrefKeys.userEmail,   email),
            _write.execute(SharedPrefKeys.userPhone,   phone),
            _write.execute(SharedPrefKeys.userCountry, country),
            _write.execute(SharedPrefKeys.userCity,    city),
            _write.execute(SharedPrefKeys.userStreet,  street),
            _write.execute(SharedPrefKeys.userAddress, address),
            // ✅ persist avatar path if a new image was picked
            if (avatar != null)
              _write.execute(SharedPrefKeys.userAvatar, avatar.path),
          ]);
          if (isClosed) return;

          _cachedUser =
              (_cachedUser ?? CachedUser(name: name, email: email)).copyWith(
                name:    name,
                email:   email,
                phone:   _nullIfEmpty(phone),
                country: _nullIfEmpty(country),
                city:    _nullIfEmpty(city),
                street:  _nullIfEmpty(street),
                address: _nullIfEmpty(address),
                // ✅ update cached avatar path so UI reflects new image immediately
                avatar:  avatar != null ? avatar.path : _cachedUser?.avatar,
              );
          emit(ProfileUpdateSuccess());

        case Failure<ProfileEntity>():
          if (isClosed) return;
          emit(ProfileUpdateFailed(message: result.error));
      }
    } catch (e) {
      if (isClosed) return;
      emit(ProfileUpdateFailed(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 4. LOAD BRANCHES
  // ═══════════════════════════════════════════════════════════
  Future<void> loadBranches() async {
    emit(ProfileBranchLoading());
    try {
      final result = await _getCompanyBranchesUseCases.execute();
      switch (result) {
        case Success<CompanyBranchEntity>():
          emit(ProfileBranchLoaded(result.data));
        case Failure():
          emit(ProfileBranchFailed(message: result.error));
      }
    } catch (e) {
      emit(ProfileBranchFailed(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 5. LOGOUT
  // ═══════════════════════════════════════════════════════════
  Future<void> logout() async {
    try {
      await _clearUseCase.execute();
      _cachedUser = null;
      emit(ProfileLogoutSuccessState());
    } catch (e) {
      emit(ProfileLogoutFailed(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 6. LOAD PAYMENTS
  // ═══════════════════════════════════════════════════════════
  Future<void> loadPayments() async {
    emit(PaymentLoadingState());
    try {
      final result = await _paymentUseCase.execute();
      switch (result) {
        case Success<PaymentEntity>(:final data):
          final active = data.data.where((p) => p.isActive == 1).toList();
          _selectedId  = active.isNotEmpty ? active.first.id : null;
          emit(PaymentLoadedState(
            payments:   data.data,
            selectedId: _selectedId,
          ));
        case Failure(:final error):
          emit(PaymentLoadFailedState(message: error));
      }
    } catch (e) {
      emit(PaymentLoadFailedState(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 7. SELECT PAYMENT (radio button tap)
  // ═══════════════════════════════════════════════════════════
  void selectPayment(int id) {
    _selectedId = id;
    emit(PaymentSelectedState(id));
  }

  // ═══════════════════════════════════════════════════════════
  // 8. SUBMIT SELECTED PAYMENT
  // ═══════════════════════════════════════════════════════════
  Future<void> submitPayment() async {
    if (_selectedId == null) return;
    if (isClosed) return;

    emit(PaymentSubmitLoadingState());
    try {
      final result = await _submitPaymentOptionUseCase.execute(
        UpdatePaymentRequest(paymentId: _selectedId),
      );
      if (isClosed) return;
      switch (result) {
        case Success<UserPaymentEntity>():
          emit(PaymentSubmitSuccessState());
        case Failure(:final error):
          emit(PaymentSubmitFailedState(message: error));
      }
    } catch (e) {
      if (isClosed) return;
      emit(PaymentSubmitFailedState(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 9. CHANGE PASSWORD — submit
  // ═══════════════════════════════════════════════════════════
  Future<void> submitChangePassword(
      ChangePasswordRequest changePasswordRequest) async {
    if (isClosed) return;
    emit(ChangePasswordLoadingState());
    try {
      final result =
      await _changePasswordUseCase.execute(changePasswordRequest);
      if (isClosed) return;

      switch (result) {
        case Success<bool>():
          _showCurrent = false;
          _showNew     = false;
          _showConfirm = false;
          emit(ChangePasswordUpdateSuccessState());
        case Failure():
          emit(ChangePasswordUpdateFailedState(message: result.error));
      }
    } catch (e) {
      if (isClosed) return;
      emit(ChangePasswordUpdateFailedState(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 10. CHANGE PASSWORD — toggle visibility
  // ═══════════════════════════════════════════════════════════
  void toggleCurrentPasswordVisibility() {
    _showCurrent = !_showCurrent;
    _emitVisibility();
  }

  void toggleNewPasswordVisibility() {
    _showNew = !_showNew;
    _emitVisibility();
  }

  void toggleConfirmPasswordVisibility() {
    _showConfirm = !_showConfirm;
    _emitVisibility();
  }

  void _emitVisibility() {
    if (isClosed) return;
    emit(ChangePasswordVisibilityState(
      showCurrent: _showCurrent,
      showNew:     _showNew,
      showConfirm: _showConfirm,
    ));
  }

  // ═══════════════════════════════════════════════════════════
  // 11. CHANGE PASSWORD — evaluate strength
  // ═══════════════════════════════════════════════════════════
  void evaluatePasswordStrength(String password) {
    if (isClosed) return;
    if (password.isEmpty) return;

    double s = 0;
    if (password.length >= 8)                                    s += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password))                    s += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password))                    s += 0.25;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) s += 0.25;

    String label;
    Color  color;
    if (s <= 0.25) {
      label = 'weak';   color = const Color(0xFFE53935);
    } else if (s <= 0.50) {
      label = 'fair';   color = const Color(0xFFFB8C00);
    } else if (s <= 0.75) {
      label = 'good';   color = const Color(0xFFFFD600);
    } else {
      label = 'strong'; color = const Color(0xFF43A047);
    }

    emit(ChangePasswordStrengthState(
      strength: s,
      label:    label,
      color:    color,
      password: password,
    ));
  }

  // ═══════════════════════════════════════════════════════════
  // Navigation emitters
  // ═══════════════════════════════════════════════════════════
  void goToAboutUs()         => emit(GoToAboutUs());
  void goToHelpAndSupport()  => emit(GoToHelpAndSupport());
  void goToCompanyBranches() => emit(GoToCompanyBranches());
  void goToEditProfile()     => emit(GoToEditProfile());
  void goToChangePassword()  => emit(GoToChangePassword());
  void goToPaymentScreen()   => emit(GoToPayment());

  // ═══════════════════════════════════════════════════════════
  // Private helpers
  // ═══════════════════════════════════════════════════════════
  String? _initials(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  static String? _nullIfEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v;
}