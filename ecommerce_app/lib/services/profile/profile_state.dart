// lib/services/profile/profile_state.dart

import 'package:ecommerce_app/data/model/response/carts/company_branch_entity.dart';
import 'package:ecommerce_app/data/model/response/company_info_entity.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ProfileState {}

// ── General ───────────────────────────────────────────────────
class ProfileInitialState       extends ProfileState {}
class ProfileLoadingState       extends ProfileState {}
class ProfileLogoutSuccessState extends ProfileState {}
class GoToAboutUs               extends ProfileState {}
class GoToHelpAndSupport        extends ProfileState {}
class GoToCompanyBranches       extends ProfileState {}
class GoToEditProfile           extends ProfileState {}
class GoToChangePassword        extends ProfileState {}
class GoToPayment               extends ProfileState {}

// ── Profile loaded ────────────────────────────────────────────
class ProfileLoadedState extends ProfileState {
  final String                    name;
  final String                    email;
  final String?                   phone;
  final String?                   avatar;
  final String?                   country;
  final String?                   city;
  final String?                   street;
  final String?                   address;
  final String?                   avatarInitials;
  final CompanyInfoCompanyEntity? company;

  ProfileLoadedState({
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.country,
    this.city,
    this.street,
    this.address,
    this.avatarInitials,
    this.company,
  });
}

class ProfileLoadFailedState extends ProfileState {
  final String? message;
  ProfileLoadFailedState({this.message});
}

// ── Logout ────────────────────────────────────────────────────
class ProfileLogoutFailed extends ProfileState {
  final String? message;
  ProfileLogoutFailed({this.message});
}

// ── Branches ──────────────────────────────────────────────────
class ProfileBranchInitial extends ProfileState {}
class ProfileBranchLoading extends ProfileState {}

class ProfileBranchLoaded extends ProfileState {
  final CompanyBranchEntity companyBranchEntity;
  ProfileBranchLoaded(this.companyBranchEntity);
}

class ProfileBranchFailed extends ProfileState {
  final String? message;
  ProfileBranchFailed({this.message});
}

// ── Update profile ────────────────────────────────────────────
class ProfileUpdateLoading extends ProfileState {}
class ProfileUpdateSuccess extends ProfileState {}

class ProfileUpdateFailed extends ProfileState {
  final String? message;
  ProfileUpdateFailed({this.message});
}

// ── Change password ───────────────────────────────────────────
class ChangePasswordLoadingState       extends ProfileState {}
class ChangePasswordUpdateSuccessState extends ProfileState {}

class ChangePasswordUpdateFailedState extends ProfileState {
  final String? message;
  ChangePasswordUpdateFailedState({this.message});
}

// ── Password visibility toggles ───────────────────────────────
class ChangePasswordVisibilityState extends ProfileState {
  final bool showCurrent;
  final bool showNew;
  final bool showConfirm;

  ChangePasswordVisibilityState({
    required this.showCurrent,
    required this.showNew,
    required this.showConfirm,
  });
}

// ── Password strength ─────────────────────────────────────────
class ChangePasswordStrengthState extends ProfileState {
  final double strength;
  final String label;
  final Color  color;
  final String password;

  ChangePasswordStrengthState({
    required this.strength,
    required this.label,
    required this.color,
    required this.password,
  });
}

// ── Payment — load ────────────────────────────────────────────
class PaymentLoadingState extends ProfileState {}

class PaymentLoadedState extends ProfileState {
  final List<dynamic> payments; // List<PaymentDataEntity>
  final int?          selectedId;

  PaymentLoadedState({required this.payments, this.selectedId});
}

class PaymentLoadFailedState extends ProfileState {
  final String? message;
  PaymentLoadFailedState({this.message});
}

class PaymentSelectedState extends ProfileState {
  final int selectedId;
  PaymentSelectedState(this.selectedId);
}

// ── Payment — submit ✅ NEW ───────────────────────────────────
class PaymentSubmitLoadingState extends ProfileState {}

class PaymentSubmitSuccessState extends ProfileState {}

class PaymentSubmitFailedState extends ProfileState {
  final String? message;
  PaymentSubmitFailedState({this.message});
}