import 'package:equatable/equatable.dart';

import '../../data/model/response/company_info_entity.dart';

abstract class AppMainState extends Equatable {
  const AppMainState();
  @override
  List<Object?> get props => [];
}
class UserAlreadySigned extends AppMainState{}
class UserNotSignedIn extends AppMainState{}
class CompanyInfoInitial extends AppMainState {}
class CompanyInfoLoading extends AppMainState {}
class CompanyInfoUpdated extends AppMainState {
  final CompanyInfoEntity company;
  const CompanyInfoUpdated(this.company);
  @override
  List<Object?> get props => [company];
}
class CompanyInfoLoaded extends AppMainState {
  final CompanyInfoEntity company;
  const CompanyInfoLoaded(this.company);
  @override
  List<Object?> get props => [company];
}

class CompanyInfoError extends AppMainState {
  final String message;
  const CompanyInfoError(this.message);
  @override
  List<Object?> get props => [message];
}