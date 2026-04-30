import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const List<_PolicySection> _sections = [
    _PolicySection(
      title: AppTexts.termsSection1Title,
      body: AppTexts.termsSection1Body,
    ),
    _PolicySection(
      title: AppTexts.termsSection2Title,
      bullets: [
        AppTexts.termsSection2Bullet1,
        AppTexts.termsSection2Bullet2,
        AppTexts.termsSection2Bullet3,
      ],
    ),
    _PolicySection(
      title: AppTexts.termsSection3Title,
      bullets: [
        AppTexts.termsSection3Bullet1,
        AppTexts.termsSection3Bullet2,
        AppTexts.termsSection3Bullet3,
      ],
    ),
    _PolicySection(
      title: AppTexts.termsSection4Title,
      bullets: [
        AppTexts.termsSection4Bullet1,
        AppTexts.termsSection4Bullet2,
        AppTexts.termsSection4Bullet3,
      ],
    ),
    _PolicySection(
      title: AppTexts.termsSection5Title,
      body: AppTexts.termsSection5Body,
      bullets: [
        AppTexts.termsSection5Bullet1,
        AppTexts.termsSection5Bullet2,
      ],
    ),
    _PolicySection(
      title: AppTexts.termsSection6Title,
      body: AppTexts.termsSection6Body,
    ),
    _PolicySection(
      title: AppTexts.termsSection7Title,
      body: AppTexts.termsSection7Body,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _PolicyScaffold(
      title: AppTexts.termsConditions,
      sections: _sections,
    );
  }
}

class _PolicyScaffold extends StatelessWidget {
  const _PolicyScaffold({
    required this.title,
    required this.sections,
  });

  final String title;
  final List<_PolicySection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (section.body != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      section.body!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (section.bullets.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    ...section.bullets.map(
                      (bullet) => Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Text(
                          '• $bullet',
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PolicySection {
  const _PolicySection({
    required this.title,
    this.body,
    this.bullets = const [],
  });

  final String title;
  final String? body;
  final List<String> bullets;
}
