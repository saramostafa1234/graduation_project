// lib/screens/assessment_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
// import 'dart:convert'; // غير مستخدم حالياً هنا

// --- استيراد الملفات الضرورية ---
import '../models/question_model.dart';
import 'assessment_data.dart'; // تأكد من وجود المتغير assessmentQuestions هنا
import '../services/Api_services.dart';     // تأكد من وجود الكلاس والدوال
import 'home_screen.dart';
// لا نحتاج لاستيراد النماذج أو شاشة النتائج إذا كنا ننتقل للهوم
// import 'assessment_results_screen.dart';
// import '../models/submission_result.dart';

// --- نموذج لتمثيل رسالة في الشات ---
// (يُفضل نقله لملف models إذا لم يكن هناك)
class ChatMessage {
  final String text;
  final bool isUserMessage;
  final Question? questionData;

  ChatMessage({required this.text, required this.isUserMessage, this.questionData});
}

// --- الشاشة الرئيسية للتقييم ---
class AssessmentScreen extends StatefulWidget {
  final String jwtToken;
  const AssessmentScreen({super.key, required this.jwtToken});

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _skipActive = false;
  String? _emotionToSkip;
  // تم جعل _isSessionComplete قابلة للتغيير
  bool _isSessionComplete = false;

  final List<ChatMessage> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  // --- (تم التعليق على قائمة النتائج لأننا ننتقل للهوم) ---
  // final List<SubmissionResult> _submissionResults = [];

  @override
  void initState() {
    super.initState();
    // التأكد من وجود الأسئلة قبل البدء
    if (assessmentQuestions.isNotEmpty) {
      _startChatFlow();
    } else {
      // التعامل مع الحالة النادرة لعدم وجود أسئلة
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if(mounted){ setState(() { _errorMessage = "خطأ: لم يتم تحميل أسئلة التقييم."; _isLoading = false; }); }
       });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  // --- بدء تدفق المحادثة بالرسالة الترحيبية ---
  void _startChatFlow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _chatMessages.add(ChatMessage(
            text: "أهلاً بكِ. سأطرح عليكِ بعض الأسئلة حول ملاحظاتك لطفلك. يرجى الإجابة بنص حر أو استخدام الأزرار المقترحة.",
            isUserMessage: false,
          ));
        });
        _scrollToBottom();
        // طرح أول سؤال بعد تأخير بسيط
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) { _askQuestionAtIndex(_currentIndex); } // استدعاء دالة عرض السؤال
        });
      }
    });
  }

  // --- دالة لعرض السؤال في الشات (بدلاً من askFirstQuestion و displayNextBotQuestion) ---
  void _askQuestionAtIndex(int index) {
     if (index < assessmentQuestions.length && mounted) {
       final question = assessmentQuestions[index];
        // تأخير بسيط قبل عرض سؤال البوت
        Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
               setState(() {
                  _chatMessages.add(ChatMessage(
                     text: question.text,
                     isUserMessage: false,
                     questionData: question,
                  ));
               });
               _scrollToBottom();
            }
        });
     } else if (mounted && index >= assessmentQuestions.length && !_isSessionComplete) {
       // اكتملت كل الأسئلة ولم يتم استدعاء الإنهاء بعد
       _completeAndGoHome();
     } else if (mounted) {
        // حالة غير متوقعة أو القائمة فارغة
        setState(() { _errorMessage = "لا يمكن عرض السؤال التالي."; });
     }
  }


  // --- دالة لعرض شرح السؤال ---
    // --- دالة لعرض شرح السؤال (معدلة لدعم RTL بشكل أفضل) ---
  void _showExplanation(String? explanation) {
    if (explanation == null || explanation.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لا يوجد شرح إضافي لهذا السؤال."), duration: Duration(seconds: 2)),);
      return;
    }
    _answerFocusNode.unfocus();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      backgroundColor: Colors.white,
      builder: (context) {
        // --- استخدام Directionality لضمان اتجاه RTL للـ BottomSheet ---
        return Directionality(
          textDirection: TextDirection.rtl, // <--- تحديد الاتجاه هنا
          child: Padding(
             padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
             child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // محاذاة كل العناصر لليمين (بداية السطر في RTL)
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- العنوان ---
                    Row( // الصف يبقى كما هو لكن المحتوى داخله سيتبع Directionality
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: Theme.of(context).primaryColor, size: 28),
                        const SizedBox(width: 10),
                         // استخدام const للنص الثابت
                        Text("توضيح السؤال:", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 25, thickness: 0.8),
                    // --- نص الشرح ---
                    Text(
                        explanation,
                        // textAlign: TextAlign.start يضمن المحاذاة لليمين في RTL
                        textAlign: TextAlign.start,
                        style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                    ),
                    const SizedBox(height: 25),
                    // --- زر الإغلاق ---
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                        // استخدام const للنص الثابت
                        child: const Text("حسناً"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                     const SizedBox(height: 10),
                  ],
                ),
             ),
          ),
        );
      },
    );
  }

  // --- معالجة الإجابة (من زر اقتراح أو زر إرسال) ---
  Future<void> _handleAnswer(String answerText) async {
    final trimmedAnswer = answerText.trim();
    if (trimmedAnswer.isEmpty || _isLoading || _isSessionComplete || _currentIndex >= assessmentQuestions.length) return; // إضافة تحقق إضافي

    _answerFocusNode.unfocus();
    final currentQuestion = assessmentQuestions[_currentIndex]; // السؤال الحالي
    String rawAnswerForDisplay = trimmedAnswer;

    // 1. التحقق من طلب الشرح
    const List<String> explanationRequests = [ "مش فاهمة", "مش فاهمه", "يعنى ايه", "يعني ايه", "يعني إيه", "ايه المقصود", "إيه المقصود", "ماذا يعني", "اشرح", "شرح", "توضيح", "?", "مش فاهم", "ماذا افعل", "ماذا أفعل" ];
    final lowerCaseAnswer = trimmedAnswer.toLowerCase();
    bool needsExplanation = explanationRequests.any((request) => lowerCaseAnswer.contains(request));

    if (needsExplanation) {
      print("User requested explanation for Q:${currentQuestion.id}");
      _showExplanation(currentQuestion.explanation);
      _answerController.clear();
      return; // توقف هنا
    }

    // 2. إضافة رسالة المستخدم وبدء التحميل
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = null; _chatMessages.add(ChatMessage(text: rawAnswerForDisplay, isUserMessage: true)); _answerController.clear(); });
    _scrollToBottom();

    // 3. تحديد الإجابة المصنفة
    String? classifiedAnswer;
    const validKeywords = ["نعم", "لا", "بمساعدة"];
    if (validKeywords.contains(trimmedAnswer)) {
      classifiedAnswer = trimmedAnswer;
    } else {
      classifiedAnswer = await ApiService.classifyAnswerWithModel(trimmedAnswer);
    }

    if (!mounted) return;

    // 4. معالجة نتيجة التصنيف
    if (classifiedAnswer == null) { // يشمل فشل المودل أو عدم وجود الكلمة المفتاحية
       setState(() { _errorMessage = "لم يتم تحليل الإجابة. حاول مرة أخرى أو استخدم الاقتراحات."; _isLoading = false; if (_chatMessages.isNotEmpty && _chatMessages.last.isUserMessage) { _chatMessages.removeLast(); } });
       return;
    }

    // 5. تفعيل التخطي
    if (currentQuestion.dimension == "فهم" && classifiedAnswer == "لا") { _skipActive = true; _emotionToSkip = currentQuestion.emotion; }

    // 6. إرسال للباك اند
    bool backendSuccess = await ApiService.submitAssessmentAnswer(currentQuestion.id, classifiedAnswer, widget.jwtToken);

    // --- (تم التعليق على تخزين النتيجة التفصيلية) ---
    // _submissionResults.add(SubmissionResult( ... ));

    if (!mounted) return;

    // 7. التعامل مع نتيجة الباك اند والانتقال
    if (backendSuccess) {
      _moveToNextQuestionOrComplete();
    } else {
      setState(() { _errorMessage = "خطأ في إرسال الإجابة."; _isLoading = false; if (_chatMessages.isNotEmpty && _chatMessages.last.isUserMessage) { _chatMessages.removeLast(); } });
    }
     if (mounted && _isLoading && !backendSuccess) { setState(() { _isLoading = false; }); }
  }


  // --- الانتقال للسؤال التالي أو إنهاء الجلسة (مع إدارة التخطي) ---
  Future<void> _moveToNextQuestionOrComplete() async {
    // إيقاف التحميل قبل البدء بالمنطق التالي
    if (mounted && _isLoading) { setState(() { _isLoading = false; }); }

    int nextIndex = _currentIndex + 1; // ابدأ بالتحقق من السؤال التالي مباشرة
    bool errorDuringSkip = false;

    while (nextIndex < assessmentQuestions.length) {
      final nextQuestion = assessmentQuestions[nextIndex];
      if (_skipActive && nextQuestion.emotion == _emotionToSkip) {
        print("[Auto-Skipping] Q:${nextQuestion.id}...");
        bool skipBackendSuccess = await ApiService.submitAssessmentAnswer(nextQuestion.id, "لا", widget.jwtToken);
        // --- (التعليق على تخزين نتيجة التخطي التفصيلية) ---
        // _submissionResults.add(SubmissionResult( ... ));
        if (!mounted) return;
        if (!skipBackendSuccess) { errorDuringSkip = true; if (mounted) setState(() { _errorMessage = "خطأ بتحديث سؤال متخطى (${nextQuestion.id})."; }); break; }
        nextIndex++; // استمر للسؤال التالي في الحلقة
      } else {
        // هذا السؤال لا يجب تخطيه
        if (nextQuestion.emotion != _emotionToSkip && _skipActive) { print("[Skip Logic Deactivated]"); _skipActive = false; _emotionToSkip = null; }
        break; // اخرج من الحلقة لعرض هذا السؤال
      }
    }

    // توقف إذا حدث خطأ أثناء معالجة التخطي
    if (errorDuringSkip) { if (mounted) setState(() { _isLoading = false; }); return; }

    // بعد الخروج من الحلقة، حدد الخطوة التالية
    if (nextIndex >= assessmentQuestions.length) {
      _completeAndGoHome(); // اكتملت كل الأسئلة
    } else {
      // هناك سؤال تالٍ لعرضه
      if (mounted) {
        setState(() { _currentIndex = nextIndex; _errorMessage = null; }); // حدث المؤشر
        _askQuestionAtIndex(_currentIndex); // اعرض السؤال الجديد في الشات
      }
    }
  }

  // --- الانتقال إلى HomeScreen بعد الاكتمال ---
  void _completeAndGoHome() {
     if(mounted && !_isSessionComplete){ // تحقق إضافي لمنع الاستدعاء المتعدد
         setState(() { _isSessionComplete = true; _isLoading = false; });
         print("Assessment completed. Navigating to HomeScreen.");
         Future.delayed(const Duration(milliseconds: 1200), () { // تأخير لعرض آخر رسالة
            if (mounted) {
               Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
            }
         });
      }
  }

  // --- التمرير لأسفل ---
   // داخل الكلاس _AssessmentScreenState في ملف assessment_screen.dart

// --- التمرير لأسفل ---
void _scrollToBottom() {
  // التأكد أولاً أن الويدجت ما زال موجوداً في الشجرة
  if (!mounted) {
    return;
  }

  // جدولة عملية التمرير لتحدث بعد اكتمال بناء الإطار الحالي
  // هذا يضمن أن حجم الـ ListView محدّث ويشمل الرسالة الجديدة
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // التأكد مرة أخرى من وجود الويدجت ومن أن الـ ScrollController مرتبط بـ ListView
    if (mounted && _scrollController.hasClients) {
      // استخدام animateTo لتمرير سلس لأسفل القائمة
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, // الانتقال إلى أقصى نقطة يمكن التمرير إليها (الأسفل)
        duration: const Duration(milliseconds: 300), // مدة الأنيميشن (يمكن تعديلها)
        curve: Curves.easeOut, // نوع منحنى الحركة للأنيميشن (يمكن تعديله)
      );

      /* 
      // بديل: استخدام jumpTo للانتقال الفوري بدون أنيميشن (إذا كنت تفضل ذلك)
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent); 
      */
    }
  });
}

  @override
  Widget build(BuildContext context) {
    // --- (تم حذف isIndexValid و currentQuestionData غير المستخدمين) ---

    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar( title: const Text('لنتحدث عن طفلك'), backgroundColor: Colors.white, foregroundColor: const Color(0xFF2C73D9), elevation: 1, centerTitle: true, automaticallyImplyLeading: false,),
      //backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          // --- منطقة عرض المحادثة ---
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10.0),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                final color = message.isUserMessage ? const Color(0xFF2C73D9) : Colors.white;
                final textColor = message.isUserMessage ? Colors.white : Colors.black87;
                final borderRadius = message.isUserMessage ? const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topRight: Radius.circular(5)) : const BorderRadius.only(topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topLeft: Radius.circular(5));
                // --- بناء الـ Row لكل رسالة ---
                return Container( margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row( mainAxisAlignment: message.isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!message.isUserMessage) const Padding( padding: EdgeInsets.only(right: 8.0, bottom: 5), child: CircleAvatar(backgroundColor: Color(0xFF2C73D9), radius: 15, child: Icon(Icons.adb, color: Colors.white, size: 18)), ),
                      Flexible(child: Container( constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75), padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0), decoration: BoxDecoration( color: color, borderRadius: borderRadius, boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.15), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2)) ] ), child: Text( message.text, textDirection: TextDirection.rtl, style: TextStyle(color: textColor, fontSize: 15, height: 1.4),), ), ),
                      // --- إزالة أيقونة الشرح من هنا ---
                      if (message.isUserMessage) const SizedBox(width: 40),
                    ],
                  ),
                );
              },
            ),
          ),

          // --- منطقة الإدخال أو رسالة الاكتمال ---
          if (!_isSessionComplete)
            Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5, offset: const Offset(0,-2))]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0).copyWith(bottom: MediaQuery.of(context).padding.bottom + 8),
                child: Column( mainAxisSize: MainAxisSize.min, children: [
                    Padding( padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8), child: Row( children: [ Expanded(child: _buildSuggestionButton("نعم")), const SizedBox(width: 8), Expanded(child: _buildSuggestionButton("لا")), const SizedBox(width: 8), Expanded(child: _buildSuggestionButton("بمساعدة")), ],),),
                    if (_errorMessage != null) Padding( padding: const EdgeInsets.only(bottom: 8.0), child: Text( _errorMessage!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center,),),
                    Row( crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Expanded( child: Container( padding: const EdgeInsets.symmetric(horizontal: 5), decoration: BoxDecoration( color: Colors.grey.shade100, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.shade300)),
                            child: TextField( controller: _answerController, focusNode: _answerFocusNode, textDirection: TextDirection.rtl, textAlign: TextAlign.right, keyboardType: TextInputType.multiline, minLines: 1, maxLines: 4, textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration( hintText: _isLoading ? "جاري المعالجة..." : "...أو اكتب إجابتك هنا", hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), isDense: true,),
                              enabled: !_isLoading, onSubmitted: _isLoading ? null : (value) => _handleAnswer(value.trim()),
                            ),),),
                        const SizedBox(width: 8),
                        FloatingActionButton( mini: true, onPressed: _isLoading ? null : () => _handleAnswer(_answerController.text.trim()),
                          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Icon(Icons.send),
                          backgroundColor: _isLoading ? Colors.grey : const Color(0xFF2C73D9), elevation: 2,),
                      ],
                    ),],),
              ),
            )
           else // رسالة اكتمال بسيطة قبل الانتقال
              Container( color: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20).copyWith(bottom: MediaQuery.of(context).padding.bottom + 20), child: const Center(child: Text("اكتمل التقييم، شكراً لكِ.", style: TextStyle(color: Colors.grey))) ),
        ],
      ),
    );
  }

  // --- ويدجت مساعد لبناء أزرار الاقتراحات ---
  Widget _buildSuggestionButton(String text) {
    return OutlinedButton(
      onPressed: _isLoading ? null : () => _handleAnswer(text), // استدعاء المعالج مباشرة
      child: Text(text),
      style: OutlinedButton.styleFrom( foregroundColor: Theme.of(context).primaryColor, side: BorderSide(color: Theme.of(context).primaryColor.withAlpha(100)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), textStyle: const TextStyle(fontSize: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    );
  }

} // نهاية الكلاس _AssessmentScreenState