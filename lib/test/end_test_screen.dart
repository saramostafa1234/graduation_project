// lib/screens/quiz/end_test_screen.dart
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
// لا نحتاج لـ ApiService هنا، HomeScreen هو من سيتعامل مع المؤقت
// import 'package:myfinalpro/services/api_service.dart';
import 'package:myfinalpro/screens/home_screen.dart'; // استيراد HomeScreen
import 'package:shared_preferences/shared_preferences.dart'; // لحفظ وقت البدء للمؤقت

class EndTestScreen extends StatefulWidget {
  @override
  _EndTestScreenState createState() => _EndTestScreenState();
}

class _EndTestScreenState extends State<EndTestScreen> {
  late ConfettiController _confettiController;
  // لا نحتاج لـ ApiService هنا
  // final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    // تشغيل التأثير بعد بناء الواجهة لتجنب الأخطاء
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if(mounted) _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose(); // تحرير الموارد
    super.dispose();
  }

  // دالة لحفظ وقت بداية المؤقت والانتقال للشاشة الرئيسية
  Future<void> _startCooldownAndNavigateHome() async {
     try {
        final prefs = await SharedPreferences.getInstance();
        // حفظ الوقت الحالي كنقطة بداية لمؤقت الـ 48 ساعة
        final cooldownStartTimeMillis = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt('lastSessionStartTime', cooldownStartTimeMillis); // استخدم نفس المفتاح المستخدم في HomeScreen
        print("EndTestScreen: Cooldown timer started. Ref time saved: $cooldownStartTimeMillis");

        if (!mounted) return; // تحقق قبل الانتقال

        // الانتقال للشاشة الرئيسية وإزالة كل الشاشات السابقة
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false, // إزالة كل المسارات السابقة
        );
     } catch (e) {
        print("Error saving cooldown start time: $e");
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('خطأ في بدء مؤقت الانتظار.'))
           );
           // حتى لو حدث خطأ، حاول الانتقال للشاشة الرئيسية
           Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(builder: (context) => const HomeScreen()),
             (route) => false,
           );
        }
     }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2C73D9), // خلفية زرقاء
      body: Stack( // استخدام Stack لوضع التأثير فوق المحتوى
        alignment: Alignment.center, // توسيط المحتوى
        children: [
          // --- تأثير القصاصات ---
          Align(
            alignment: Alignment.topCenter, // من الأعلى
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, // انفجار للخارج
              shouldLoop: false, // لا يتكرر
              colors: const [ // ألوان القصاصات
                  Color(0xff2C73D9), Colors.white, Colors.purple,
                  Colors.yellow, Colors.green, Colors.redAccent
              ],
               gravity: 0.1, // جاذبية أقل لتساقط أبطأ
               emissionFrequency: 0.04, // تقليل معدل الإطلاق
               numberOfParticles: 15, // عدد أقل من القصاصات
            ),
          ),
          // --- نافذة الحوار (محتوى الشاشة) ---
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // حواف دائرية
            contentPadding: const EdgeInsets.all(24), // padding داخلي
            content: Column(
              mainAxisSize: MainAxisSize.min, // لأخذ أقل ارتفاع
              children: [
                const Text(
                  '🎉 رائع! لقد أنهيت الاختبار بنجاح 🎉', // رسالة مشجعة
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20, // حجم الخط
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: Color(0xff2C73D9)), // لون النص
                ),
                const SizedBox(height: 25), // مسافة
                ElevatedButton(
                  onPressed: _startCooldownAndNavigateHome, // استدعاء الدالة عند الضغط
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2C73D9), // لون الزر
                    foregroundColor: Colors.white, // لون النص
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50), // padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // حواف الزر
                    ),
                     elevation: 3, // ظل خفيف
                  ),
                  // نص الزر للانتقال للشاشة الرئيسية
                  child: const Text('العودة للرئيسية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}