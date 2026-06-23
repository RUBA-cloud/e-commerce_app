// lib/services/company_info/app_main_state.dart

import 'package:equatable/equatable.dart';
import '../../data/model/response/company_info_entity.dart';

abstract class AppMainState extends Equatable {
  const AppMainState();
  @override
  List<Object?> get props => [];
}

// ── Auth ──────────────────────────────────────────────────────
class UserAlreadySigned extends AppMainState {}
class UserNotSignedIn   extends AppMainState {}

// ── Company info ──────────────────────────────────────────────
class CompanyInfoInitial extends AppMainState {}
class CompanyInfoLoading extends AppMainState {}

class CompanyInfoLoaded extends AppMainState {
  final CompanyInfoEntity company;
  const CompanyInfoLoaded(this.company);
  @override
  List<Object?> get props => [company];
}

class CompanyInfoUpdated extends AppMainState {
  final CompanyInfoEntity company;
  const CompanyInfoUpdated(this.company);
  @override
  List<Object?> get props => [company];
}

class CompanyInfoError extends AppMainState {
  final String message;
  const CompanyInfoError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Theme ✅ NEW ──────────────────────────────────────────────
// Emitted by toggleTheme() and _loadTheme() so any BlocBuilder
// listening to AppMainCubit can react to dark/light changes.
class ThemeChangedState extends AppMainState {
  final bool isDark;
  const ThemeChangedState({required this.isDark});
  @override
  List<Object?> get props => [isDark];
}