import 'package:equatable/equatable.dart';

import '../data/models/engineer_models.dart';

abstract class EngineerState extends Equatable {
  const EngineerState();

  @override
  List<Object?> get props => [];
}

class EngineerInitial extends EngineerState {}

class EngineersLoading extends EngineerState {}

class EngineersLoadingMore extends EngineersLoaded {
  const EngineersLoadingMore(
    super.engineers, {
    super.meta,
    super.links,
    super.hasMore,
  });
}

class EngineersLoaded extends EngineerState {
  final List<Engineer> engineers;
  final EngineersMeta? meta;
  final EngineersLinks? links;
  final bool hasMore;

  const EngineersLoaded(
    this.engineers, {
    this.meta,
    this.links,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [engineers, meta, links, hasMore];
}

class EngineersError extends EngineerState {
  final String message;

  const EngineersError(this.message);

  @override
  List<Object?> get props => [message];
}

class EngineerDetailLoading extends EngineerState {}

class EngineerDetailLoaded extends EngineerState {
  final Engineer engineer;

  const EngineerDetailLoaded(this.engineer);

  @override
  List<Object?> get props => [engineer];
}

class EngineerDetailError extends EngineerState {
  final String message;

  const EngineerDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
