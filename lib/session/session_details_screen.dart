import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'models/session_model.dart'; // تأكد من المسار الصحيح لنموذج الجلسة
import '../services/Api_services.dart'; // تأكد من المسار الصحيح لخدمات API
import 'break.dart'; // تأكد من المسار الصحيح لشاشة الاستراحة
import 'timetest.dart'; // تأكد من المسار الصحيح لشاشة الاختبار
import 'dart:math'; // لاستخدام min و Random

//=============================================================================
// الشاشة الرئيسية لعرض تفاصيل وتمارين الجلسة
//=============================================================================
class SessionDetailsScreen extends StatefulWidget {
  final Session initialSession; // الجلسة المبدئية التي تم تمريرها للشاشة
  final String jwtToken; // توكن المصادقة للمستخدم

  const SessionDetailsScreen({
    super.key,
    required this.initialSession,
    required this.jwtToken,
  });

  @override
  _SessionDetailsScreenState createState() => _SessionDetailsScreenState();
}

//=============================================================================
// حالة الشاشة (State)
//=============================================================================
class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  // --- متغيرات الحالة ---
  late Session _currentSession; // نسخة من الجلسة قابلة للتعديل (إذا لزم الأمر مستقبلاً)
  int _currentStepIndex = 0; // مؤشر التمرين الحالي
  bool _isLoading = false; // لتحديد ما إذا كانت هناك عملية تحميل جارية (مثل استدعاء API)
  String? _errorMessage; // لتخزين رسائل الخطأ لعرضها للمستخدم
  Timer? _breakTimer; // مؤقت الاستراحة (غير مستخدم بشكل مباشر هنا ولكن يتم إلغاؤه في dispose)
  Timer? _stepTimer; // مؤقت عرض التمرين الحالي
  String? _randomObjectImagePath; // لتخزين مسار الصورة العشوائية للخطوة الأخيرة
  List<String> _objectImagePaths = []; // قائمة بمسارات الصور العشوائية المحتملة

  // --- الثوابت ---
  // المدد الزمنية (يمكن تعديلها للاختبار)
  static const Duration imageDisplayDuration = Duration(minutes: 7);
  static const Duration textDisplayDuration = Duration(minutes: 10);
  static const Duration breakDuration = Duration(seconds:30 );
  // static const Duration imageDisplayDuration = Duration(seconds: 15); // للاختبار
  // static const Duration textDisplayDuration = Duration(seconds: 10); // للاختبار
  // static const Duration breakDuration = Duration(seconds: 5);    // للاختبار

  static const String localImagePathBase = 'assets/'; // البادئة لمسارات الصور في مجلد assets
  static const String objectsFolderPath = 'assets/objects/'; // مسار مجلد الصور العشوائية

  // --- الألوان الثابتة المطلوبة ---
  static const Color screenBgColor = Color(0xFF2C73D9); // اللون الأزرق الأساسي للخلفية
  static const Color appBarElementsColor = Colors.white; // لون عناصر AppBar (نص، أيقونات)
  static const Color cardBgColor = Colors.white; // لون خلفية الكروت
  static const Color cardTextColor = Color(0xFF2C73D9); // لون النص داخل الكروت
  static const Color progressBarColor = Colors.white; // لون شريط التقدم
  static Color progressBarBgColor = Colors.white.withOpacity(0.3); // لون خلفية شريط التقدم
  static const Color buttonBgColor = Colors.white; // لون خلفية زر "التالي"
  static const Color buttonFgColor = Color(0xFF2C73D9); // لون نص وأيقونة زر "التالي"
  static const Color loadingIndicatorColor = Colors.white; // لون مؤشر التحميل العام
  static const Color errorTextColor = Colors.redAccent; // لون نص خطأ حفظ التقدم

  //=============================================================================
  // دورة حياة الويدجت (initState, dispose)
  //=============================================================================

  @override
  void initState() {
    super.initState();
    _currentSession = widget.initialSession;

    // تحقق مما إذا كانت الجلسة تحتوي على تمارين
    if (_currentSession.details.isEmpty) {
      _errorMessage = "لا توجد تمارين في هذه الجلسة.";
      // استخدم addPostFrameCallback لتحديث الحالة بعد اكتمال الإطار الأول
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      // إذا كانت هناك تمارين، ابدأ العملية
      print("--- Session Details Screen Initialized ---");
      print("Session Title: ${_currentSession.title}");
      print(
          "Exercise Count: ${_currentSession.details.length}"); // تم استخدام details.length
      print("New Detail available: ${_currentSession.newDetail != null}");
      _printSessionDetails(); // طباعة تفاصيل التمارين للمساعدة في التصحيح
      _loadObjectImagePaths(); // تحميل مسارات الصور العشوائية
      _startStepTimer(); // بدء مؤقت التمرين الأول
    }
  }

  @override
  void dispose() {
    _breakTimer?.cancel(); // إلغاء المؤقتات لمنع تسرب الذاكرة
    _stepTimer?.cancel();
    print("--- Session Details Screen Disposed ---");
    super.dispose();
  }

  // دالة مساعدة لتحديث الحالة بأمان (تتحقق من `mounted` أولاً)
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  //=============================================================================
  // الدوال المنطقية والخاصة بالتمارين
  //=============================================================================

  // طباعة تفاصيل التمارين المتاحة (للتصحيح)
  void _printSessionDetails() {
    print("--- Available Exercise Details (from details list) ---");
    for (int i = 0; i < _currentSession.details.length; i++) {
      final detail = _currentSession.details[i];
      final textSnippet =
          detail.text?.substring(0, min(detail.text?.length ?? 0, 50)) ??
              'null';
      print(
          "Exercise $i: ID=${detail.id}, Type=${detail.datatypeOfContent}, Image=${detail.hasImage}, Text=${detail.hasText}, Desc=${detail.hasDesc}"); // يشمل Desc
    }
    if (_currentSession.newDetail != null) {
      print(
          "--- New Detail Data: ID=${_currentSession.newDetail!.id}, Type=${_currentSession.newDetail!.datatypeOfContent}, Image=${_currentSession.newDetail!.hasImage}, Text=${_currentSession.newDetail!.hasText}, Desc=${_currentSession.newDetail!.hasDesc}"); // يشمل Desc
    } else {
      print("--- New Detail Data: Not Available ---");
    }
    print("------------------------------------------------------");
  }

  // تحميل مسارات الصور من مجلد الصور العشوائية
  Future<void> _loadObjectImagePaths() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      _objectImagePaths = manifestMap.keys
          .where((String key) =>
              key.startsWith(objectsFolderPath) && // تبدأ بالمسار المطلوب
              key != objectsFolderPath &&          // ليست المجلد نفسه
              (key.endsWith('.png') || // التأكد من أنها صورة (امتدادات شائعة)
                  key.endsWith('.jpg') ||
                  key.endsWith('.jpeg') ||
                  key.endsWith('.gif') ||
                  key.endsWith('.webp')))
          .toList();
      print("Loaded ${_objectImagePaths.length} images from $objectsFolderPath");
      if (_objectImagePaths.isEmpty) {
        print("Warning: No images found in $objectsFolderPath.");
      }
    } catch (e) {
      print("Error loading object image paths: $e");
      // يمكن تعيين رسالة خطأ هنا إذا كان تحميل الصور العشوائية ضروريًا
      // setStateIfMounted(() => _errorMessage = "خطأ في تحميل موارد الصور.");
    }
  }

  // اختيار صورة عشوائية من القائمة التي تم تحميلها
  void _selectRandomObjectImage() {
    if (_objectImagePaths.isNotEmpty) {
      final random = Random();
      _randomObjectImagePath =
          _objectImagePaths[random.nextInt(_objectImagePaths.length)];
      print("Selected random object image: $_randomObjectImagePath");
    } else {
      print("Warning: Cannot select random image, path list is empty.");
      _randomObjectImagePath = null; // ضمان أنها null إذا لم يتم العثور على صور
    }
  }

  // بدء مؤقت عرض التمرين الحالي
  void _startStepTimer() {
    _stepTimer?.cancel(); // ألغ المؤقت القديم إن وجد
    if (_currentSession.details.isEmpty ||
        _currentStepIndex >= _currentSession.details.length) {
      print("Cannot start step timer: No details or index out of bounds.");
      return;
    }

    final currentDetail = _currentSession.details[_currentStepIndex];
    Duration currentStepDuration;
    final contentType = currentDetail.datatypeOfContent?.toLowerCase();
    final bool isLastStep =
        _currentStepIndex == _currentSession.details.length - 1;

    // تحديد المدة بناءً على نوع المحتوى
    if (contentType == 'img' || currentDetail.hasImage) {
      currentStepDuration = imageDisplayDuration;
    } else { // افتراض النص إذا لم يكن صورة
      currentStepDuration = textDisplayDuration;
      if (contentType != 'text' && !currentDetail.hasText) {
        print(
            "Warning: Step ID ${currentDetail.id} has no text/image. Using text duration.");
      }
    }

    print(
        "Starting step timer for Step Index: $_currentStepIndex (ID: ${currentDetail.id}) - Duration: ${currentStepDuration.inSeconds} sec");

    // اختيار الصورة العشوائية *مقدماً* إذا كانت هذه هي الخطوة الأخيرة
    if (isLastStep) {
      _selectRandomObjectImage();
    }

    // بدء المؤقت الجديد
    _stepTimer = Timer(currentStepDuration, () {
      print("Step Timer Finished for Step Index: $_currentStepIndex.");
      if (mounted) {
        _goToNextStep(); // الانتقال للخطوة التالية عند انتهاء المؤقت
      }
    });
  }

  // استدعاء API لإعلام الخادم باكتمال التمرين الحالي
  Future<bool> _completeDetailApiCall(int detailId) async {
    setStateIfMounted(() {
      _isLoading = true; // إظهار مؤشر التحميل
      _errorMessage = null; // مسح أي رسالة خطأ سابقة
    });
    try {
      print("Attempting to complete detail ID: $detailId");
      bool success = await ApiService.completeDetail(widget.jwtToken, detailId);
      if (!mounted) return false; // التحقق بعد await
      if (success) {
        print("Successfully completed detail ID: $detailId");
      } else {
        print("Failed to complete detail ID: $detailId via API.");
        setStateIfMounted(() => _errorMessage = "فشل حفظ التقدم."); // عرض خطأ للمستخدم
      }
      return success;
    } catch (e) {
      print("Error completing detail $detailId: $e");
      if (mounted) {
        setStateIfMounted(() => _errorMessage = "خطأ في الاتصال بالخادم.");
      }
      return false;
    } finally {
      if (mounted) {
        setStateIfMounted(() => _isLoading = false); // إخفاء مؤشر التحميل
      }
    }
  }

  // الانتقال إلى التمرين التالي أو إنهاء الجلسة
  Future<void> _goToNextStep() async {
    if (_isLoading || _currentSession.details.isEmpty) return; // منع التنفيذ المتعدد أو إذا لا توجد تمارين
    if (_currentStepIndex >= _currentSession.details.length) return; // تأكد من أن المؤشر صالح

    _stepTimer?.cancel(); // إيقاف المؤقت الحالي فورًا
    _stepTimer = null;

    final currentDetailId = _currentSession.details[_currentStepIndex].id;
    bool success = await _completeDetailApiCall(currentDetailId); // إكمال التمرين الحالي عبر API

    if (!mounted) return; // التحقق بعد await

    if (success) {
      final nextIndex = _currentStepIndex + 1;
      final bool isSessionFinished = nextIndex >= _currentSession.details.length;

      print("API call for detail $currentDetailId successful. Starting break.");
      await _startBreakAndWait(); // الانتقال لشاشة الاستراحة والانتظار
      if (!mounted) return; // التحقق بعد العودة من الاستراحة

      if (isSessionFinished) {
        print("All session exercises completed! Navigating to StartTest.");
        Navigator.pop(context, true); // إغلاق الشاشة الحالية وإرجاع true (نجاح)
        // الانتقال لشاشة الاختبار واستبدال الشاشة الحالية
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StartTest()),
        );
      } else {
        print("Break finished. Moving to exercise index $nextIndex.");
        // الانتقال للخطوة التالية، مسح الخطأ، وبدء المؤقت الجديد
        setStateIfMounted(() {
          _currentStepIndex = nextIndex;
          _errorMessage = null;
        });
        _startStepTimer();
      }
    } else {
      // فشل استدعاء API، ابق في نفس الخطوة واعرض الخطأ (تم تعيينه في _completeDetailApiCall)
      print("API call for detail $currentDetailId failed. Staying on current step.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'فشل حفظ التقدم.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // الانتقال إلى شاشة الاستراحة والانتظار حتى تنتهي
  Future<void> _startBreakAndWait() async {
    print("Navigating to BreakScreen for $breakDuration...");
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BreakScreen(duration: breakDuration),
        fullscreenDialog: true, // يمنع الإغلاق بالسحب لأسفل
      ),
    );
    print("Returned from BreakScreen.");
  }

  //=============================================================================
  // بناء واجهات المحتوى (التمارين)
  //=============================================================================

  // بناء المحتوى الرئيسي (يحدد أي واجهة فرعية ستُعرض)
  Widget _buildStepContent() {
    if (_currentStepIndex >= _currentSession.details.length) {
      print("Error: _buildStepContent called with invalid index $_currentStepIndex");
      return _buildGenericErrorWidget("خطأ في عرض التمرين.");
    }

    final currentDetail = _currentSession.details[_currentStepIndex];
    final int totalSteps = _currentSession.details.length;
    final bool isLastStep = _currentStepIndex == totalSteps - 1;
    final bool isSecondToLastStep = _currentStepIndex == totalSteps - 2;

    print("--- Building Content for Step Index: $_currentStepIndex (ID: ${currentDetail.id}) ---");

    bool displayDoubleImage = false;
    String? imagePath1; String? imagePath2;
    String? text1 = currentDetail.text; String? text2;
    String? desc1 = currentDetail.desc; String? desc2; // متغيرات الوصف

    // الحالة 1: الخطوة قبل الأخيرة مع صورتين (الحالي + الجديد)
    if (isSecondToLastStep &&
        currentDetail.hasImage &&
        _currentSession.newDetail?.hasImage == true) {
      print("State: Second to last step - Double Image (Main + NewDetail).");
      displayDoubleImage = true;
      imagePath1 = localImagePathBase + currentDetail.image!;
      imagePath2 = localImagePathBase + _currentSession.newDetail!.image!;
      text2 = _currentSession.newDetail!.text;
      desc2 = _currentSession.newDetail!.desc; // احصل على الوصف الثاني
    }
    // الحالة 2: الخطوة الأخيرة مع صورتين (الحالي + عشوائي)
    else if (isLastStep &&
        currentDetail.hasImage &&
        _randomObjectImagePath != null) {
      print("State: Last step - Double Image (Main + Random Object).");
      displayDoubleImage = true;
      imagePath1 = localImagePathBase + currentDetail.image!;
      imagePath2 = _randomObjectImagePath; // المسار كامل بالفعل
      text2 = null;
      desc2 = null; // لا يوجد وصف للصورة العشوائية عادةً
    }

    // بناء الواجهة بناءً على الحالة
    Widget contentWidget;
    if (displayDoubleImage) {
      print("Building Double Image Widget. Img1: $imagePath1, Img2: $imagePath2");
      contentWidget = _buildDoubleImageWidget(imagePath1!, imagePath2!, text1, text2, desc1, desc2); // تمرير الأوصاف
    } else if (currentDetail.hasImage) {
      print("Building Single Image Widget.");
      final fullImagePath = localImagePathBase + currentDetail.image!;
      contentWidget = _buildSingleImageWidget(fullImagePath, text1, desc1); // تمرير الوصف
    } else if (currentDetail.hasText) {
      print("Building Single Text Widget.");
      contentWidget = _buildSingleTextWidget(text1!);
    } else {
      print("Warning: Unsupported/Empty content for Step Index: $_currentStepIndex");
      contentWidget = _buildGenericErrorWidget('لا يوجد محتوى لهذه الخطوة (ID: ${currentDetail.id})');
    }

    // توسيط المحتوى والسماح بالتمرير
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: contentWidget,
      ),
    );
  }

  // بناء واجهة الصورة الواحدة (مع النص والوصف الاختياري)
  Widget _buildSingleImageWidget(String imagePath, String? text, String? desc) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      color: cardBgColor, // خلفية الكارت بيضاء
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الصورة
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print("Error loading single image asset: $imagePath - $error");
                  return _buildImageErrorWidget(imagePath);
                },
              ),
            ),
          ),
          // النص الرئيسي (إذا وجد)
          if (text != null && text.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                left: 16.0, right: 16.0,
                bottom: (desc != null && desc.isNotEmpty) ? 4.0 : 16.0, // تباعد سفلي مشروط
                top: 4.0,
              ),
              child: Text( text, textAlign: TextAlign.center,
                style: const TextStyle( fontSize: 19, color: cardTextColor, fontWeight: FontWeight.w500, fontFamily: 'cairo', height: 1.4),
              ),
            ),
          // الوصف (إذا وجد)
          if (desc != null && desc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only( left: 16.0, right: 16.0, bottom: 20.0, top: 4.0,),
              child: Text( desc, textAlign: TextAlign.center,
                style: TextStyle( fontSize: 16, color: cardTextColor.withOpacity(0.85), fontFamily: 'cairo', fontWeight: FontWeight.normal, height: 1.3),
              ),
            ),
        ],
      ),
    );
  }

  // بناء واجهة النص الواحد
  Widget _buildSingleTextWidget(String text) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      color: cardBgColor, // خلفية الكارت بيضاء
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 25.0),
        child: Text( text, textAlign: TextAlign.center,
          style: const TextStyle( fontSize: 20, color: cardTextColor, fontWeight: FontWeight.w500, fontFamily: 'cairo', height: 1.6),
        ),
      ),
    );
  }

  // بناء واجهة الصورتين (مع النصوص والأوصاف الاختيارية)
  Widget _buildDoubleImageWidget(String imagePath1, String imagePath2,
      String? text1, String? text2, String? desc1, String? desc2) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // الكارت الأول
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          color: cardBgColor, // أبيض
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الصورة الأولى
              Padding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, (text1 != null && text1.isNotEmpty || desc1 != null && desc1.isNotEmpty) ? 8 : 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset( imagePath1, fit: BoxFit.contain,
                    errorBuilder: (ctx, e, s) => _buildImageErrorWidget(imagePath1),),
                ),
              ),
              // النص الأول
              if(text1 != null && text1.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: (desc1 != null && desc1.isNotEmpty) ? 4.0 : 12.0, left: 12.0, right: 12.0),
                  child: Text(text1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, color: cardTextColor, fontFamily: 'cairo', height: 1.3)),
                ),
              // الوصف الأول
              if(desc1 != null && desc1.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 12.0, right: 12.0, top: 2.0),
                  child: Text( desc1, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: cardTextColor.withOpacity(0.85), fontFamily: 'cairo', fontWeight: FontWeight.normal, height: 1.2)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 15), // فاصل
        // الكارت الثاني
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          color: cardBgColor, // أبيض
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الصورة الثانية
              Padding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, (text2 != null && text2.isNotEmpty || desc2 != null && desc2.isNotEmpty) ? 8 : 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset( imagePath2, fit: BoxFit.contain,
                    errorBuilder: (ctx, e, s) {
                      bool isRandom = imagePath2 == _randomObjectImagePath;
                      return _buildImageErrorWidget(isRandom ? "صورة عشوائية ($imagePath2)" : imagePath2);
                    },
                  ),
                ),
              ),
              // النص الثاني
              if(text2 != null && text2.isNotEmpty)
                Padding(
                   padding: EdgeInsets.only(bottom: (desc2 != null && desc2.isNotEmpty) ? 4.0 : 12.0, left: 12.0, right: 12.0),
                  child: Text(text2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, color: cardTextColor, fontFamily: 'cairo', height: 1.3)),
                ),
              // الوصف الثاني
              if(desc2 != null && desc2.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 12.0, right: 12.0, top: 2.0),
                  child: Text( desc2, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: cardTextColor.withOpacity(0.85), fontFamily: 'cairo', fontWeight: FontWeight.normal, height: 1.2)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  //=============================================================================
  // بناء واجهات مساعدة (للأخطاء)
  //=============================================================================

  // ويدجت لعرض خطأ تحميل صورة
  Widget _buildImageErrorWidget(String? attemptedPath) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.red.shade50, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column( mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.broken_image_outlined, size: 40, color: Colors.redAccent),
          const SizedBox(height: 10),
          const Text('خطأ في تحميل الصورة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
          const SizedBox(height: 6),
          Text('(المسار: ${attemptedPath ?? "غير متوفر"})', textDirection: TextDirection.ltr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 10)),
      ],),
    );
  }

  // ويدجت لعرض خطأ عام أو تحذير
  Widget _buildGenericErrorWidget(String message) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.orange.shade50, borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column( mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.warning_amber_rounded, size: 45, color: Colors.orangeAccent),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
      ],),
    );
  }

  //=============================================================================
  // بناء الواجهة الرئيسية للشاشة (build method)
  //=============================================================================
  @override
  Widget build(BuildContext context) {
    print("Building UI with fixed colors: Screen BG=$screenBgColor, AppBar Elements=$appBarElementsColor");

    // --- تحديد محتوى الـ body ---
    Widget bodyContent;

    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator(color: loadingIndicatorColor)); // مؤشر تحميل أبيض
    } else if (_errorMessage != null && _currentSession.details.isEmpty) {
      // خطأ عام يمنع عرض التمارين
      bodyContent = Center(child: _buildGenericErrorWidget(_errorMessage!));
    } else if (_currentSession.details.isEmpty) {
       // لا توجد تمارين ولكن لا يوجد خطأ تحميل
      bodyContent = Center(child: _buildGenericErrorWidget("لا توجد تمارين متاحة في هذه الجلسة حاليًا."));
    } else if (_currentStepIndex >= _currentSession.details.length) {
      // حالة غير متوقعة (اكتمل أو خطأ في المؤشر)
      bodyContent = Center(child: _buildGenericErrorWidget("اكتملت التمارين أو حدث خطأ غير متوقع."));
    } else {
      // --- بناء الواجهة الطبيعية (تمارين) ---
      bodyContent = Column(
        children: [
          // --- شريط التقدم ---
          if (_currentSession.details.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentStepIndex + 1) / _currentSession.details.length,
                  minHeight: 10,
                  backgroundColor: progressBarBgColor, // خلفية شريط التقدم (أبيض شفاف)
                  valueColor: const AlwaysStoppedAnimation<Color>(progressBarColor), // لون التقدم (أبيض)
                ),
              ),
            ),

          // --- محتوى التمرين (الكارت) ---
          Expanded(
            child: _buildStepContent(), // هنا سيتم بناء الكارت الأبيض بالمحتوى الأزرق
          ),

          // --- رسالة الخطأ أو زر "التالي" ---
          _errorMessage != null && _errorMessage!.contains('فشل حفظ التقدم')
              ? Padding( // رسالة خطأ خاصة بحفظ التقدم
                  padding: const EdgeInsets.all(20.0),
                  child: Text( _errorMessage!,
                    style: const TextStyle( color: errorTextColor, fontWeight: FontWeight.bold), // لون أحمر فاتح
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding( // زر "التالي"
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 25.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () { // تعطيل الزر أثناء التحميل
                              print("Next button pressed.");
                              _stepTimer?.cancel(); // أوقف المؤقت فور الضغط
                              _goToNextStep();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonBgColor, // خلفية الزر بيضاء
                        foregroundColor: buttonFgColor, // لون النص والأيقونة أزرق
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle( fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'cairo'),
                        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(30.0)),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.2),
                        disabledBackgroundColor: buttonBgColor.withOpacity(0.7), // لون معطل
                        disabledForegroundColor: buttonFgColor.withOpacity(0.5), // لون معطل
                      ),
                      child: _isLoading
                          ? const SizedBox( // مؤشر تحميل داخل الزر
                              height: 24, width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(buttonFgColor), // أزرق
                              ),
                            )
                          : const Text('التالي'),
                    ),
                  ),
                ),
        ],
      );
    }

    // --- بناء الـ Scaffold النهائي ---
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: screenBgColor, // خلفية الشاشة زرقاء دائمًا
        appBar: AppBar(
          title: Text( _currentSession.title ?? 'تمارين الجلسة',
            style: const TextStyle( color: appBarElementsColor, fontWeight: FontWeight.bold, fontFamily: 'cairo'), // نص AppBar أبيض
          ),
          backgroundColor: screenBgColor, // خلفية AppBar زرقاء
          elevation: 0, // بدون ظل
          iconTheme: const IconThemeData(color: appBarElementsColor), // أيقونات AppBar بيضاء
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 24, color: appBarElementsColor), // أيقونة الرجوع بيضاء
            tooltip: 'العودة',
            onPressed: () {
              print("Back button pressed. Popping context with 'false'.");
              Navigator.pop(context, false); // إرجاع false عند الضغط على الرجوع
            },
          ),
        ),
        body: bodyContent, // عرض المحتوى المحدد
      ),
    );
  }
} // نهاية الكلاس _SessionDetailsScreenState