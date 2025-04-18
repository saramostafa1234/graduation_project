// lib/screens/session_player_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'break.dart'; // شاشة البريك
import 'quiz_screen.dart';           // شاشة الكويز
// import '../services/api_service.dart'; // قد نحتاجه للكويز

class SessionPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;
  final String jwtToken;

  const SessionPlayerScreen({
    super.key,
    required this.sessionData,
    required this.jwtToken,
  });

  @override
  _SessionPlayerScreenState createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends State<SessionPlayerScreen> {
  int _currentPartIndex = 0; // مؤشر للجزء الحالي
  late List<dynamic> _sessionParts; // قائمة بأجزاء الجلسة (من details.$values)
  Timer? _sessionTimer;
  Duration _remainingTime = Duration.zero;
  bool _isSessionPaused = false;
  bool _isLoadingNext = false; // لمنع الضغط المتكرر على التالي

  // مدد افتراضية (يمكن تعديلها أو جعلها تعتمد على النوع لاحقاً)
  static const Duration _imageDuration = Duration(minutes: 9);
  static const Duration _textStoryDuration = Duration(minutes: 10);
  static const Duration _imageBreak = Duration(minutes: 2);
  static const Duration _textStoryBreak = Duration(minutes: 3);

  @override
  void initState() {
    super.initState();
    _initializeSessionParts();
  }

  // تهيئة قائمة الأجزاء والبدء بالجزء الأول
  void _initializeSessionParts() {
    try {
      final details = widget.sessionData['details'];
      if (details is Map && details.containsKey('\$values') && details['\$values'] is List) {
        _sessionParts = details['\$values'];
        _sessionParts.removeWhere((part) => part == null); // إزالة أي أجزاء null
      } else {
        _sessionParts = [];
      }
    } catch (e) {
      print("Error initializing session parts: $e");
      _sessionParts = [];
    }

    if (_sessionParts.isNotEmpty) {
      _startPartTimer(_currentPartIndex); // ابدأ مؤقت الجزء الأول
    } else {
      _handleError("خطأ: لا يوجد محتوى لهذه الجلسة.");
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  // بدء مؤقت الجزء الحالي بناءً على نوعه
  void _startPartTimer(int partIndex) {
    if (!mounted || partIndex >= _sessionParts.length) return;
    _sessionTimer?.cancel(); // ألغ المؤقت القديم

    final currentPart = _sessionParts[partIndex];
    final String? partType = currentPart?['dataTypeOfContent']?.toString().toLowerCase();
    Duration partDuration;

    // تحديد مدة العرض بناءً على النوع
    if (partType == 'image' || partType == 'img') { // التعامل مع كلا الاحتمالين
      partDuration = _imageDuration;
    } else if (partType == 'text' || partType == 'story') { // التعامل مع كلا الاحتمالين
      partDuration = _textStoryDuration;
    } else {
      print("Warning: Unknown part type '$partType' for timer. Using default.");
      partDuration = _textStoryDuration; // مدة افتراضية
    }

    setStateIfMounted(() {
      _isLoadingNext = false; // تفعيل زر التالي
      _isSessionPaused = false;
      _remainingTime = partDuration;
    });
    print("Starting timer for part index: $partIndex, Type: $partType, Duration: $partDuration");

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      if (_isSessionPaused) return; // لا تنقص الوقت إذا كان متوقف مؤقتاً

      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        print("Timer finished for part index: $partIndex");
        _handleSessionPartCompletion();
      } else {
        setStateIfMounted(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      }
    });
  }

  // التعامل مع انتهاء وقت الجزء أو الضغط على التالي
  Future<void> _handleSessionPartCompletion() async {
    _sessionTimer?.cancel();
    if (!mounted || _isLoadingNext) return; // منع التنفيذ المتكرر
    setStateIfMounted(() { _isLoadingNext = true; }); // تعطيل زر التالي مؤقتاً

    // التحقق إذا كان هناك أجزاء متبقية
    if (_currentPartIndex < _sessionParts.length - 1) {
      // تحديد مدة البريك بناءً على نوع الجزء *الحالي*
       final currentPart = _sessionParts[_currentPartIndex];
       final String? partType = currentPart?['dataTypeOfContent']?.toString().toLowerCase();
       Duration breakDuration = (partType == 'image' || partType == 'img') ? _imageBreak : _textStoryBreak;

      await _goToBreak(breakDuration); // انتظار انتهاء البريك
      if (mounted) {
         setStateIfMounted(() {
            _currentPartIndex++; // الانتقال للجزء التالي
         });
         _startPartTimer(_currentPartIndex); // بدء مؤقت الجزء الجديد
      }
    } else {
      // اكتملت كل الأجزاء، انتقل للكويز
      _goToQuiz();
    }
     // إعادة تفعيل زر التالي بعد الانتهاء (إذا لم يتم الانتقال للكويز)
     if (mounted && _currentPartIndex < _sessionParts.length - 1) {
        setStateIfMounted(() { _isLoadingNext = false; });
     }
  }

  // الانتقال لشاشة البريك
  Future<void> _goToBreak(Duration breakDuration) async {
     if (!mounted) return;
     print("Going to break for $breakDuration...");
     await Navigator.push( context, MaterialPageRoute(builder: (context) => AnimatedWaveScreen(breakDuration: breakDuration)), );
     if (mounted) print("Returned from break.");
     // عند العودة، سيتم استكمال التنفيذ في _handleSessionPartCompletion
  }

  // الانتقال للكويز
  void _goToQuiz() {
     if (!mounted) return;
     print("Session parts finished. Navigating to Quiz.");
     final int sessionId = widget.sessionData['session_ID_'] ?? -1;
     if (sessionId == -1) { _handleError("خطأ: رقم تعريف الجلسة غير صالح."); return; }
     Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => QuizScreen(sessionId: sessionId, jwtToken: widget.jwtToken)), );
  }

  // التعامل مع الأخطاء
  void _handleError(String message) {
     print("SessionPlayer Error: $message");
     if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
        // يمكنك العودة للشاشة السابقة أو الهوم
        if(Navigator.canPop(context)) Navigator.pop(context);
     }
  }

  // إيقاف واستئناف المؤقت (اختياري)
  void _pauseTimer() { /* ... نفس كود الإيقاف ... */ }
  void _resumeTimer() { /* ... نفس كود الاستئناف ... */ }

  // تنسيق الوقت
  String formatDuration(Duration duration) { /* ... نفس الكود السابق ... */ return "";}
  String _convertToArabicNumbers(String number) { /* ... نفس الكود السابق ... */ return "";}
  void setStateIfMounted(VoidCallback fn) { if (mounted) setState(fn); }

  @override
  Widget build(BuildContext context) {
    // الحصول على بيانات الجزء الحالي بأمان
    final currentPart = (_sessionParts.isNotEmpty && _currentPartIndex < _sessionParts.length)
                        ? _sessionParts[_currentPartIndex] : null;
    final String? partType = currentPart?['dataTypeOfContent']?.toString().toLowerCase();
    final String partText = currentPart?['_text'] ?? '';
    final String imageName = currentPart?['image_'] ?? '';
    final String imagePath = imageName.isNotEmpty ? "assets/img/${imageName.replaceAll('\\', '/')}" : ''; // بناء المسار

    // --- تحديد لون الخلفية بناءً على group_id و index (مثال) ---
    final int groupId = widget.sessionData['group_id'] ?? 0;
    final int partIndexInTotal = _currentPartIndex; // يمكنك استخدام index أكثر تعقيداً إذا لزم الأمر
    Color backgroundColor = Colors.white; Color textColor = Colors.black87;
    // مثال بسيط: أزرق للانفعالات (group 1), أبيض للمهارات (group 2)
    // أو يمكنك تطبيق منطق 3-3-4 هنا إذا عرفت ترتيب الجزء داخل المجموعة
    if (groupId == 1) { backgroundColor = const Color(0xFF2C73D9); textColor = Colors.white; }
    // ----------------------------------------------------------

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.sessionData['title'] ?? 'الجلسة', style: TextStyle(color: textColor, fontSize: 20)),
        backgroundColor: backgroundColor, elevation: 0, centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        // يمكنك إضافة زر إيقاف/استئناف هنا
      ),
      body: currentPart == null
          ? const Center(child: Text("خطأ في تحميل محتوى الجلسة."))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 // --- شريط التقدم الكلي للجلسة ---
                 Padding( padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                   child: LinearProgressIndicator( value: (_currentPartIndex + 1) / _sessionParts.length, /* ... */),),
                 // --- الوقت المتبقي للجزء الحالي ---
                 Padding( padding: const EdgeInsets.only(top: 5.0, bottom: 10),
                   child: Text( "الوقت المتبقي: ${_convertToArabicNumbers(formatDuration(_remainingTime))}", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: textColor.withOpacity(0.9), fontWeight: FontWeight.w500), textDirection: TextDirection.rtl,),),

                 // --- عرض المحتوى (صورة أو نص) ---
                 Expanded(
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                     child: Center(
                       child: (partType == 'image' || partType == 'img') && imagePath.isNotEmpty
                         // عرض الصورة
                         ? Container( decoration: BoxDecoration( borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300, width: 1), boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: Offset(0,3))] ), clipBehavior: Clip.antiAlias,
                              child: Image.asset( imagePath, fit: BoxFit.contain, errorBuilder: (ctx, err, st) => const Icon(Icons.error_outline, color: Colors.red, size: 50),)
                           )
                         // عرض النص (لـ text أو story أو أي نوع آخر)
                         : SingleChildScrollView( // للسماح بتمرير النص الطويل
                             child: Text( partText, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 20, height: 1.7, color: textColor),),
                           ),
                     ),
                   ),
                 ),

                 // --- رقم الجزء ---
                 Padding( padding: const EdgeInsets.only(bottom: 15), child: Text( "الجزء ${_currentPartIndex + 1} من ${_sessionParts.length}", textAlign: TextAlign.center, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14)),),

                 // --- زر التالي ---
                 Padding( padding: const EdgeInsets.only(left: 40, right: 40, bottom: 30, top: 10),
                   child: ElevatedButton.icon(
                      onPressed: _isLoadingNext ? null : _handleSessionPartCompletion, // استدعاء المعالج
                      icon: const Icon(Icons.skip_next_rounded), label: const Text("التالي"),
                      style: ElevatedButton.styleFrom( backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),),)
              ],
            ),
    );
  }
}