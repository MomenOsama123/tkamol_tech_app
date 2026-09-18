import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taamol_tech/core/constants/app_colors.dart';
import 'package:taamol_tech/core/constants/app_strings.dart';
import 'package:taamol_tech/features/home/presentation/pages/main_screen.dart';
import 'package:taamol_tech/features/auth/presentation/screens/login_screen.dart';
import 'package:taamol_tech/features/auth/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // تأخير بسيط لعرض الشعار فقط، مش عشان ننتظر أي بيانات
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 1. فيه جلسة مستخدم محفوظة (Session) بالفعل؟ يبقى يدخل على طول للتطبيق،
    //    وهناك هيتحدد الـ role (أدمن / مستخدم عادي) من auth_service.
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _goTo(const MainScreen());
      return;
    }

    // 2. مفيش جلسة، هل سبق وشاف المستخدم شاشات الـ onboarding؟
    final preferences = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding =
        preferences.getBool('onboarding_completed') ?? false;

    if (!mounted) return;

    if (hasSeenOnboarding) {
      _goTo(const LoginScreen());
    } else {
      _goTo(const OnboardingScreen());
    }
  }

  void _goTo(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepPurple,
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: child,
            ),
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الشعار
              Container(
                width: 110,
                height: 110,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.devices_other_rounded,
                  size: 60,
                  color: AppColors.primaryCyan,
                ),
              ),
              const SizedBox(height: 24),

              // اسم الشركة بالعربي
              Text(
                AppStrings.tr(context, AppStrings.appNameAr),
                style: const TextStyle(
                  color: AppColors.cardWhite,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 4),

              // اسم الشركة بالإنجليزي
              Text(
                AppStrings.tr(context, AppStrings.appNameEn),
                style: const TextStyle(
                  color: AppColors.primaryCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 12),

              // السلوجان المترجم
              Text(
                AppStrings.tr(context, AppStrings.sloganAr),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.borderLight,
                  fontSize: 12,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
