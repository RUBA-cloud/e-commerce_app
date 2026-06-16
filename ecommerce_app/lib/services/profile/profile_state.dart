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