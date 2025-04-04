import 'dart:math'; // ✅ إضافة هذا السطر لاستخدام pi

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

void showSuccessPopup(BuildContext context, Widget nextScreen) {
  ConfettiController confettiController =
      ConfettiController(duration: Duration(days: 1)); // ✅ استمرار التأثير

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      confettiController.play(); // ✅ تشغيل التأثير عند ظهور النافذة

      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Stack(
            alignment: Alignment.center,
            children: [
              // ✅ تأثير القصاصات الورقية
              ConfettiWidget(
                confettiController: confettiController,
                blastDirection: -pi / 2,
                // ✅ سقوط الورق من الأعلى
                shouldLoop: true,
                // ✅ استمرار التأثير حتى يضغط المستخدم
                colors: [
                  Colors.red,
                  Colors.green,
                  Color(0xff2C73D9),
                  Colors.yellow,
                  Colors.purple
                ],
                // ✅ ألوان متعددة
                gravity: 0.3,
                numberOfParticles: 20,
                emissionFrequency: 0.05,

                // ✅ جعل الورق مربعات
                createParticlePath: (size) {
                  return Path()..addRect(Rect.fromLTWH(0, 0, 10, 10));
                },
              ),

              // ✅ محتوى النافذة
              SizedBox(
                height: 250,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🎉 أحسنت، أنت رائع!',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2C73D9)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff2C73D9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(180, 50),
                      ),
                      onPressed: () {
                        confettiController.stop(); // ✅ إيقاف التأثير عند الضغط
                        Navigator.of(context).pop();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => nextScreen),
                          );
                        });
                      },
                      child: const Text('التالي',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
