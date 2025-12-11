import 'package:equatable/equatable.dart';
import '../data/models/company_models.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompaniesLoading extends CompanyState {}

class CompaniesLoaded extends CompanyState {
  final List<Company> companies;

  const CompaniesLoaded(this.companies);

  @override
  List<Object?> get props => [companies];
}

class CompaniesError extends CompanyState {
  final String message;

  const CompaniesError(this.message);

  @override
  List<Object?> get props => [message];
}

class CompanyDetailLoading extends CompanyState {}

class CompanyDetailLoaded extends CompanyState {
  final Company company;

  const CompanyDetailLoaded(this.company);

  @override
  List<Object?> get props => [company];
}

class CompanyDetailError extends CompanyState {
  final String message;

  const CompanyDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
