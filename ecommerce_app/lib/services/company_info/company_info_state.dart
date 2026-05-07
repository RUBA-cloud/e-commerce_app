import 'package:equatable/equatable.dart';

import '../../data/model/response/company_info_entity.dart';

abstract class CompanyInfoState extends Equatable {
  const CompanyInfoState();
  @override
  List<Object?> get props => [];
}

class CompanyInfoInitial extends CompanyInfoState {}

class CompanyInfoLoading extends CompanyInfoState {}
class CompanyInfoUpdated extends CompanyInfoState {
  final CompanyInfoEntity company;
  const CompanyInfoUpdated(this.company);
  @override
  List<Object?> get props => [company];
}
class CompanyInfoLoaded extends CompanyInfoState {
  final CompanyInfoEntity company;
  const CompanyInfoLoaded(this.company);
  @override
  List<Object?> get props => [company];
}

class CompanyInfoError extends CompanyInfoState {
  final String message;
  const CompanyInfoError(this.message);
  @override
  List<Object?> get props => [message];
}