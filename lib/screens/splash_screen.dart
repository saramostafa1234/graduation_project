import 'dart:async';

import 'package:flutter/material.dart';

import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool animateText = false; // متغير للتحكم في حركة النص
  bool animateLogo = false; // متغير للتحكم في ظهور اللوجو

  @override
  void initState() {
    super.initState();
    // تأخير بسيط قبل بدء الحركات لجعلها أكثر سلاسة
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        animateText = true;
        animateLogo = true;
      });
    });

    // الانتقال إلى شاشة الـ Onboarding بعد 4 ثوانٍ
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // خلفية بيضاء للشاشة
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // تأثير التلاشي (Fade-in) على اللوجو
              AnimatedOpacity(
                opacity: animateLogo ? 1 : 0,
                // يظهر تدريجياً عند تفعيل animateLogo
                duration: Duration(milliseconds: 1200),
                child: Image.asset(
                  'assets/images/WhatsApp Image 2025-03-11 at 7.15.10 PM.jpeg',
                  // الصورة المستخدمة كشعار للتطبيق
                  width: screenWidth * 0.5,
                  fit: BoxFit.contain,
                ),
              ),

              // النص المتحرك الذي يكون على شكل جزئين "ASP" و "iQ"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // تحريك الجزء الأول من النص "ASP" من اليسار
                  AnimatedSlide(
                    offset: animateText ? Offset(0, 0) : Offset(-1, 0),
                    // يتحرك من اليسار
                    duration: Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    child: Text(
                      "ASP",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(
                            0xFF2C73D9), // لون أزرق متناسق مع تصميم التطبيق
                      ),
                    ),
                  ),

                  // تحريك الجزء الثاني من النص "iQ" من اليمين
                  AnimatedSlide(
                    offset: animateText ? Offset(0, 0) : Offset(1, 0),
                    // يتحرك من اليمين
                    duration: Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    child: Text(
                      "iQ",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C73D9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}