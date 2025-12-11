import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constant/app_texts.dart';
import '../../features/auth/login/ui/login_screen.dart';
import '../../features/auth/register/ui/register_screen.dart';
import '../../features/auth/register/ui/role_selection_screen.dart';
import '../../features/auth/register/data/models/register_models.dart';
import '../../features/home/home_screen.dart';
import '../../features/maintenance/ui/maintenance_screen.dart';
import '../../features/maintenance/cubit/maintenance_cubit.dart';
import '../../features/maintenance/data/repositories/maintenance_repository.dart';
import '../../features/used_machines/ui/used_machines_list_screen.dart';
import '../../features/used_machines/ui/add_used_machine_screen.dart';
import '../../features/used_machines/ui/used_machine_detail_screen.dart';
import '../../features/used_machines/cubit/used_machine_cubit.dart';
import '../../features/used_machines/data/repositories/used_machine_repository.dart';
import '../../features/merchants/ui/merchants_list_screen.dart';
import '../../features/merchants/ui/merchant_detail_screen.dart';
import '../../features/merchants/cubit/merchant_cubit.dart';
import '../../features/merchants/data/repositories/merchant_repository.dart';
import '../../features/companies/ui/companies_list_screen.dart';
import '../../features/companies/ui/company_detail_screen.dart';
import '../../features/companies/cubit/company_cubit.dart';
import '../../features/companies/data/repositories/company_repository.dart';
import '../../features/designs/ui/designs_list_screen.dart';
import '../../features/designs/ui/add_design_screen.dart';
import '../../features/designs/cubit/design_cubit.dart';
import '../../features/designs/data/repositories/design_repository.dart';
import '../../features/sellers/ui/sellers_list_screen.dart';
import '../../features/sellers/ui/seller_detail_screen.dart';
import '../../features/sellers/cubit/seller_cubit.dart';
import '../../features/sellers/data/repositories/seller_repository.dart';
import '../../features/profile/ui/profile_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'app_routes.dart';

Route<dynamic> onGenerateAppRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case AppRoutes.onboarding:
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case AppRoutes.signup:
      final role = settings.arguments as UserRole?;
      if (role != null) {
        return MaterialPageRoute(builder: (_) => RegisterScreen(role: role));
      }
      return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    case AppRoutes.maintenance:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => MaintenanceCubit(MaintenanceRepository()),
          child: const MaintenanceScreen(),
        ),
      );
    case AppRoutes.usedMachines:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) {
            final cubit = UsedMachineCubit(UsedMachineRepository());
            cubit.loadUsedMachines();
            return cubit;
          },
          child: const UsedMachinesListScreen(),
        ),
      );
    case AppRoutes.addUsedMachine:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => UsedMachineCubit(UsedMachineRepository()),
          child: const AddUsedMachineScreen(),
        ),
      );
    case AppRoutes.usedMachineDetail:
      final machineId = settings.arguments as int?;
      if (machineId != null) {
        return MaterialPageRoute(
          builder: (_) => UsedMachineDetailScreen(machineId: machineId),
        );
      }
      return MaterialPageRoute(
        builder: (_) =>
            Scaffold(body: Center(child: Text(AppTexts.routeNotFound))),
      );
    case AppRoutes.merchants:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) {
            final cubit = MerchantCubit(MerchantRepository());
            cubit.loadMerchants();
            return cubit;
          },
          child: const MerchantsListScreen(),
        ),
      );
    case AppRoutes.merchantDetail:
      final merchantId = settings.arguments as int?;
      if (merchantId != null) {
        return MaterialPageRoute(
          builder: (_) => MerchantDetailScreen(merchantId: merchantId),
        );
      }
      return MaterialPageRoute(
        builder: (_) =>
            Scaffold(body: Center(child: Text(AppTexts.routeNotFound))),
      );
    case AppRoutes.companies:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) {
            final cubit = CompanyCubit(CompanyRepository());
            cubit.loadCompanies();
            return cubit;
          },
          child: const CompaniesListScreen(),
        ),
      );
    case AppRoutes.companyDetail:
      final companyId = settings.arguments as int?;
      if (companyId != null) {
        return MaterialPageRoute(
          builder: (_) => CompanyDetailScreen(companyId: companyId),
        );
      }
      return MaterialPageRoute(
        builder: (_) =>
            Scaffold(body: Center(child: Text(AppTexts.routeNotFound))),
      );
    case AppRoutes.designs:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) {
            final cubit = DesignCubit(DesignRepository());
            cubit.loadDesigns();
            return cubit;
          },
          child: const DesignsListScreen(),
        ),
      );
    case AppRoutes.addDesign:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => DesignCubit(DesignRepository()),
          child: const AddDesignScreen(),
        ),
      );
    case AppRoutes.sellers:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) {
            final cubit = SellerCubit(SellerRepository());
            cubit.loadSellers();
            return cubit;
          },
          child: const SellersListScreen(),
        ),
      );
    case AppRoutes.sellerDetail:
      final sellerId = settings.arguments as int?;
      if (sellerId != null) {
        return MaterialPageRoute(
          builder: (_) => SellerDetailScreen(sellerId: sellerId),
        );
      }
      return MaterialPageRoute(
        builder: (_) =>
            Scaffold(body: Center(child: Text(AppTexts.routeNotFound))),
      );
    case AppRoutes.profile:
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    default:
      return MaterialPageRoute(
        builder: (_) =>
            Scaffold(body: Center(child: Text(AppTexts.routeNotFound))),
      );
  }
}
