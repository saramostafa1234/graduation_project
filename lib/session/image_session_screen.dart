// lib/screens/image_session_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';

// --- استيراد الملفات الضرورية ---
// تأكد من صحة هذه المسارات
import 'break.dart'; // <-- استيراد شاشة البريك الجديدة
import 'quiz_screen.dart';           // <-- استيراد شاشة الكويز

class ImageSessionScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData; // بيانات الجلسة الممررة
  final String jwtToken;                // التوكن للمصادقة
  // يمكنك إضافة indexInGroup هنا إذا أردتِ تغيير الألوان
  // final int indexInGroup;

  const ImageSessionScreen({
    super.key,
    required this.sessionData,
    required this.jwtToken,
    // required this.indexInGroup,
  });

  @override
  _ImageSessionScreenState createState() => _ImageSessionScreenState();
}

class _ImageSessionScreenState extends State<ImageSessionScreen> {
  int _currentImageIndex = 0;
  late List<String> _imageNames;
  Timer? _sessionTimer;
  // المدة الفعلية لعرض الصورة
  static const Duration _imageDisplayDuration = Duration(minutes: 9);
  // static const Duration _imageDisplayDuration = Duration(seconds: 10); // للاختبار
  // المدة الفعلية للبريك
  static const Duration _breakDuration = Duration(minutes: 2);
  // static const Duration _breakDuration = Duration(seconds: 5); // للاختبار

  late Duration _remainingTime;
  bool _isSessionPaused = false;
  // --- إضافة متغير isLoading ---
  bool _isLoading = false; // للتحكم في حالة الزر "التالي" أثناء الانتقال

  @override
  void initState() {
    super.initState();
    // استخراج قائمة أسماء الصور بأمان
    try {
      final imagesData = widget.sessionData['details']?['images'];
      if (imagesData != null && imagesData is List) {
         _imageNames = List<String>.from(imagesData.map((item) => item.toString()));
         _imageNames.removeWhere((name) => name.trim().isEmpty);
      } else { _imageNames = []; }
    } catch (e) { print("Error parsing images: $e"); _imageNames = []; }

    if (_imageNames.isNotEmpty) {
      _remainingTime = _imageDisplayDuration;
      _startSessionTimer();
    } else {
      print("Error: No valid images found.");
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("خطأ: لا توجد صور."), backgroundColor: Colors.red));
           if (Navigator.canPop(context)) Navigator.pop(context);
         }
       });
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  // --- بدء أو استئناف مؤقت عرض الصورة ---
  void _startSessionTimer() {
    if (!mounted || _isSessionPaused) return;
    _sessionTimer?.cancel();
    setStateIfMounted(() {}); // تحديث بسيط للحالة إذا لزم الأمر
    print("Starting/Resuming timer for image index: $_currentImageIndex, remaining: $_remainingTime");
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        print("Timer finished for image index: $_currentImageIndex");
        // لا نستخدم isLoading هنا، الانتقال يحدث مباشرة
        _handleSessionPartCompletion();
      } else {
        setStateIfMounted(() { _remainingTime = _remainingTime - const Duration(seconds: 1); });
      }
    });
  }

  // --- إيقاف المؤقت مؤقتًا ---
  void _pauseTimer() {
    if (!_isSessionPaused) {
      setStateIfMounted(() { _isSessionPaused = true; });
      _sessionTimer?.cancel();
      print("Timer paused at: $_remainingTime");
    }
  }

  // --- استئناف المؤقت ---
  void _resumeTimer() {
    if (_isSessionPaused) {
      setStateIfMounted(() { _isSessionPaused = false; });
      _startSessionTimer();
    }
  }

  // --- التعامل مع انتهاء وقت عرض الصورة أو الضغط على التالي ---
  Future<void> _handleSessionPartCompletion() async { // جعلها async للمعالجة
     _sessionTimer?.cancel(); // إيقاف المؤقت الحالي
     if (!mounted) return;
     // بدء التحميل لمنع الضغط المتكرر على "التالي" أثناء الانتقال
     setStateIfMounted(() { _isLoading = true; });

     // تأخير بسيط للسماح بعرض حالة التحميل (اختياري)
     await Future.delayed(const Duration(milliseconds: 100));

     if (!mounted) return; // تحقق مرة أخرى

    if (_currentImageIndex < _imageNames.length - 1) {
      await _goToBreak(); // انتظار انتهاء البريك
    } else {
      _goToQuiz();
    }

     // إيقاف التحميل بعد الانتهاء من الانتقال أو العودة من البريك
     if (mounted) {
        setStateIfMounted(() { _isLoading = false; });
     }
  }

  // --- الانتقال لشاشة البريك ---
  Future<void> _goToBreak() async {
     if (!mounted) return;
     print("Going to break...");
     // الانتقال لشاشة البريك وانتظار العودة منها
     await Navigator.push(
       context,
       MaterialPageRoute(
         // استخدام شاشة البريك المتحركة وتمرير المدة
         builder: (context) => AnimatedWaveScreen(breakDuration: _breakDuration)
       ),
     );
      // بعد العودة من البريك
      if (mounted) {
        print("Returned from break. Moving to next image.");
         setStateIfMounted(() {
           _currentImageIndex++;
           _remainingTime = _imageDisplayDuration; // إعادة تعيين الوقت
         });
         _startSessionTimer(); // بدء مؤقت الصورة التالية
      }
  }

  // --- الانتقال لشاشة الكويز ---
  void _goToQuiz() {
     if (!mounted) return;
     print("Image session parts finished. Navigating to Quiz.");
     final int sessionId = widget.sessionData['session_ID_'] ?? -1;

     if (sessionId == -1) { /* ... معالجة خطأ ID ... */ return; }

     Navigator.pushReplacement(
       context,
       MaterialPageRoute(builder: (context) => QuizScreen(sessionId: sessionId, jwtToken: widget.jwtToken)),
     );
  }

  // --- دالة آمنة لتحديث الواجهة ---
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) { setState(fn); }
  }

  // --- دوال تنسيق الوقت ---
   String formatDuration(Duration duration) {
      duration = duration.isNegative ? Duration.zero : duration;
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$minutes:$seconds';
   }
   String _convertToArabicNumbers(String number) {
      const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      String result = number;
      for (int i = 0; i < english.length; i++) { result = result.replaceAll(english[i], arabic[i]); }
      return result;
   }

  // --- بناء الواجهة ---
  @override
  Widget build(BuildContext context) {
    final String currentImageName = _imageNames.isNotEmpty && _currentImageIndex < _imageNames.length
                                  ? _imageNames[_currentImageIndex] : '';
    final String imagePath = "assets/img/$currentImageName";
    const Color backgroundColor = Colors.white; // لون ثابت
    const Color textColor = Colors.black87;   // لون ثابت

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.sessionData['title'] ?? 'جلسة صور', style: const TextStyle(color: textColor, fontSize: 20)),
        backgroundColor: backgroundColor, elevation: 0, iconTheme: const IconThemeData(color: textColor), centerTitle: true,
         actions: [
            IconButton( icon: Icon(_isSessionPaused ? Icons.play_arrow : Icons.pause, color: textColor), tooltip: _isSessionPaused ? 'استئناف' : 'إيقاف مؤقت',
               onPressed: () { if (_isSessionPaused) { _resumeTimer(); } else { _pauseTimer(); } }, ) ],
      ),
      body: _imageNames.isEmpty
          ? const Center(child: Text("خطأ: لا توجد صور لهذه الجلسة.", style: TextStyle(color: Colors.red)))
          : Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                 Padding( padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                   child: LinearProgressIndicator( value: (_currentImageIndex + 1) / _imageNames.length, backgroundColor: Colors.grey[300], valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal), minHeight: 6,),),
                 Padding( padding: const EdgeInsets.only(top: 5.0, bottom: 10),
                   child: Text( _isSessionPaused ? "متوقف مؤقتاً" : "الوقت المتبقي: ${_convertToArabicNumbers(formatDuration(_remainingTime))}", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: textColor.withOpacity(0.9), fontWeight: FontWeight.w500), textDirection: TextDirection.rtl,),),
                Expanded( child: Padding( padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Container( decoration: BoxDecoration( borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300, width: 1), boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0,3))] ), clipBehavior: Clip.antiAlias,
                      child: Center( child: currentImageName.isNotEmpty
                          ? Image.asset( imagePath, fit: BoxFit.contain,
                              frameBuilder: (context, child, frame, wasSyncLoaded) => wasSyncLoaded ? child : AnimatedOpacity(opacity: frame == null ? 0 : 1, duration: const Duration(seconds: 1), curve: Curves.easeOut, child: child),
                              errorBuilder: (context, error, stackTrace) { print("Error loading asset: $imagePath"); return Column( mainAxisAlignment: MainAxisAlignment.center, children: [ const Icon(Icons.broken_image_outlined, size: 80, color: Colors.grey), const SizedBox(height: 10), Text("خطأ تحميل الصورة\n($currentImageName)", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),],); },)
                          : const Icon(Icons.image_not_supported_outlined, size: 100, color: Colors.grey),),),),),
                 Padding( padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                   child: Text( "الصورة ${_currentImageIndex + 1}: تأمل تعابير الوجه", // <-- نص افتراضي
                     textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: textColor.withOpacity(0.9)),),),
                 Padding( padding: const EdgeInsets.only(left: 40, right: 40, bottom: 30, top: 10),
                   child: ElevatedButton.icon(
                      // تعطيل الزر أثناء التحميل أو الإيقاف المؤقت
                      onPressed: _isLoading || _isSessionPaused ? null : _handleSessionPartCompletion,
                      icon: const Icon(Icons.skip_next_rounded), label: const Text("التالي"),
                      style: ElevatedButton.styleFrom( backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),),)],),);
  }

  // --- دالة بناء كارت التقدم (لم تعد مستخدمة هنا، يمكن حذفها) ---
  // Widget _buildProgressCard(...) { ... }

} // نهاية الكلاس _ImageSessionScreenState