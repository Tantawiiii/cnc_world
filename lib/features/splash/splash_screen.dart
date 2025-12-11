import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constant/app_assets.dart';
import '../../core/constant/app_colors.dart';
import '../../core/di/inject.dart' as di;
import '../../core/routing/app_routes.dart';
import '../../core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _backgroundController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _backgroundPulse;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;

  final StorageService _storageService = di.sl<StorageService>();

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _backgroundPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _checkAuthAndNavigate();
          }
        });
      }
    });

    _mainController.forward();
  }

  void _checkAuthAndNavigate() {
    final token = _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _backgroundController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _backgroundPulse,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5 + (_backgroundPulse.value * 0.3),
                    colors: [
                      AppColors.logoBlack,
                      AppColors.logoBlack.withOpacity(0.95),
                      AppColors.logoBlack,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  animation: _particleAnimation.value,
                  glowAnimation: _glowAnimation.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_mainController, _glowController]),
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 1.2 + (_glowAnimation.value * 0.3),
                      child: Container(
                        width: 250.w,
                        height: 250.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.logoYellow.withOpacity(
                                _glowAnimation.value * 0.4,
                              ),
                              blurRadius: 60.r,
                              spreadRadius: 20.r,
                            ),
                            BoxShadow(
                              color: AppColors.logoWhite.withOpacity(
                                _glowAnimation.value * 0.2,
                              ),
                              blurRadius: 40.r,
                              spreadRadius: 10.r,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Image.asset(
                            AppAssets.appLogoWithoutBack,
                            width: 220.w,
                            height: 220.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animation;
  final double glowAnimation;

  ParticlePainter({required this.animation, required this.glowAnimation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;

    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2 / 12) + (animation * math.pi * 2);
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      final distance = math.sqrt(
        math.pow(x - center.dx, 2) + math.pow(y - center.dy, 2),
      );
      final opacity = (1.0 - (distance / (radius * 1.5))).clamp(0.0, 1.0);

      paint.color = AppColors.logoYellow.withOpacity(
        opacity * glowAnimation * 0.6,
      );

      canvas.drawCircle(Offset(x, y), 3, paint);
    }

    // Draw radial glow lines
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2 / 8) + (animation * math.pi);
      final startRadius = radius * 0.6;
      final endRadius = radius * 1.2;

      paint.color = AppColors.logoYellow.withOpacity(glowAnimation * 0.2);
      paint.strokeWidth = 2;

      final startX = center.dx + math.cos(angle) * startRadius;
      final startY = center.dy + math.sin(angle) * startRadius;
      final endX = center.dx + math.cos(angle) * endRadius;
      final endY = center.dy + math.sin(angle) * endRadius;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.glowAnimation != glowAnimation;
  }
}
