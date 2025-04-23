// lib/session/start_test.dart
import 'package:flutter/material.dart';
// تأكد من استيراد مدير الاختبارات
import 'package:myfinalpro/test/quiz_manager_screen.dart';

class StartTest extends StatelessWidget {
  const StartTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2C73D9),
      body: Stack( // استخدام Stack لوضع السهم فوق المحتوى
        children: [
          Center(
            child: Container(
              width: 300, // عرض الحاوية
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white, // خلفية بيضاء
                borderRadius: BorderRadius.circular(16.0), // حواف دائرية
                boxShadow: [ // ظل خفيف (اختياري)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // لأخذ أقل ارتفاع ممكن
                children: [
                  const Text(
                    'حان وقت الاختبار',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo', // تأكد من استخدام الخط
                        color: Color(0xff2C73D9)),
                  ),
                  const SizedBox(height: 15),

                  // --- عرض صورة GIF ---
                  // تأكد من وجود الملف في المسار الصحيح وأنه معرف في pubspec.yaml
                  Image.asset(
                    'assets/images/clock.gif', // تأكد من المسار الصحيح
                    width: 180, // تعديل الحجم
                    height: 140,
                    // معالج خطأ إذا لم يتم تحميل الـ GIF
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading GIF: assets/clock.gif - $error");
                      return Container(
                        width: 180,
                        height: 140,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.timer_off_outlined, color: Colors.grey, size: 50)),
                      );
                    },
                  ),
                  // --- نهاية صورة GIF ---

                  const SizedBox(height: 25), // مسافة قبل الزر
                  Center(
                    child: SizedBox(
                      width: double.infinity, // زر بعرض الحاوية
                      child: ElevatedButton(
                        onPressed: () {
                          // --- الانتقال لمدير الاختبارات ---
                          // استخدم pushReplacement إذا كنت لا تريد السماح بالرجوع لهذه الشاشة
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuizManagerScreen()), // <-- الانتقال لمدير الاختبار
                          );
                          // --- نهاية الانتقال ---
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2C73D9), // لون الزر
                          foregroundColor: Colors.white, // لون النص
                          padding: const EdgeInsets.symmetric(vertical: 14), // padding داخلي
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // حواف الزر
                          ),
                          elevation: 4, // ظل الزر
                          textStyle: const TextStyle( // نمط النص داخل الزر
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        child: const Text('ابدأ الاختبار'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- سهم الرجوع ---
          Positioned(
            // تحديد الموضع أعلى اليمين (مع الأخذ في الاعتبار الـ safe area)
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward, // استخدام السهم القياسي للخلف في RTL
                  size: 35, color: Colors.white),
              onPressed: () {
                // الرجوع للشاشة السابقة (غالباً SessionDetailsScreen أو HomeScreen)
                Navigator.pop(context);
              },
               tooltip: 'رجوع', // نص توضيحي عند الضغط المطول
            ),
          ),
          // --- نهاية سهم الرجوع ---
        ],
      ),
    );
  }
}