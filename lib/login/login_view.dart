// lib/login/login_view.dart
import 'package:flutter/material.dart';
import 'package:myfinalpro/login/forgetPassword.dart'; // تأكد من المسار
import 'package:myfinalpro/registration/registration.dart'; // تأكد من المسار
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/assessment_screen.dart'; // شاشة التقييم
import '../services/Api_services.dart'; // خدمة الـ API (تأكد من اسم الملف api_service.dart)
import '../widget/custom.dart'; // الويدجت المخصص (CustomTextField)

class LoginView extends StatefulWidget {
  // استخدام const للـ constructor
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscureText = true; // لإخفاء/إظهار كلمة المرور
  bool isSelected = false; // لحالة "تذكرني"
  bool isLoading = false; // لعرض مؤشر التحميل
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage; // لعرض رسائل الخطأ

  @override
  void initState() {
    super.initState();
    _loadSavedEmail(); // محاولة تحميل الإيميل المحفوظ عند بدء الشاشة
  }

  @override
  void dispose() {
    // التخلص من الـ controllers لمنع تسرب الذاكرة
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- دوال SharedPreferences ---
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print("LoginView: Token only saved.");
  }

  // دالة لحفظ كل بيانات المستخدم والتوكن
  Future<void> _saveUserDataAndImage(String token, String name, String email, String? imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await prefs.setString('user_image_url', imageUrl);
      print("LoginView: Image URL saved: $imageUrl");
    } else {
      await prefs.remove('user_image_url');
      print("LoginView: Image URL removed or not provided.");
    }
    print("LoginView: User data saved - Name: $name, Email: $email");
  }

  // تحميل الإيميل المحفوظ (إذا وُجد)
  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    if (savedEmail != null && mounted) {
      setState(() {
        _emailController.text = savedEmail;
        isSelected = true; // تحديد "تذكرني" تلقائيًا
      });
    }
  }


  // --- دالة تسجيل الدخول المعدلة بالكامل ---
  Future<void> _login() async {
    if(isLoading) return;
    if (!mounted) return;
    setState(() { isLoading = true; _errorMessage = null; });

    try {
      // 1. تسجيل الدخول
      final result = await ApiService.loginUser(_emailController.text.trim(), _passwordController.text);
      if (!mounted) return;

      if (result['success'] == true && result['token'] != null) {
        final String receivedToken = result['token'];
        print("Login Successful. Token received. Fetching user profile...");

        // 2. جلب بيانات الملف الشخصي
        final profileResult = await ApiService.getUserProfile(receivedToken);
        print("--- PROFILE FETCH RESULT ---"); print("Success: ${profileResult['success']}"); print("Data: ${profileResult['data']}"); print("Message: ${profileResult['message']}"); print("--------------------------");
        if (!mounted) return;

        String fullName = "المستخدم"; String userEmail = _emailController.text.trim(); String? imageUrl;

        // 3. التحقق واستخراج البيانات
        if (profileResult['success'] == true && profileResult['data'] != null && profileResult['data'] is Map) {
          final profileData = profileResult['data'] as Map<String, dynamic>;
          // --- !!! تأكدي من أسماء المفاتيح الفعلية هنا !!! ---
          final String firstName = profileData['name'] ?? profileData['Name'] ?? '';
          final String lastName = profileData['surname'] ?? profileData['Surname'] ?? '';
          userEmail = profileData['email'] ?? profileData['Email'] ?? userEmail;
          imageUrl = profileData['image_url']?.toString() ?? profileData['Image_']?.toString() ?? profileData['profilePicture']?.toString();
          // ----------------------------------------------------
          fullName = '$firstName $lastName'.trim();
          if (fullName.isEmpty) fullName = "مستخدم جديد";
          // 4. حفظ كل البيانات
          print("==> Attempting to save user data...");
          await _saveUserDataAndImage(receivedToken, fullName, userEmail, imageUrl);
          print("==> User data save function called.");
        } else {
          print("Failed to fetch profile after login: ${profileResult['message']}");
          await _saveToken(receivedToken); // حفظ التوكن فقط
          _errorMessage = 'تم الدخول، لكن فشل تحميل بيانات الملف الشخصي.';
        }

        // 5. حفظ الإيميل إذا تم تحديد "تذكرني"
        if (isSelected) {
          final prefs = await SharedPreferences.getInstance();
          if (!mounted) return;
          await prefs.setString('saved_email', _emailController.text.trim());
        }

        // 6. الانتقال لشاشة التقييم
        if (!mounted) return;
        print("Navigating to AssessmentScreen...");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AssessmentScreen(jwtToken: receivedToken)));

      } else {
        // فشل تسجيل الدخول
        if (mounted) { setState(() { _errorMessage = result['message'] ?? 'فشل تسجيل الدخول. تأكد من البريد وكلمة المرور.'; }); }
      }
    } catch (e, s) {
      print("Login Error: $e"); print("Login Stacktrace: $s");
      if (mounted) setState(() { _errorMessage = 'حدث خطأ غير متوقع. تحقق من اتصالك.'; });
    } finally {
      if (mounted) { setState(() { isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- الجزء العلوي (الشعار والعنوان) ---
              Container( width: double.infinity, alignment: Alignment.center, margin: EdgeInsets.only(top: screenHeight * 0.1),
                child: Image.asset("assets/images/logo.png", width: screenWidth * 0.5, fit: BoxFit.contain,),),
              const SizedBox(height: 10),
              const Text("تسجيل الدخول ", style: TextStyle(color: Color(0xFF2C73D9), fontSize: 22, fontWeight: FontWeight.bold,),),
              const SizedBox(height: 40),

              // --- حقول الإدخال ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomTextField( hintText: "أدخل البريد الإلكتروني", obscureText: false, controller: _emailController, onChanged: (value) {}, keyboardType: TextInputType.emailAddress,),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                // --- استخدام CustomTextField مع suffixIcon و onSuffixIconPressed ---
                child: CustomTextField(
                  hintText: "أدخل كلمة المرور",
                  obscureText: _obscureText,
                  controller: _passwordController,
                  onChanged: (value) {},
                  // تمرير بيانات الأيقونة (IconData)
                  suffixIcon: _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  // تمرير الدالة التي سيتم استدعاؤها عند الضغط
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                // -----------------------------------------------------------------
              ),

              // --- عرض رسالة الخطأ ---
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text( _errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14), textAlign: TextAlign.center,),
                ),
              const SizedBox(height: 10),

              // --- صف تذكرني ونسيت كلمة المرور ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row( mainAxisSize: MainAxisSize.min, children: [
                    Checkbox( value: isSelected, onChanged: (bool? value) { setState(() { isSelected = value ?? false; }); }, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact,),
                    InkWell( onTap: () => setState(() { isSelected = !isSelected; }), child: const Text( "تذكرني", style: TextStyle(fontSize: 14, color: Colors.black54),),),
                  ],),
                  InkWell( onTap: () { Navigator.push( context, MaterialPageRoute( builder: (context) => ForgetPassword()),); },
                    child: const Text( "هل نسيت كلمة المرور؟", style: TextStyle( fontSize: 14, color: Color(0xFF2C73D9),),),),
                ],),),
              const SizedBox(height: 30),

              // --- زر تسجيل الدخول ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login, // <-- استدعاء الدالة المعدلة
                  style: ElevatedButton.styleFrom( backgroundColor: const Color(0xFF2C73D9), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12),), padding: const EdgeInsets.symmetric(vertical: 12),),
                  child: isLoading
                      ? const SizedBox( height: 24, width: 24, child: CircularProgressIndicator( color: Colors.white, strokeWidth: 3,),)
                      : const Text( "تسجيل الدخول", style: TextStyle( color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,),),
                ),
              ),
              const SizedBox(height: 25),

              // --- رابط إنشاء حساب جديد ---
              Row( mainAxisAlignment: MainAxisAlignment.center, children: [
                InkWell( onTap: () { Navigator.push( context, MaterialPageRoute( builder: (context) => RegistrationView()),); },
                  child: const Text( "أنشئ حساب جديد", style: TextStyle( color: Color(0xFF2C73D9), fontSize: 15, fontWeight: FontWeight.bold,),),),
                const Text( "لا تمتلك حساب؟", style: TextStyle( color: Color(0xFF4A4A4A), fontSize: 15,),),
                const SizedBox(width: 5),
                
              ],),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}