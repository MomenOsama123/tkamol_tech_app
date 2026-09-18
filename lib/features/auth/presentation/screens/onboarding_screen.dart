import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/language_fab.dart';
import '../controllers/language_controller.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final int _totalSlides = 3;

  // الانتقال لشاشة إنشاء حساب جديد عند الضغط على زر ابدأ الآن
  Future<void> _onFinishOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('onboarding_completed', true);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  // الانتقال المباشر لشاشة تسجيل الدخول
  void _onLoginClick() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated Decorative Blob
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            top: -50,
            left: _currentIndex == 0 ? -100 : (_currentIndex == 1 ? 50 : 200),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryCyan.withValues(alpha: 0.1),
                    AppColors.primaryCyan.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar العلوي مع زر تخطي
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LanguageFab(
                        onLanguageChanged: LanguageController.toggleLanguage,
                      ),
                      TextButton(
                        onPressed: _onFinishOnboarding,
                        child: Text(
                          AppStrings.tr(context, AppStrings.skip),
                          style: const TextStyle(
                            color: AppColors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // محتوى السلايدر (PageView)
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: [
                      _buildPage(
                        title: AppStrings.tr(context, AppStrings.onboardingTitle1),
                        subtitle: AppStrings.tr(
                          context,
                          AppStrings.onboardingSubtitle1,
                        ),
                        iconData: Icons.laptop_mac_rounded,
                        color: AppColors.primaryCyan,
                      ),
                      _buildPage(
                        title: AppStrings.tr(context, AppStrings.onboardingTitle2),
                        subtitle: AppStrings.tr(
                          context,
                          AppStrings.onboardingSubtitle2,
                        ),
                        iconData: Icons.print_rounded,
                        color: AppColors.primaryGreen,
                      ),
                      _buildPage(
                        title: AppStrings.tr(context, AppStrings.onboardingTitle3),
                        subtitle: AppStrings.tr(
                          context,
                          AppStrings.onboardingSubtitle3,
                        ),
                        iconData: Icons.inventory_2_rounded,
                        color: AppColors.deepPurple,
                      ),
                    ],
                  ),
                ),

                // القسم السفلي
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // مؤشر النقاط (Dots Indicator)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _totalSlides,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentIndex == index ? 28 : 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? AppColors.primaryCyan
                                  : AppColors.borderLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // زر الإجراءات (الشرائح الأولى vs الشريحة الأخيرة)
                      if (_currentIndex == _totalSlides - 1)
                        // زر "ابدأ الآن" للذهاب لشاشة إنشاء الحساب
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _onFinishOnboarding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryCyan,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  color: AppColors.highlightYellow,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.tr(
                                    context,
                                    AppStrings.getStartedProducts,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.cardWhite,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_back_rounded,
                                  color: AppColors.cardWhite,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        // زر "التالي" للتنقل بين الشرائح
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryCyan,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              AppStrings.tr(context, AppStrings.next),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.cardWhite,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 14),

                      // رابط تسجيل الدخول المباشر أسفل الزر
                      if (_currentIndex == _totalSlides - 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.tr(context, AppStrings.alreadyHaveAccount),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: _onLoginClick,
                              child: Text(
                                AppStrings.tr(context, AppStrings.loginText),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.deepPurple,
                                  decoration: TextDecoration.underline,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Decorative Ring
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, size: 60, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.deepPurple,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }
}
