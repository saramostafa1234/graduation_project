// lib/widget/routes_generator.dart
import 'package:flutter/material.dart';
// لا نحتاج dart:async هنا
// import 'dart:async';

// --- استيراد الشاشات والملفات الضرورية ---
// تأكد من صحة هذه المسارات في مشروعك
import 'package:myfinalpro/screens/emotion.dart';
import 'package:myfinalpro/screens/timetest.dart'; // StartTest
import 'package:myfinalpro/widget/page_route_names.dart';
import 'package:myfinalpro/widget/report.dart';        // ReportView
import 'package:myfinalpro/login/login_view.dart';      // LoginView
import 'package:myfinalpro/registration/registration.dart'; // RegistrationView
import 'package:myfinalpro/screens/skills.dart';       // SkillsScreen
import 'package:myfinalpro/screens/splash_screen.dart';  // SplashScreen
// تأكد من أن هذا هو المسار الصحيح لملف شاشة البريك وأن الكلاس بداخله اسمه AnimatedWaveScreen
import 'package:myfinalpro/session/break.dart';       // AnimatedWaveScreen (Break)
import 'package:myfinalpro/session/session_details_screen.dart'; // <-- شاشة تفاصيل الجلسة
import 'package:myfinalpro/widget/about_app.dart';      // About_App
import 'package:myfinalpro/screens/assessment_screen.dart'; // AssessmentScreen
import 'package:myfinalpro/widget/editaccount.dart';   // EditAccountScreen
// import 'package:myfinalpro/screens/home_screen.dart'; // <-- غير مستخدم هنا، تم حذفه

class RoutesGenerator {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    print("Generating route for: ${settings.name} with arguments: ${settings.arguments}"); // للتشخيص

    switch (settings.name) {
      case PageRouteName.initial:
        return MaterialPageRoute( builder: (_) => SplashScreen(), settings: settings, ); // إزالة const
      case PageRouteName.login:
        return MaterialPageRoute( builder: (_) => LoginView(), settings: settings, ); // إزالة const
      case PageRouteName.registration:
        return MaterialPageRoute( builder: (_) => RegistrationView(), settings: settings, ); // إزالة const
      case PageRouteName.skills:
        return MaterialPageRoute( builder: (_) => SkillsScreen(), settings: settings, ); // إضافة const إذا أمكن
      case PageRouteName.emotions:
        return MaterialPageRoute( builder: (_) => EmotionScreen(), settings: settings, ); // إضافة const إذا أمكن
      case PageRouteName.editProfile:
        return MaterialPageRoute( builder: (_) => EditAccountScreen(), settings: settings, ); // إضافة const إذا أمكن
      case PageRouteName.aboutApp:
        return MaterialPageRoute( builder: (_) => const About_App(), settings: settings, );
      case PageRouteName.reports:
        return MaterialPageRoute( builder: (_) => ReportView(), settings: settings, ); // إضافة const إذا أمكن
      case PageRouteName.starttest:
        return MaterialPageRoute( builder: (_) => StartTest(), settings: settings, ); // إضافة const إذا أمكن

      case PageRouteName.chatPot: // شاشة التقييم
        final String? tokenArgument = settings.arguments as String?;
        if (tokenArgument != null && tokenArgument.isNotEmpty) {
          return MaterialPageRoute( builder: (_) => AssessmentScreen(jwtToken: tokenArgument), settings: settings, );
        } else {
          print("RouteGenerator Error: Missing jwtToken for AssessmentScreen.");
          return _errorRoute(settings, "Token not provided for assessment");
        }

      case PageRouteName.session: // شاشة تفاصيل الجلسة التدريبية
        final args = settings.arguments;
        if (args is Map<String, dynamic> && args.containsKey('sessionData') && args.containsKey('jwtToken')) {
          final Map<String, dynamic> sessionData = args['sessionData'];
          final String jwtToken = args['jwtToken'];
          // تأكد من استيراد SessionDetailsScreen
          return MaterialPageRoute(
            builder: (_) => SessionDetailsScreen( sessionData: sessionData, jwtToken: jwtToken,), settings: settings,);
        } else {
          print("RouteGenerator Error: Missing or invalid arguments for SessionDetailsScreen. Args: $args");
          return _errorRoute(settings, "Session data missing");
        }

    // ******** تم تصحيح هذا الجزء ********
      case PageRouteName.breaak: // شاشة البريك
      // توقع أن الوسيط هو Duration
        final Duration? breakDurationArg = settings.arguments as Duration?;
        if (breakDurationArg != null) {
          // تأكد من استيراد AnimatedWaveScreen من المسار الصحيح
          // تأكد أن constructor في AnimatedWaveScreen يقبل breakDuration
          return MaterialPageRoute(
            builder: (_) => AnimatedWaveScreen(breakDuration: breakDurationArg), // <-- تمرير breakDuration فقط
            settings: settings,
          );
        } else {
          print("RouteGenerator Error: Missing breakDuration for AnimatedWaveScreen.");
          return _errorRoute(settings, "Break duration missing");
        }
    // *********************************

      default:
      // مسار غير معروف، اذهب للشاشة الابتدائية
        return MaterialPageRoute( builder: (_) => SplashScreen(), settings: settings, ); // إزالة const
    }
  }

  // --- دالة مساعدة لعرض شاشة خطأ ---
  static Route<dynamic> _errorRoute(RouteSettings settings, String error) {
    print("Route Error: $error for route ${settings.name}");
    return MaterialPageRoute(
      // استخدام const هنا
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('خطأ في التوجيه')),
        body: Center(child: Text('حدث خطأ أثناء الانتقال.\n($error)')),
      ),
      settings: settings,
    );
  }
}