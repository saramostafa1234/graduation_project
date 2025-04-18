// lib/screens/training_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // لإضافة استيراد Timer و async

// --- استيراد الملفات الضرورية ---
import '../services/Api_services.dart'; // تأكد من المسار الصحيح لـ ApiService
// لا نحتاج لاستيراد SubmissionResult هنا لأننا نعرض بيانات الجلسات التدريبية
// لا نحتاج لاستيراد home_screen هنا إلا إذا كان هناك زر للعودة المباشرة

class TrainingPlanScreen extends StatefulWidget {
  // تعديل الـ constructor لاستخدام super parameters وإضافة const
  const TrainingPlanScreen({super.key});

  @override
  _TrainingPlanScreenState createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen> {
  List<dynamic> _trainingPlanSessions = []; // قائمة لتخزين الجلسات التدريبية المخصصة
  bool _isLoading = true;
  String? _errorMessage;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchTrainingPlan();
  }

  // --- قراءة التوكن وجلب الخطة ---
  Future<void> _loadTokenAndFetchTrainingPlan() async {
    // التأكد من أن الويدجت مازال موجوداً قبل البدء
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = null; }); // بدء التحميل

    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');

      if (!mounted) return; // تحقق بعد await

      if (_authToken == null || _authToken!.isEmpty) {
        setState(() { _isLoading = false; _errorMessage = "خطأ: رمز الدخول غير موجود."; });
        // يمكنك إضافة انتقال لشاشة اللوجن هنا
        // Future.delayed(Duration(seconds: 2), () {
        //   if(mounted) Navigator.pushReplacementNamed(context, PageRouteName.login);
        // });
        return;
      }
      await _fetchTrainingPlan(); // جلب الجلسات
    } catch (e) {
       print("Error loading token: $e");
       if (mounted) setState(() { _isLoading = false; _errorMessage = "خطأ في تحميل بيانات المصادقة."; });
    }
  }

  // --- جلب خطة التدريب المخصصة من الـ API ---
  Future<void> _fetchTrainingPlan() async {
    // التأكد من وجود التوكن قبل الاستدعاء
    if (_authToken == null || _authToken!.isEmpty) {
       print("Fetch skipped: Auth token is missing.");
       if (mounted) setState(() { _isLoading = false; _errorMessage = "خطأ: رمز الدخول غير موجود."; });
       return;
    }

    // إعادة تعيين الحالة قبل البدء بالطلب الجديد (خاصة عند التحديث)
    if (mounted) setState(() { _isLoading = true; _errorMessage = null; });

    try {
      print("Fetching training plan...");
      final result = await ApiService.getChildSessions(_authToken!); // استدعاء الدالة الصحيحة
      if (!mounted) return; // تحقق بعد await

      if (result['success'] && result['sessions'] != null && result['sessions'] is List) {
        setState(() {
          _trainingPlanSessions = result['sessions'];
          _isLoading = false;
          if (_trainingPlanSessions.isEmpty) {
            _errorMessage = "لا توجد جلسات تدريبية مخصصة لك حالياً.";
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? 'فشل في تحميل خطة التدريب.';
        });
      }
    } catch (e) {
      print("Error fetching training plan: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "حدث خطأ غير متوقع أثناء تحميل الخطة.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الخطة التدريبية'), // عنوان مناسب
        centerTitle: true,
        // يمكنك إضافة زر رجوع إذا لم تكن هذه الشاشة الأولى بعد اللوجن
        // leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
         backgroundColor: Colors.white,
         foregroundColor: Theme.of(context).primaryColor,
         elevation: 1,
      ),
      backgroundColor: Colors.grey[100], // خلفية متناسقة
      body: RefreshIndicator( // للسماح بالسحب للتحديث
        onRefresh: _fetchTrainingPlan, // استدعاء دالة الجلب عند السحب
        child: _buildBody(), // بناء المحتوى بناءً على الحالة
      ),
    );
  }

  // --- ويدجت لبناء محتوى الصفحة ---
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      // إضافة زر لإعادة المحاولة عند وجود خطأ
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 50),
                const SizedBox(height: 15),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _trainingPlanSessions.isEmpty ? Colors.grey.shade700 : Colors.red.shade700, fontSize: 16)
                ),
                const SizedBox(height: 20),
                 // لا نعرض زر إعادة المحاولة إذا كان الخطأ هو عدم وجود جلسات
                 if(!(_errorMessage == "لا توجد جلسات تدريبية مخصصة حالياً." || _errorMessage == "خطأ: رمز الدخول غير موجود."))
                   ElevatedButton.icon(
                      onPressed: _fetchTrainingPlan,
                      icon: const Icon(Icons.refresh),
                      label: const Text("إعادة المحاولة"),
                   )
             ],
          )
        )
      );
    }
    if (_trainingPlanSessions.isEmpty) {
      // رسالة أوضح لعدم وجود جلسات مع إمكانية التحديث
      return LayoutBuilder( // لتمكين RefreshIndicator حتى لو كانت القائمة فارغة
         builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
               constraints: BoxConstraints(minHeight: constraints.maxHeight),
               child: Center(child: Text("لا توجد جلسات تدريبية مخصصة حالياً.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16))),
            ),
         ),
       );
    }

    // --- عرض قائمة الجلسات ---
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // إضافة padding رأسي للقائمة
      itemCount: _trainingPlanSessions.length,
      itemBuilder: (context, index) {
        final session = _trainingPlanSessions[index];
        // --- استخراج البيانات بأمان ---
        final String title = session?['title'] ?? 'جلسة ${index + 1}';
        final String description = session?['description'] ?? 'لا يوجد وصف لهذه الجلسة.';
        final int sessionId = session?['session_ID_'] ?? -1;
        // يمكنك استخراج حقول أخرى مثل group_id, details, etc. هنا إذا احتجت إليها

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // تعديل الـ margin
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            leading: CircleAvatar(
              // استخدام لون مختلف قليلاً
              backgroundColor: Colors.teal.shade50,
              child: Text(
                '${index + 1}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade800),
              ),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Padding( // إضافة padding للنص الفرعي
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            ),
            trailing: const Icon(Icons.play_circle_outline_rounded, size: 28, color: Colors.teal), // تغيير الأيقونة
            onTap: () {
              // --- الإجراء عند الضغط على الجلسة ---
              print("Selected session ID: $sessionId, Title: $title");
              // هنا يمكنك الانتقال إلى شاشة بدء/تفاصيل الجلسة التدريبية الفعلية
              // مثال:
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => SessionPlayerScreen(sessionData: session), // شاشة افتراضية لتشغيل الجلسة
              //   ),
              // );
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text("تم اختيار الجلسة: $title"), duration: Duration(seconds: 1)),
               );
            },
          ),
        );
      },
    );
  } // نهاية buildBody
} // نهاية الكلاس