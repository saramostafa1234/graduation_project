// lib/screens/story_session_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
// تأكد من استيراد هذه الملفات
import 'break.dart';
import 'quiz_screen.dart';
// import '../services/api_service.dart'; // قد نحتاجه لاحقاً

class StorySessionScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;
  final String jwtToken;

  // إضافة const و super.key
  const StorySessionScreen({
    super.key,
    required this.sessionData,
    required this.jwtToken,
  });

  @override
  _StorySessionScreenState createState() => _StorySessionScreenState();
}

class _StorySessionScreenState extends State<StorySessionScreen> {
  int _currentStoryIndex = 0;
  late List<String> _storyParts = []; // تهيئة بقائمة فارغة
  Timer? _sessionTimer;
  // المدة الفعلية للقصة
  static const Duration _storyDisplayDuration = Duration(minutes: 10);
  // static const Duration _storyDisplayDuration = Duration(seconds: 15); // للاختبار
  // المدة الفعلية للبريك
  static const Duration _breakDuration = Duration(minutes: 3);
  // static const Duration _breakDuration = Duration(seconds: 7); // للاختبار

  // --- المتغيرات غير المستخدمة حالياً (سيتم استخدامها لاحقاً) ---
  Duration _remainingTime = _storyDisplayDuration; // القيمة الأولية
  bool _isBreakActive = false;
  // ---------------------------------------------------------

  // --- إضافة متغير isLoading ---
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _parseStoryParts(); // استخراج أجزاء القصة
    if (_storyParts.isNotEmpty) {
       _remainingTime = _storyDisplayDuration; // إعادة تعيين الوقت
      // _startSessionTimer(); // <-- سنبدأ المؤقت لاحقاً عند الحاجة
    } else {
      // التعامل مع حالة عدم وجود قصة
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("خطأ: لا يوجد محتوى قصة لهذه الجلسة."), backgroundColor: Colors.red));
           if (Navigator.canPop(context)) Navigator.pop(context);
         }
       });
    }
  }

  // --- دالة لاستخراج أجزاء القصة ---
  void _parseStoryParts() {
     try {
       // محاولة قراءة من مفتاح 'stories' كقائمة
       final storiesData = widget.sessionData['details']?['stories'];
       if (storiesData != null && storiesData is List && storiesData.isNotEmpty) {
          _storyParts = List<String>.from(storiesData.map((item) => item.toString()));
       }
       // إذا فشل، محاولة قراءة من مفتاح 'parts' كقائمة
       else {
          final partsData = widget.sessionData['details']?['parts'];
          if (partsData != null && partsData is List && partsData.isNotEmpty) {
             _storyParts = List<String>.from(partsData.map((item) => item.toString()));
          }
          // إذا فشل، محاولة قراءة من '_text' وتقسيمه
          else {
             final textData = widget.sessionData['details']?['_text'];
             if (textData != null && textData is String && textData.isNotEmpty) {
                _storyParts = textData.split(RegExp(r'\n\s*\n')); // التقسيم بالأسطر الفارغة
             }
             // إذا فشل، استخدام 'story' كحل أخير
             else {
                final storyData = widget.sessionData['details']?['story'];
                if (storyData != null && storyData is String && storyData.isNotEmpty) {
                   _storyParts = [storyData]; // اعتبرها جزء واحد
                } else {
                   _storyParts = []; // القصة فارغة
                }
             }
          }
       }
       _storyParts.removeWhere((part) => part.trim().isEmpty); // إزالة الأجزاء الفارغة
       print("Parsed story parts count: ${_storyParts.length}");
     } catch (e) {
        print("Error parsing story parts: $e");
        _storyParts = [];
     }
  }


  @override
  void dispose() { _sessionTimer?.cancel(); super.dispose(); }

  // --- (الدوال التالية غير مستخدمة حالياً، سيتم تفعيلها لاحقاً) ---
  void _startSessionTimer() { /* ... منطق المؤقت ... */ }
  void _handleSessionPartCompletion() { /* ... منطق انتهاء الجزء ... */ }
  Future<void> _goToBreak() async { /* ... منطق الانتقال للبريك ... */ }
  void _goToQuiz() { /* ... منطق الانتقال للكويز ... */ }
  String formatDuration(Duration duration) { /* ... */ return ""; }
  String _convertToArabicNumbers(String number) { /* ... */ return ""; }
  // -------------------------------------------------------------

  // --- دالة للانتقال للجزء التالي (مبسطة حالياً) ---
  void _nextPart() {
     if (_currentStoryIndex < _storyParts.length - 1) {
        setState(() {
           _currentStoryIndex++;
        });
     } else {
        // اكتملت أجزاء القصة، انتقل للكويز (أو شاشة النهاية)
        _goToQuiz(); // يجب تفعيل هذه الدالة لاحقاً
        print("End of story parts. Should navigate to quiz.");
     }
  }


  @override
  Widget build(BuildContext context) {
    final String currentStoryPart = _storyParts.isNotEmpty && _currentStoryIndex < _storyParts.length
                                  ? _storyParts[_currentStoryIndex] : '...';
    // --- تحديد لون الخلفية (مثال) ---
    const Color backgroundColor = Colors.white;
    const Color textColor = Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
         title: Text(widget.sessionData['title'] ?? 'جلسة قصة', style: const TextStyle(color: textColor, fontSize: 20)),
         backgroundColor: backgroundColor, elevation: 0, iconTheme: const IconThemeData(color: textColor), centerTitle: true,
      ),
      body: _storyParts.isEmpty
        ? const Center(child: Text("خطأ: لا يوجد محتوى قصة لهذه الجلسة.", style: TextStyle(color: Colors.red)))
        : Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // --- يمكنك إضافة مؤشر التقدم أو الوقت هنا ---
            // Padding(padding: ..., child: LinearProgressIndicator(...)),
            // Padding(padding: ..., child: Text("الوقت المتبقي: ...")),
            const SizedBox(height: 15),

            // --- عرض نص القصة الحالي ---
            Expanded(
              child: SingleChildScrollView( // للسماح بالتمرير
                 padding: const EdgeInsets.all(25.0),
                 child: Text(
                    currentStoryPart,
                    textAlign: TextAlign.right, // محاذاة لليمين
                    textDirection: TextDirection.rtl, // اتجاه النص
                    style: const TextStyle(fontSize: 20, height: 1.8, color: textColor),
                 ),
              ),
            ),

            // --- رقم الجزء (اختياري) ---
            Padding( padding: const EdgeInsets.only(bottom: 15), child: Text( "الجزء ${_currentStoryIndex + 1} من ${_storyParts.length}", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),),

            // --- زر التالي ---
            Padding(
               padding: const EdgeInsets.all(30),
               // استخدام const للـ ElevatedButton
               child: ElevatedButton(
                 // استخدام _isLoading لمنع الضغط المتكرر (تم تعريفه الآن)
                 onPressed: _isLoading ? null : _nextPart, // <-- استدعاء الدالة المبسطة
                 style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // لون مختلف
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50), // تحديد حجم
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                 ),
                 child: const Text("التالي", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               ),
            )
          ],),
    );
  }
}