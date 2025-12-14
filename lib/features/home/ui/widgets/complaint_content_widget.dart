import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/di/inject.dart' as di;
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../contact/cubit/contact_cubit.dart';
import '../../../contact/cubit/contact_state.dart';
import '../../../contact/data/models/contact_models.dart';

class ComplaintContentWidget extends StatefulWidget {
  const ComplaintContentWidget({super.key});

  @override
  State<ComplaintContentWidget> createState() => _ComplaintContentWidgetState();
}

class _ComplaintContentWidgetState extends State<ComplaintContentWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final StorageService _storageService = di.sl<StorageService>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userData = _storageService.getUserData();
    if (userData != null) {
      _nameController.text = userData['name'] ?? '';
      _phoneController.text = userData['phone'] ?? '';

      // Combine address, city, and state if available
      final addressParts = <String>[];
      if (userData['address'] != null &&
          userData['address'].toString().isNotEmpty) {
        addressParts.add(userData['address'].toString());
      }
      if (userData['city'] != null && userData['city'].toString().isNotEmpty) {
        addressParts.add(userData['city'].toString());
      }
      if (userData['state'] != null &&
          userData['state'].toString().isNotEmpty) {
        addressParts.add(userData['state'].toString());
      }
      _addressController.text = addressParts.join(', ');

      if (userData['email'] != null) {
        _emailController.text = userData['email'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitComplaint() {
    if (!_formKey.currentState!.validate()) return;

    final request = ContactRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      type: 'complaint',
    );

    context.read<ContactCubit>().submitContact(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactCubit, ContactState>(
      listener: (context, state) {
        if (state is ContactSubmitted) {
          final localizations = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations?.complaintSuccess ?? AppTexts.complaintSuccess,
              ),
              backgroundColor: AppColors.success,
            ),
          );
          _nameController.clear();
          _emailController.clear();
          _phoneController.clear();
          _addressController.clear();
          _subjectController.clear();
          _messageController.clear();
        } else if (state is ContactSubmitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  final localizations = AppLocalizations.of(context);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations?.complaint ?? AppTexts.complaint,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _buildNameField(context),
                      SizedBox(height: 20.h),
                      _buildEmailField(context),
                      SizedBox(height: 20.h),
                      _buildField(
                        context,
                        localizations?.phone ?? AppTexts.phone,
                        _phoneController,
                        Icons.phone_outlined,
                        localizations?.phoneRequired ?? AppTexts.phoneRequired,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 20.h),
                      _buildField(
                        context,
                        localizations?.address ?? AppTexts.address,
                        _addressController,
                        Icons.location_on_outlined,
                        localizations?.addressRequired ??
                            AppTexts.addressRequired,
                      ),
                      SizedBox(height: 20.h),
                      _buildSubjectField(context),
                      SizedBox(height: 20.h),
                      _buildMessageField(context),
                      SizedBox(height: 32.h),
                      BlocBuilder<ContactCubit, ContactState>(
                        builder: (context, state) {
                          final isSubmitting = state is ContactSubmitting;
                          return PrimaryButton(
                            title:
                                localizations?.submitComplaint ??
                                AppTexts.submitComplaint,
                            onPressed: isSubmitting ? null : _submitComplaint,
                            isLoading: isSubmitting,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
    String? errorText, {
    TextInputType? keyboardType,
    String? Function(String?)? customValidator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        AppTextField(
          controller: controller,
          hint: label,
          keyboardType: keyboardType,
          leadingIcon: icon,
          validator:
              customValidator ??
              (value) {
                if (value == null || value.trim().isEmpty) {
                  return errorText;
                }
                return null;
              },
        ),
      ],
    );
  }

  Widget _buildNameField(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.name ?? AppTexts.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        AppTextField(
          controller: _nameController,
          hint: localizations?.name ?? AppTexts.name,
          leadingIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return localizations?.nameRequired ?? AppTexts.nameRequired;
            }
            final trimmedValue = value.trim();
            // Name should only contain letters, spaces, and Arabic characters
            final nameRegex = RegExp(r'^[\p{L}\s]+$', unicode: true);
            if (!nameRegex.hasMatch(trimmedValue)) {
              return localizations?.nameInvalidFormat ??
                  AppTexts.nameInvalidFormat;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubjectField(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.subject ?? AppTexts.subject,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        AppTextField(
          controller: _subjectController,
          hint: localizations?.subject ?? AppTexts.subject,
          leadingIcon: Icons.subject_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return localizations?.subjectRequired ?? AppTexts.subjectRequired;
            }
            if (value.trim().length < 5) {
              return localizations?.subjectMinLength ??
                  AppTexts.subjectMinLength;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.email ?? AppTexts.email,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        AppTextField(
          controller: _emailController,
          hint: localizations?.email ?? AppTexts.email,
          keyboardType: TextInputType.emailAddress,
          leadingIcon: Icons.email_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return localizations?.emailRequired ?? AppTexts.emailRequired;
            }
            final trimmedValue = value.trim();
            // More strict email validation regex
            final emailRegex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            );
            if (!emailRegex.hasMatch(trimmedValue)) {
              return localizations?.invalidEmail ?? AppTexts.invalidEmail;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMessageField(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.message ?? AppTexts.message,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        AppTextField(
          controller: _messageController,
          hint: localizations?.messageHint ?? AppTexts.messageHint,
          maxLines: 5,
          leadingIcon: Icons.message_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return localizations?.messageRequired ?? AppTexts.messageRequired;
            }
            if (value.trim().length < 10) {
              return localizations?.messageMinLength ??
                  AppTexts.messageMinLength;
            }
            return null;
          },
        ),
      ],
    );
  }
}
