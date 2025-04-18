// lib/screens/animated_break_screen.dart (اسم مقترح للملف)
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math'; // لاستخدام sin

class AnimatedWaveScreen extends StatefulWidget {
  final Duration breakDuration; // <-- استقبال مدة البريك

  // تعديل الـ constructor لاستقبال المدة واستخدام super.key
  const AnimatedWaveScreen({super.key, required this.breakDuration});

  @override
  _AnimatedWaveScreenState createState() => _AnimatedWaveScreenState();
}

class _AnimatedWaveScreenState extends State<AnimatedWaveScreen>
    with SingleTickerProviderStateMixin {
  // --- متغيرات الأنيميشن ---
  late AnimationController _animationController;
  double _waveOffset = 0.0;
  // ---------------------

  // --- متغيرات المؤقت ---
  Timer? _breakTimer;
  late Duration _remainingTime;
  // ---------------------

  @override
  void initState() {
    super.initState();

    // --- إعداد الأنيميشن ---
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // يمكن تعديل سرعة الموجة
    )..addListener(() {
        if (mounted) {
          setState(() {
            _waveOffset = _animationController.value * 2 * pi;
          });
        }
      })
      ..repeat(); // تكرار الأنيميشن

    // --- إعداد وبدء مؤقت البريك ---
    _remainingTime = widget.breakDuration; // استخدام المدة الممررة
    _startBreakTimer();
    // --------------------------
  }

  // --- بدء المؤقت التنازلي للبريك ---
  void _startBreakTimer() {
    _breakTimer?.cancel();
    print("Starting break timer for: $_remainingTime");
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }

      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        print("Break finished. Popping screen.");
        if (Navigator.canPop(context)) {
           Navigator.pop(context); // العودة للشاشة السابقة
        }
      } else {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // التخلص من controller الأنيميشن
    _breakTimer?.cancel(); // التخلص من المؤقت
    super.dispose();
  }

   // --- دوال تنسيق الوقت (يمكن نقلها لملف utils) ---
   String formatDuration(Duration duration) {
      duration = duration.isNegative ? Duration.zero : duration;
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$minutes:$seconds'; // عرض دقائق:ثواني
   }
   String _convertToArabicNumbers(String number) {
      const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      String result = number;
      for (int i = 0; i < english.length; i++) { result = result.replaceAll(english[i], arabic[i]); }
      return result;
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية الشاشة
          Container(color: Colors.lightBlue[50]),

          // --- الموجة المتحركة في الخلفية ---
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            painter: WavePainter(_waveOffset), // استخدام قيمة الأنيميشن
          ),

          // --- محتوى شاشة البريك فوق الموجة ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 const Text(
                    "وقت الراحة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32, // خط أكبر
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E4A8A), // لون أزرق أغمق
                       shadows: [ Shadow(blurRadius: 1.0, color: Colors.black26, offset: Offset(1, 1)),]
                    ),
                  ),
                  const SizedBox(height: 35),
                  // --- عرض المؤقت ---
                  Text(
                     _convertToArabicNumbers(formatDuration(_remainingTime)),
                     style: const TextStyle(
                        fontSize: 70, // خط كبير جداً للمؤقت
                        fontWeight: FontWeight.w700, // خط أثقل
                        color: Colors.white,
                        fontFamily: 'monospace', // خط مناسب للأرقام
                         shadows: [ Shadow(blurRadius: 4.0, color: Colors.black54, offset: Offset(1, 2)),] // ظل أوضح
                     ),
                     textDirection: TextDirection.ltr, // لضمان عرض الأرقام صحيحاً
                  ),
                   const SizedBox(height: 15),
                   Text("دقيقة : ثانية", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                  // ------------------
                  const SizedBox(height: 50),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 50.0),
                     child: Text(
                       "استرخِ قليلاً...", // نص أبسط
                        style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.95)),
                        textAlign: TextAlign.center,
                     ),
                   ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- كلاس WavePainter (مع التعديلات السابقة) ---
class WavePainter extends CustomPainter {
  final double waveOffset;
  WavePainter(this.waveOffset);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = const Color(0xff2C73D9).withOpacity(0.6);
    Path path = Path();
    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      double sineValue = sin((x * 0.015) + waveOffset);
      double y = size.height * 0.75 + (sineValue * 35);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height); path.close();
    canvas.drawPath(path, paint);

    Paint paint2 = Paint()..color = const Color(0xff5AAFFF).withOpacity(0.4);
    Path path2 = Path();
    path2.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      double sineValue = sin((x * 0.02) + waveOffset + pi / 2);
      double y = size.height * 0.80 + (sineValue * 45);
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height); path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}