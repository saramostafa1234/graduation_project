// lib/widget/side_bar_menu.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// --- استيراد الشاشات والملفات الضرورية ---
import 'package:myfinalpro/widget/about_app.dart';
import 'package:myfinalpro/screens/assessment_screen.dart';
import 'package:myfinalpro/widget/editaccount.dart';
import 'package:myfinalpro/widget/report.dart';
import 'package:myfinalpro/session/session_details_screen.dart';
import 'package:myfinalpro/login/login_view.dart';
import 'package:myfinalpro/widget/page_route_names.dart';

class SideBarMenuTest extends StatefulWidget {
  const SideBarMenuTest({super.key});

  @override
  State<SideBarMenuTest> createState() => _SideBarMenuTestState();
}

class _SideBarMenuTestState extends State<SideBarMenuTest> {
  String _userName = "جاري التحميل...";
  String _userEmail = "";
  String? _jwtToken;
  String? _userImageUrl; // لتخزين رابط الصورة

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      // --- قراءة البيانات بالمفاتيح الصحيحة ---
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      final token = prefs.getString('auth_token');
      final imageUrl = prefs.getString('user_image_url'); // <-- قراءة رابط الصورة
      // ---------------------------------------

      print("Sidebar: Read from Prefs - Name: $name, Email: $email, ImageUrl: $imageUrl, Token: ${token != null}");

      if (mounted) {
        setState(() {
          _userName = name ?? "اسم المستخدم";
          _userEmail = email ?? "البريد الإلكتروني";
          _jwtToken = token;
          _userImageUrl = imageUrl; // <-- تخزين الرابط في الحالة
        });
      }
    } catch (e) {
      print("Error loading user data in Sidebar: $e");
      if (mounted) { setState(() { _userName = "خطأ"; _userEmail = ""; _userImageUrl = null; }); }
    }
  }

  Future<void> _navigateToAssessment() async { /* ... نفس الكود ... */ }
  Future<void> _logout() async { /* ... نفس الكود ... */ }

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
            DrawerHeader(
              margin: EdgeInsets.zero, padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration( color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))) ),
              child: Row( crossAxisAlignment: CrossAxisAlignment.center, children: [
                  // --- الصورة وأيقونة التعديل ---
                  Stack( alignment: Alignment.bottomLeft, children: [
                      // ******** تعديل عرض الصورة ********
                      CircleAvatar( radius: screenWidth * 0.095, backgroundColor: Colors.grey.shade200,
                        backgroundImage: (_userImageUrl != null && _userImageUrl!.isNotEmpty)
                            ? NetworkImage(_userImageUrl!) as ImageProvider
                            : const AssetImage("assets/images/default_avatar.png"), // تأكدي من وجود الصورة الافتراضية
                        onBackgroundImageError: (_, __) => print("Drawer Image Error"),
                      ),
                      // **********************************
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
           // _buildDrawerItem(icon: Icons.notifications_none, text: "الإشعارات", onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => SessionView())); }),
            _buildDrawerItem(icon: Icons.bar_chart_outlined, text: "التقارير", onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ReportView())); }),
            _buildDrawerItem(icon: Icons.smart_toy_outlined, text: "المساعد الذكي", onTap: _navigateToAssessment),
            _buildDrawerItem(icon: Icons.info_outline, text: "حول التطبيق", onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const About_App())); }),
            const Divider(height: 15, thickness: 0.8, indent: 16, endIndent: 16),
            _buildDrawerItem(icon: Icons.logout, text: "تسجيل الخروج", onTap: _logout, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  // --- دالة مساعدة لبناء عناصر القائمة ---
  Widget _buildDrawerItem({required IconData icon, required String text, required VoidCallback onTap, Color? color}) {
     final itemColor = color ?? const Color(0xFF2C73D9);
    return ListTile(
      leading: Icon(icon, color: itemColor, size: 26),
      title: Text(text, style: TextStyle(fontSize: 16, color: itemColor)),
      trailing: Icon(Icons.keyboard_arrow_left, color: itemColor.withOpacity(0.6)),
      onTap: () {
         if (Navigator.canPop(context)) Navigator.pop(context);
         Future.delayed(const Duration(milliseconds: 150), onTap);
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
    );
  }

} // نهاية الكلاس