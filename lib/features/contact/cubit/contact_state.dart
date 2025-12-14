import 'package:equatable/equatable.dart';
import '../data/models/contact_models.dart';

abstract class ContactState extends Equatable {
  const ContactState();

  @override
  List<Object?> get props => [];
}

class ContactInitial extends ContactState {}

class ContactSubmitting extends ContactState {}

class ContactSubmitted extends ContactState {
  final ContactResponse response;

  const ContactSubmitted(this.response);

  @override
  List<Object?> get props => [response];
}

class ContactSubmitError extends ContactState {
  final String message;

  const ContactSubmitError(this.message);

  @override
  List<Object?> get props => [message];
}

