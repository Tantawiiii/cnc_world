import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constant/app_texts.dart';
import 'core/di/inject.dart' as di;
import 'core/localization/app_localizations.dart';
import 'core/network/dio_client.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await di.init();

  final storageService = di.sl<StorageService>();
  final dioClient = di.sl<DioClient>();
  final token = storageService.getToken();

  if (token != null) {
    dioClient.setAuthToken(token);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar', 'SA');

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final storageService = di.sl<StorageService>();
    final savedLanguage = storageService.getLanguage();
    if (savedLanguage != null) {
      setState(() {
        _locale = Locale(savedLanguage, savedLanguage == 'ar' ? 'SA' : 'US');
      });
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    final storageService = di.sl<StorageService>();
    storageService.saveLanguage(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, child) {
        return MaterialApp(
          title: AppTexts.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: _locale,
          supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          onGenerateRoute: onGenerateAppRoute,
          initialRoute: AppRoutes.splash,
        );
      },
    );
  }
}
