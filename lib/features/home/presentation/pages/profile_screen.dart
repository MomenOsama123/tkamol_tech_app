import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taamol_tech/core/constants/app_colors.dart';
import 'package:taamol_tech/features/auth/presentation/pages/settings_screen.dart';
import 'package:taamol_tech/features/auth/presentation/screens/login_screen.dart';
import 'package:taamol_tech/features/products/presentation/pages/add_edit_product_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isAdmin = false;
  String _fullName = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      // إذا لم يكن هناك مستخدم (وضع الزائر Guest) ننهي التحميل فوراً
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      _email = user.email ?? '';

      final response = await _supabase
          .from('profiles')
          .select('full_name, is_admin')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        final rawIsAdmin = response['is_admin'];
        setState(() {
          _fullName = response['full_name'] ?? _email.split('@').first;
          _isAdmin =
              rawIsAdmin == true ||
              rawIsAdmin.toString().toLowerCase() == 'true' ||
              rawIsAdmin == 1;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final user = _supabase.auth.currentUser;
    final bool isGuest = user == null; // 🌟 فحص حالة الزائر

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryCyan),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardWhite,
        elevation: 0,
        title: Text(
          isArabic ? 'الملف الشخصي' : 'My Profile',
          style: const TextStyle(
            color: AppColors.deepPurple,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. كارت معلومات الحساب / الزائر
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryCyan.withValues(
                          alpha: 0.2,
                        ),
                        child: Icon(
                          isGuest ? Icons.person_outline_rounded : Icons.person,
                          size: 50,
                          color: AppColors.deepPurple,
                        ),
                      ),
                      if (_isAdmin && !isGuest)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.deepPurple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // الاسم أو حالة الزائر
                  Text(
                    isGuest
                        ? (isArabic ? 'زائر' : 'Guest')
                        : (_fullName.isEmpty ? 'مستخدم' : _fullName),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepPurple,
                      fontFamily: 'Tajawal',
                    ),
                  ),

                  // تفاصيل المستخدم المسجل فقط
                  if (!isGuest) ...[
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ID: ${user.id.substring(0, 8).toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ] else ...[
                    // 🌟 إضافة هوية "زائر" لتبدو كأن هناك مستخدم (Guest User Identity)
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryCyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isArabic ? 'جلسة زائر نشطة' : 'Active Guest Session',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryCyan,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],

                  // 🌟 الواجهة الخاصة بالزائر وتوجيهه لتسجيل الدخول
                  if (isGuest) ...[
                    const SizedBox(height: 12),
                    Text(
                      isArabic
                          ? 'قم بتسجيل الدخول للاستفادة من كافة ميزات التطبيق'
                          : 'Log in to enjoy all app features',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isArabic
                              ? 'تسجيل الدخول / حساب جديد'
                              : 'Log In / Register',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. أدوات الإدارة (تظهر للأدمن المسجل فقط)
            if (_isAdmin && !isGuest) ...[
              Align(
                alignment: isArabic
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  isArabic ? 'أدوات الإدارة (Admin Panel)' : 'Admin Tools',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.deepPurple.withValues(alpha: 0.2),
                  ),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.add_shopping_cart,
                    color: AppColors.deepPurple,
                  ),
                  title: Text(
                    isArabic ? 'إضافة منتج جديد' : 'Add New Product',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddEditProductScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 3. الإعدادات والتفضيلات
            Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                isArabic ? 'الإعدادات والتفضيلات' : 'Settings',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.primaryCyan,
                ),
                title: Text(
                  isArabic ? 'الإعدادات' : 'Settings',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // 4. زر تسجيل الخروج (يظهر فقط للمستخدم المسجل وليس الزائر)
            if (!isGuest)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    isArabic ? 'تسجيل الخروج' : 'Log Out',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}