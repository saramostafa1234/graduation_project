import 'package:flutter/material.dart';
import 'package:myfinalpro/test/models/quiz_model.dart';
import 'package:myfinalpro/services/Api_services.dart';
import 'package:myfinalpro/test/quiz_type1_screen.dart';
import 'package:myfinalpro/test/QuizType2Screen.dart';
import 'package:myfinalpro/test/end_test_screen.dart';
import 'package:myfinalpro/screens/common/loading_indicator.dart';
import 'package:myfinalpro/screens/common/error_display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myfinalpro/login/login_view.dart';
import 'package:flutter/foundation.dart';

class QuizManagerScreen extends StatefulWidget {
  final List<int> completedSessionDetailIds;

  const QuizManagerScreen({
    super.key,
    required this.completedSessionDetailIds,
  });

  @override
  State<QuizManagerScreen> createState() => _QuizManagerScreenState();
}

class _QuizManagerScreenState extends State<QuizManagerScreen> {
  Future<QuizSession?>? _quizSessionFuture;
  int _currentQuizStep = 0;
  String? _jwtToken;
  bool _isCompletingStep = false;
  int _wrongAnswersCount = 0;
  static const int maxWrongAnswers = 1;
  List<int> _attemptedTestDetailIds = [];

  @override
  void initState() {
    super.initState();
    _attemptedTestDetailIds = [];
    _loadTokenAndFetchData();
  }

  Future<void> _loadTokenAndFetchData() async {
    setStateIfMounted(() {
      _quizSessionFuture = null;
      _currentQuizStep = 0;
      _isCompletingStep = false;
      _wrongAnswersCount = 0;
      _attemptedTestDetailIds = [];
    });
    final prefs = await SharedPreferences.getInstance();
    _jwtToken = prefs.getString('auth_token');
    if (!mounted) return;
    if (_jwtToken == null || _jwtToken!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView()));
      });
      setStateIfMounted(() => _quizSessionFuture = Future.error("Token required"));
    } else {
      _loadQuizData();
    }
  }

  void _loadQuizData() {
    if (_jwtToken == null) return;
    setStateIfMounted(() {
      _quizSessionFuture = ApiService.fetchNextTestDetail(_jwtToken!);
    });
  }

  void _handleIncorrectAnswerLocally() {
    setStateIfMounted(() => _wrongAnswersCount++);
    debugPrint("QuizManager: Incorrect answer processed. Total wrong answers: $_wrongAnswersCount");
  }

  Future<void> _completeQuizStep(QuizDetail detailToComplete, {bool wasCorrect = true}) async {
    if (_jwtToken == null || _isCompletingStep) return;
    setStateIfMounted(() => _isCompletingStep = true);

    if (!wasCorrect) {
      _handleIncorrectAnswerLocally();
    }

    int idToMark = detailToComplete.id;
    if (!_attemptedTestDetailIds.contains(idToMark) && idToMark > 0) {
        _attemptedTestDetailIds.add(idToMark);
        debugPrint("QuizManager: Added TEST detail ID $idToMark to _attemptedTestDetailIds. Current list: $_attemptedTestDetailIds");
    }

    if (_wrongAnswersCount > maxWrongAnswers) {
      debugPrint("QuizManager: Test failed due to too many wrong answers ($_wrongAnswersCount).");
      await _markRelevantDetailsAsNotCompleteOnFailure(); // <--- استدعاء الدالة المحدثة
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EndTestScreen(testPassed: false)));
      }
      setStateIfMounted(() => _isCompletingStep = false);
      return;
    }

    debugPrint("QuizManager: Completing Step ${_currentQuizStep + 1}. Sending TEST Item ID: $idToMark. Correct: $wasCorrect");
    if (idToMark <= 0) {
      debugPrint("QuizManager Error: Attempting to complete step with invalid TEST ID ($idToMark).");
      setStateIfMounted(() => _isCompletingStep = false);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ في بيانات الخطوة الحالية.')));
      return;
    }

    bool success = await ApiService.markTestDetailComplete(_jwtToken!, idToMark);
    if (!mounted) { _isCompletingStep = false; return; }

    if (success) {
      debugPrint("QuizManager: API complete for TEST detail ID $idToMark successful.");
      if (_currentQuizStep == 0) {
        setStateIfMounted(() { _currentQuizStep = 1; _isCompletingStep = false; });
      } else {
        debugPrint("QuizManager: Quiz finished successfully.");
        debugPrint("QuizManager: Original Session Detail IDs passed: ${widget.completedSessionDetailIds}");
        debugPrint("QuizManager: Attempted Test Detail IDs: $_attemptedTestDetailIds");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EndTestScreen(testPassed: true)));
      }
    } else {
      debugPrint("QuizManager: API complete failed for TEST detail ID $idToMark.");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ في حفظ التقدم.')));
      setStateIfMounted(() => _isCompletingStep = false);
    }
  }

  // ---!!! تعديل اسم الدالة ليعكس أنها تعالج كلا النوعين من التفاصيل !!!---
  Future<void> _markRelevantDetailsAsNotCompleteOnFailure() async {
    if (_jwtToken == null) {
      debugPrint("QuizManager: Cannot mark details as not complete. Token missing.");
      return;
    }

    bool allSessionMarkingSucceeded = true;
    bool allTestMarkingSucceeded = true;

    // 1. تعليم تفاصيل الجلسة الأصلية كـ "غير مكتملة"
    if (widget.completedSessionDetailIds.isNotEmpty) {
      debugPrint("QuizManager: Marking ORIGINAL session details as NOT complete. IDs: ${widget.completedSessionDetailIds}");
      for (int sessionDetailId in widget.completedSessionDetailIds) {
        if (sessionDetailId <= 0) continue;
        try {
          bool success = await ApiService.markSessionDetailAsNotComplete(_jwtToken!, sessionDetailId); // <--- استخدام الدالة الصحيحة
          if (!success) allSessionMarkingSucceeded = false;
        } catch (e) {
          debugPrint("QuizManager: Error marking original session detail ID $sessionDetailId as not complete: $e");
          allSessionMarkingSucceeded = false;
        }
      }
    }

    // 2. تعليم تفاصيل الاختبار التي تمت محاولتها كـ "غير مكتملة"
    if (_attemptedTestDetailIds.isNotEmpty) {
      debugPrint("QuizManager: Marking ATTEMPTED test details as NOT complete. IDs: $_attemptedTestDetailIds");
      for (int testDetailId in _attemptedTestDetailIds) {
        if (testDetailId <= 0) continue;
        try {
          // ---!!! استدعاء الدالة الجديدة الخاصة بتفاصيل الاختبار !!!---
          bool success = await ApiService.markTestDetailAsNotComplete(_jwtToken!, testDetailId);
          if (!success) allTestMarkingSucceeded = false;
        } catch (e) {
          debugPrint("QuizManager: Error marking attempted test detail ID $testDetailId as not complete: $e");
          allTestMarkingSucceeded = false;
        }
      }
    }

    if (allSessionMarkingSucceeded && allTestMarkingSucceeded) {
      debugPrint("QuizManager: All relevant details (session & test) successfully processed for NotComplete status.");
    } else {
      debugPrint("QuizManager: One or more details failed to be processed for NotComplete status.");
    }
  }


  void setStateIfMounted(VoidCallback fn) {
    if (mounted) setState(fn);
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
            if (snapshot.error.toString().contains("Token required")) errorMsg = "خطأ مصادقة.";
            else if (snapshot.error.toString().contains("Unauthorized")) {
              errorMsg = "انتهت صلاحية الدخول.";
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView()));
              });
            } else errorMsg += '\n(${snapshot.error})';
          }
          return ErrorDisplay(message: errorMsg, onRetry: _loadTokenAndFetchData);
        }

        final quizSession = snapshot.data!;

        if (_currentQuizStep == 0) {
          if (quizSession.details.isEmpty) return ErrorDisplay(message: "لا توجد بيانات للخطوة الأولى.", onRetry: _loadQuizData);
          final step1Detail = quizSession.details[0];
          return QuizType1Screen(
            key: const ValueKey('quiz_step_0'),
            detail: step1Detail,
            onAnswerSelected: (bool isCorrect) => _completeQuizStep(step1Detail, wasCorrect: isCorrect),
            isCompleting: _isCompletingStep,
          );
        } else {
          if (quizSession.details.length < 2 || quizSession.newDetail == null) {
            return ErrorDisplay(message: 'خطأ: بيانات الاختبار غير كافية للخطوة الثانية.', onRetry: _loadQuizData);
          }
          final option1 = quizSession.details[1];
          final option2 = quizSession.newDetail;
          return QuizType2Screen(
            key: const ValueKey('quiz_step_1'),
            rootQuestion: quizSession.question,
            option1Detail: option1,
            option2Detail: option2,
            rootAnswer: quizSession.answer,
            onAnswerSelected: (QuizDetail chosenDetail, bool isCorrect) => _completeQuizStep(chosenDetail, wasCorrect: isCorrect),
            isCompleting: _isCompletingStep,
          );
        }
      },
    );
  }
}