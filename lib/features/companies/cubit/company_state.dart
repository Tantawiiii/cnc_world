import 'package:equatable/equatable.dart';
import '../data/models/company_models.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompaniesLoading extends CompanyState {}

class CompaniesLoadingMore extends CompaniesLoaded {
  const CompaniesLoadingMore(
    super.companies, {
    super.meta,
    super.links,
    super.hasMore,
  });
}

class CompaniesLoaded extends CompanyState {
  final List<Company> companies;
  final CompaniesMeta? meta;
  final CompaniesLinks? links;
  final bool hasMore;

  const CompaniesLoaded(
    this.companies, {
    this.meta,
    this.links,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [companies, meta, links, hasMore];
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
