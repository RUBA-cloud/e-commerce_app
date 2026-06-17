import 'dart:io';

import 'package:ecommerce_app/core/di/api_result.dart';
import 'package:ecommerce_app/core/di/configure_dependency.dart';
import 'package:ecommerce_app/data/model/request/profile/update_profile_request.dart';
import 'package:ecommerce_app/data/model/response/carts/company_branch_entity.dart';
import 'package:ecommerce_app/data/model/response/company_info_entity.dart';
import 'package:ecommerce_app/data/model/response/profile/profile_entity.dart';
import 'package:ecommerce_app/domain/usecases/company_info_use_cases.dart';
import 'package:ecommerce_app/domain/usecases/get_company_branches_use_cases.dart';
import 'package:ecommerce_app/domain/usecases/shared_pref_usecases/shared_prefs_clear_use_case.dart';
import 'package:ecommerce_app/domain/usecases/shared_pref_usecases/shared_prefs_get_string_use_case.dart';
import 'package:ecommerce_app/domain/usecases/shared_pref_usecases/shared_prefs_string_use_case.dart';
import 'package:ecommerce_app/domain/usecases/udpdate_profile_use_case.dart';
import 'package:ecommerce_app/services/profile/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constant/shared_prefence_keys.dart' show SharedPrefKeys;

// ─────────────────────────────────────────────────────────────
// CachedUser — in-memory snapshot read from SharedPrefs.
// EditProfileScreen reads this synchronously via currentUser.
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

  // ── Use-cases (matching the real DI registrations) ────────────
  final SharedPrefsClearUseCase    _clearUseCase =
  getIt<SharedPrefsClearUseCase>();
  final GetCompanyInfoUseCase      _getCompanyInfoUseCase =
  getIt<GetCompanyInfoUseCase>();
  final GetCompanyBranchesUseCases _getCompanyBranchesUseCases =
  getIt<GetCompanyBranchesUseCases>();
  final UpdateProfileUseCase       updateProfileUseCase =
  getIt<UpdateProfileUseCase>();
  final SharedPrefsStringUseCase   _write =
  getIt<SharedPrefsStringUseCase>();
  final SharedPrefsGetStringUseCase _read =
  getIt<SharedPrefsGetStringUseCase>();

  // ── In-memory cached user ─────────────────────────────────────
  CachedUser? _cachedUser;

  /// Synchronous — EditProfileScreen calls this in initState to
  /// pre-fill controllers without an extra async round-trip.
  CachedUser? get currentUser => _cachedUser;

  // ═══════════════════════════════════════════════════════════════
  // 1. LOAD COMPANY INFO  (original method — unchanged behaviour)
  // ═══════════════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════════
  // 2. LOAD USER PROFILE FROM SHARED PREFS
  //    Reads the fields that LoginCubit.fromLogin() persisted.
  //    Builds CachedUser so EditProfileScreen can pre-fill fields.
  // ═══════════════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════════
  // 3. UPDATE PROFILE
  //    Calls API → persists all updated fields → refreshes cache.
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String country,
    required String city,
    required String street,
    required String address,
    File? avatar,
  }) async {
    if (isClosed)  return;
    emit(ProfileUpdateLoading());
    try {
      final request = UpdateProfileRequest(
        name:    name,
        email:   email,
        phone:   phone,
        country: country,
        city:    city,
        street:  street,
      );

      final result = await updateProfileUseCase.execute(request);
      if (isClosed) return; // ← guard after every await

      switch (result) {
        case Success<ProfileEntity>():
          await Future.wait([
            _write.execute(SharedPrefKeys.userName,    name),
            _write.execute(SharedPrefKeys.userEmail,   email),
            _write.execute(SharedPrefKeys.userPhone,   phone),
            _write.execute(SharedPrefKeys.userCountry, country),
            _write.execute(SharedPrefKeys.userCity,    city),
            _write.execute(SharedPrefKeys.userStreet,  street),
            _write.execute(SharedPrefKeys.userAddress, address),
          ]);
          if (isClosed) return; // ← guard after every await

          _cachedUser = (_cachedUser ?? CachedUser(name: name, email: email))
              .copyWith(
            name:    name,
            email:   email,
            phone:   _nullIfEmpty(phone),
            country: _nullIfEmpty(country),
            city:    _nullIfEmpty(city),
            street:  _nullIfEmpty(street),
            address: _nullIfEmpty(address),
          );

          emit(ProfileUpdateSuccess());
          return;

        case Failure<ProfileEntity>():
          if (isClosed) return;
          emit(ProfileUpdateFailed(message: result.error));
          return;
      }
    } catch (e) {
      if (isClosed) return;
      emit(ProfileUpdateFailed(message: e.toString()));
    }
  }
  // ═══════════════════════════════════════════════════════════════
  // 4. LOAD BRANCHES  (original method — unchanged behaviour)
  // ═══════════════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════════
  // 5. LOGOUT  (original method — clears all prefs via clear use-case)
  // ═══════════════════════════════════════════════════════════════
  Future<void> logout() async {
    try {
      await _clearUseCase.execute();
      _cachedUser = null;
      emit(ProfileLogoutSuccessState());
    } catch (e) {
      emit(ProfileLogoutFailed(message: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Navigation emitters  (original — unchanged)
  // ═══════════════════════════════════════════════════════════════
  void goToAboutUs()         => emit(GoToAboutUs());
  void goToHelpAndSupport()  => emit(GoToHelpAndSupport());
  void goToCompanyBranches() => emit(GoToCompanyBranches());
  void goToEditProfile()     => emit(GoToEditProfile());

  // ═══════════════════════════════════════════════════════════════
  // Private helpers
  // ═══════════════════════════════════════════════════════════════

  /// "John Doe" → "JD" | "Alice" → "A" | "" / null → null
  String? _initials(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// Treats empty strings the same as null so optional SharedPref
  /// fields don't surface as empty strings in the UI.
  static String? _nullIfEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v;
}