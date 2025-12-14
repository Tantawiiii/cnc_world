import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/contact_models.dart';
import '../data/repositories/contact_repository.dart';
import 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  final ContactRepository _repository;

  ContactCubit(this._repository) : super(ContactInitial());

  Future<void> submitContact(ContactRequest request) async {
    emit(ContactSubmitting());
    try {
      final response = await _repository.submitContact(request);
      emit(ContactSubmitted(response));
    } catch (e) {
      emit(ContactSubmitError(e.toString()));
    }
  }
}

