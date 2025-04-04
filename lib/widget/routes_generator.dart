import 'package:flutter/material.dart';
import 'package:myfinalpro/screens/emotion.dart';
import 'package:myfinalpro/screens/home_screen.dart';
import 'package:myfinalpro/screens/timetest.dart';
import 'package:myfinalpro/widget/page_route_names.dart';
import 'package:myfinalpro/widget/report.dart';

import '../login/login_view.dart';
import '../registration/registration.dart';
import '../screens/skills.dart';
import '../screens/splash_screen.dart';
import '../services/break.dart';
import '../session/seesion.dart';
import 'about_app.dart';
import 'chatpot.dart';
import 'editaccount.dart';
//import '../splash/splash_view.dart';

class RoutesGenerator {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case PageRouteName.initial:
        return MaterialPageRoute(
          builder: (context) => SplashScreen(),
          settings: settings,
        );
      case PageRouteName.login:
        return MaterialPageRoute(
          builder: (context) => LoginView(),
          settings: settings,
        );
      case PageRouteName.registration:
        return MaterialPageRoute(
          builder: (context) => RegistrationView(),
          settings: settings,
        );
      case PageRouteName.skills:
        return MaterialPageRoute(
          builder: (context) => SkillsScreen(),
          settings: settings,
        );
      case PageRouteName.emotions:
        return MaterialPageRoute(
          builder: (context) => EmotionScreen(),
          settings: settings,
        );
      case PageRouteName.editProfile:
        return MaterialPageRoute(
          builder: (context) => EditProfileScreen(),
          settings: settings,
        );
      case PageRouteName.aboutApp:
        return MaterialPageRoute(
          builder: (context) => About_App(),
          settings: settings,
        );
      case PageRouteName.reports:
        return MaterialPageRoute(
          builder: (context) => ReportView(),
          settings: settings,
        );
      case PageRouteName.chatPot:
        return MaterialPageRoute(
          builder: (context) => ChatBotScreen(),
          settings: settings,
        );
      case PageRouteName.session:
        return MaterialPageRoute(
          builder: (context) => SessionView(),
          settings: settings,
        );
      case PageRouteName.starttest:
        return MaterialPageRoute(
          builder: (context) => StartTest(),
          settings: settings,
        );
      case PageRouteName.breaak:
        final nextScreen = settings.arguments
            as Widget?; // استرجاع الشاشة التالية من `arguments`
        return MaterialPageRoute(
          builder: (context) =>
              AnimatedWaveScreen(nextScreen: nextScreen ?? HomeScreen()),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => SplashScreen(),
        );
    }
  }
}
