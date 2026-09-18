import 'package:flutter/material.dart';
import 'package:taamol_tech/core/constants/app_colors.dart';
import 'package:taamol_tech/features/home/presentation/pages/contact_us_screen.dart';
import 'package:taamol_tech/features/home/presentation/pages/home_screen.dart';
import 'package:taamol_tech/features/home/presentation/pages/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 🌟 العناصر الثابتة لصفحات الشريط السفلي
  final List<Widget> _pages = const [
    HomeScreen(),
    ContactUsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryCyan,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_outlined),
            activeIcon: const Icon(Icons.grid_view),
            label: isArabic ? 'المنتجات' : 'Products',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.headset_mic_outlined),
            activeIcon: const Icon(Icons.headset_mic),
            label: isArabic ? 'تواصل معنا' : 'Contact Us',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: isArabic ? 'حسابي' : 'Profile',
          ),
        ],
      ),
    );
  }
}