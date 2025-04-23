// lib/screens/quiz/quiz_manager_screen.dart
import 'package:flutter/material.dart';
import 'package:myfinalpro/test/models/quiz_model.dart'; // <<--- نموذج الكويز
import '../services/Api_services.dart';
import 'package:myfinalpro/test/quiz_type1_screen.dart';
import 'package:myfinalpro/test/QuizType2Screen.dart';
import 'package:myfinalpro/test/end_test_screen.dart';
import 'package:myfinalpro/screens/common/loading_indicator.dart';
import 'package:myfinalpro/screens/common/error_display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myfinalpro/login/login_view.dart';
 // لـ debugPrint
import 'package:flutter/foundation.dart';

class QuizManagerScreen extends StatefulWidget {
  const QuizManagerScreen({super.key});

  @override
  State<QuizManagerScreen> createState() => _QuizManagerScreenState();
}

class _QuizManagerScreenState extends State<QuizManagerScreen> {
  Future<QuizSession?>? _quizSessionFuture;
  int _currentQuizStep = 0; // 0 for Type1, 1 for Type2
  String? _jwtToken;
  bool _isCompletingStep = false;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchData();
  }

  Future<void> _loadTokenAndFetchData() async {
    setState(() {
      _quizSessionFuture = null;
      _currentQuizStep = 0;
      _isCompletingStep = false;
    });
    final prefs = await SharedPreferences.getInstance();
    _jwtToken = prefs.getString('auth_token');
    if (!mounted) { return; } // <-- إضافة أقواس
    if (_jwtToken == null || _jwtToken!.isEmpty) {
      debugPrint("QuizManager: Token not found, redirecting.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // <-- إضافة أقواس
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginView()));
        } // <-- إضافة أقواس
      });
      setState(() => _quizSessionFuture = Future.error("Token required"));
    } else {
      _loadQuizData();
    }
  }

  void _loadQuizData() {
    if (_jwtToken == null) { return; } // <-- إضافة أقواس
    setState(() {
      _quizSessionFuture = ApiService.fetchNextTestDetail(_jwtToken!);
    });
  }

 Future<void> _completeQuizStep(QuizDetail detailToComplete) async {
  if (_jwtToken == null || _isCompletingStep) {
    return;
  }
  setState(() => _isCompletingStep = true);

  // --- !!! التعديل الأساسي هنا !!! ---
  // استخدام الـ ID الكبير (id) وليس detailId
  int idToMark = detailToComplete.id; // <-- استخدام الحقل 'id' الكبير
  debugPrint(
      "QuizManager: Completing Step ${_currentQuizStep + 1}. Sending Item ID: $idToMark");
  // --- نهاية التعديل ---

  // التأكد من أن الـ ID صالح قبل الإرسال
  if (idToMark <= 0) {
     debugPrint("QuizManager Error: Attempting to complete step with invalid ID ($idToMark).");
     setStateIfMounted(() => _isCompletingStep = false);
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في بيانات الخطوة الحالية.')),
     );
     return;
  }

  bool success =
      await ApiService.markTestDetailComplete(_jwtToken!, idToMark);

  if (!mounted) {
    _isCompletingStep = false;
    return;
  }

  if (success) {
    debugPrint("QuizManager: API complete for ID $idToMark successful.");
    if (_currentQuizStep == 0) {
      debugPrint("QuizManager: Moving to Step 2 (Type 2 Comparison).");
      setStateIfMounted(() {
        _currentQuizStep = 1;
        _isCompletingStep = false;
      });
    } else {
      debugPrint("QuizManager: Quiz finished. Navigating to EndTestScreen.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EndTestScreen()),
      );
    }
  } else {
    debugPrint("QuizManager: API complete failed for ID $idToMark.");
     if (mounted) { // تحقق قبل عرض SnackBar
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطأ في حفظ التقدم. حاول لاحقاً.')),
         );
     }
    setStateIfMounted(() => _isCompletingStep = false);
  }
}

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) { setState(fn); } // <-- إضافة أقواس
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuizSession?>(
      future: _quizSessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator(message: 'جاري تحميل الاختبار...');
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          String errorMsg = 'فشل تحميل بيانات الاختبار.';
          if (snapshot.error != null) {
            debugPrint("QuizManager FutureBuilder Error: ${snapshot.error}");
            // --- تعديل: إضافة الأقواس ---
            if (snapshot.error.toString().contains("Token required")) {
              errorMsg = "خطأ مصادقة.";
            } else if (snapshot.error.toString().contains("Unauthorized")) {
              errorMsg = "انتهت صلاحية الدخول.";
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) { // <-- إضافة أقواس
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginView()));
                } // <-- إضافة أقواس
              });
            } else {
              errorMsg += '\n(${snapshot.error})';
            }
            // --- نهاية التعديل ---
          }
          return ErrorDisplay(
              message: errorMsg, onRetry: _loadTokenAndFetchData);
        }

        final quizSession = snapshot.data!;

        if (quizSession.details.isEmpty) {
          return ErrorDisplay(
              message: 'خطأ: لا توجد خطوات في بيانات الاختبار.',
              onRetry: _loadQuizData);
        }
        if (quizSession.details.length < 2 && _currentQuizStep == 1) {
          return ErrorDisplay(
              message: 'خطأ: بيانات الاختبار غير كافية للخطوة الثانية.',
              onRetry: _loadQuizData);
        }

        if (_currentQuizStep == 0) {
          final step1Detail = quizSession.details[0];
          return QuizType1Screen(
            key: const ValueKey('quiz_step_0'),
            detail: step1Detail,
            onCorrect: () => _completeQuizStep(step1Detail),
            isCompleting: _isCompletingStep,
          );
        } else {
          // --- تعديل: إضافة الأقواس ---
          if (quizSession.details.length < 2) {
            return ErrorDisplay(
                message: 'خطأ داخلي: لا يمكن عرض الخطوة الثانية.',
                onRetry: _loadQuizData);
          }
          // --- نهاية التعديل ---
          final option1 = quizSession.details[1];
          final option2 = quizSession.newDetail;
          return QuizType2Screen(
            key: const ValueKey('quiz_step_1'),
            rootQuestion: quizSession.question,
            option1Detail: option1,
            option2Detail: option2,
            rootAnswer: quizSession.answer,
            onCorrect: (QuizDetail correctChoice) => _completeQuizStep(correctChoice),
            isCompleting: _isCompletingStep,
          );
        }
      },
    );
  }
}