// lib/widget/side_bar_menu.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// --- استيراد الشاشات والملفات الضرورية ---
import 'package:myfinalpro/widget/about_app.dart';
import 'package:myfinalpro/screens/assessment_screen.dart';
import 'package:myfinalpro/widget/editaccount.dart';
import 'package:myfinalpro/widget/report.dart';
// import 'package:myfinalpro/session/session_details_screen.dart'; // غير مستخدم مباشرة هنا
import 'package:myfinalpro/login/login_view.dart'; // <-- استيراد شاشة تسجيل الدخول
import 'package:myfinalpro/widget/page_route_names.dart';
import 'package:myfinalpro/models/smart_assistant_screen.dart';

class SideBarMenuTest extends StatefulWidget {
  const SideBarMenuTest({super.key});

  @override
  State<SideBarMenuTest> createState() => _SideBarMenuTestState();
}

class _SideBarMenuTestState extends State<SideBarMenuTest> {
  String _userName = "جاري التحميل...";
  String _userEmail = "";
  String? _jwtToken;
  String? _userImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // ... (نفس الكود السابق)
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      final token = prefs.getString('auth_token');
      final imageUrl = prefs.getString('user_image_url');

      print("Sidebar: Read from Prefs - Name: $name, Email: $email, ImageUrl: $imageUrl, Token: ${token != null}");

      if (mounted) {
        setState(() {
          _userName = name ?? "اسم المستخدم";
          _userEmail = email ?? "البريد الإلكتروني";
          _jwtToken = token;
          _userImageUrl = imageUrl;
        });
      }
    } catch (e) {
      print("Error loading user data in Sidebar: $e");
      if (mounted) { setState(() { _userName = "خطأ"; _userEmail = ""; _userImageUrl = null; }); }
    }
  }

  // دالة الانتقال للمساعد الذكي (افترض أنها موجودة وصحيحة)
  Future<void> _navigateToAssessment() async {
     if (_jwtToken != null) {
      if (Navigator.canPop(context)) Navigator.pop(context); // أغلق الـ Drawer أولاً
      // انتظر قليلاً قبل الانتقال لضمان إغلاق الـ Drawer بسلاسة
      await Future.delayed(const Duration(milliseconds: 150));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AssessmentScreen(jwtToken: _jwtToken!)),
      );
    } else {
      // يمكنك عرض رسالة خطأ إذا لم يتم العثور على التوكن
      print("Sidebar: Cannot navigate to Assessment, token is null.");
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('خطأ: لم يتم العثور على معلومات المستخدم.')),
         );
       }
    }
  }

  // --- دالة تسجيل الخروج المعدلة ---
  Future<void> _logout() async {
    try {
      print("Sidebar: Initiating logout...");
      final prefs = await SharedPreferences.getInstance();

      // 1. مسح جميع بيانات المستخدم والتوكن المحفوظة
      await prefs.remove('auth_token');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_image_url');
      await prefs.remove('saved_email'); // مسح الإيميل المحفوظ أيضًا

      print("Sidebar: User data cleared from SharedPreferences.");

      // 2. التحقق من أن الويدجت ما زال موجودًا قبل استخدام context
      if (!mounted) return;

      print("Sidebar: Navigating to LoginView and removing previous routes.");
      // 3. الانتقال إلى شاشة تسجيل الدخول وإزالة جميع الشاشات السابقة
      //    استخدام (Route<dynamic> route) => false يضمن إزالة كل المسار السابق.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()), // الانتقال لشاشة تسجيل الدخول
        (Route<dynamic> route) => false, // هذا الشرط يزيل كل الشاشات السابقة
      );
    } catch (e) {
      print("Error during logout: $e");
      // يمكنك عرض رسالة للمستخدم في حالة حدوث خطأ أثناء عملية تسجيل الخروج
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تسجيل الخروج.')),
        );
      }
    }
  }
  // ------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // --- DrawerHeader ---
            DrawerHeader(
              margin: EdgeInsets.zero, padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration( color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))) ),
              child: Row( crossAxisAlignment: CrossAxisAlignment.center, children: [
                  // --- الصورة وأيقونة التعديل ---
                  Stack( alignment: Alignment.bottomLeft, children: [
                      CircleAvatar( radius: screenWidth * 0.095, backgroundColor: Colors.grey.shade200,
                        backgroundImage: (_userImageUrl != null && _userImageUrl!.isNotEmpty)
                            ? NetworkImage(_userImageUrl!) as ImageProvider
                            : const AssetImage("assets/images/default_avatar.png"),
                        onBackgroundImageError: (_, __) => print("Drawer Image Error"), // التعامل مع خطأ تحميل الصورة
                      ),
                       Positioned( bottom: 0, left: 0, child: Material( color: Colors.transparent, shape: const CircleBorder(), clipBehavior: Clip.antiAlias,
                           child: InkWell( borderRadius: BorderRadius.circular(screenWidth * 0.05), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => EditAccountScreen())); },
                              child: Container( padding: const EdgeInsets.all(5), decoration: BoxDecoration( shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.grey.shade300, width: 1) ),
                                child: Icon( Icons.edit_outlined, size: screenWidth * 0.045, color: Colors.blueGrey.shade700,),),),),),],),
                  const SizedBox(width: 15),
                  // --- الاسم والإيميل ---
                  Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text( _userName, style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 17, fontWeight: FontWeight.bold,), maxLines: 1, overflow: TextOverflow.ellipsis, ),
                        const SizedBox(height: 5),
                        Text( _userEmail, style: const TextStyle(color: Colors.blueGrey, fontSize: 14,), maxLines: 1, overflow: TextOverflow.ellipsis,),],),),],),),

            // --- عناصر القائمة ---
            _buildDrawerItem(icon: Icons.person_outline, text: "تعديل الملف الشخصي", onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => EditAccountScreen())); }),
            _buildDrawerItem(icon: Icons.home_outlined, text: "الصفحة الرئيسية", onTap: () { Navigator.pushNamedAndRemoveUntil(context, PageRouteName.home, (route) => false); }),
            _buildDrawerItem(icon: Icons.bar_chart_outlined, text: "التقارير", onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ReportView())); }),
            _buildDrawerItem(icon: Icons.smart_toy_outlined, text: "المساعد الذكي", onTap: () {
              Navigator.pushNamed(context, PageRouteName.smartAssistant);
            }), // استخدم الدالة المنفصلة
            _buildDrawerItem(icon: Icons.info_outline, text: "حول التطبيق", onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const About_App())); }),
            const Divider(height: 15, thickness: 0.8, indent: 16, endIndent: 16),
            _buildDrawerItem(
              icon: Icons.logout,
              text: "تسجيل الخروج",
              onTap: _logout, // <-- استدعاء الدالة المعدلة هنا
              color: Colors.redAccent // لون مميز لتسجيل الخروج
            ),
          ],
        ),
      ),
    );
  }

  // --- دالة مساعدة لبناء عناصر القائمة (نفس الكود السابق) ---
  Widget _buildDrawerItem({required IconData icon, required String text, required VoidCallback onTap, Color? color}) {
     final itemColor = color ?? const Color(0xFF2C73D9);
    return ListTile(
      leading: Icon(icon, color: itemColor, size: 26),
      title: Text(text, style: TextStyle(fontSize: 16, color: itemColor)),
      trailing: Icon(Icons.keyboard_arrow_left, color: itemColor.withOpacity(0.6)),
      onTap: () {
         // أغلق الـ Drawer أولاً إذا كان مفتوحًا
         if (Navigator.canPop(context)) Navigator.pop(context);
         // انتظر قليلاً قبل تنفيذ الـ onTap لضمان إغلاق الـ Drawer
         Future.delayed(const Duration(milliseconds: 150), onTap);
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
    );
  }

}