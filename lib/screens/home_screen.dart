// import 'dart:async';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:myfinalpro/screens/skills.dart';
// import 'package:myfinalpro/screens/test1.dart';
// import 'package:myfinalpro/screens/timetest.dart';
// import 'package:myfinalpro/session/seesion.dart';
//
// import '../widget/custom_drawer.dart';
// import '../widgets/Notifictionicon.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'emotion.dart';
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   bool isSessionAvailable = false;
//   Duration remainingTime = Duration.zero;
//   Timer? timer;
//   double emotionProgress = 0.5;
//   double skillsProgress = 0.9;
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   @override
//   void initState() {
//     super.initState();
//     _loadSessionData();
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _loadSessionData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastSessionTime = prefs.getInt('lastSessionTime') ?? 0;
//     final currentTime = DateTime.now().millisecondsSinceEpoch;
//     final sessionCooldown = 48 * 60 * 60 * 1000; // 48 ساعة بالمللي ثانية
//
//     if (currentTime - lastSessionTime >= sessionCooldown) {
//       setState(() {
//         isSessionAvailable = true;
//         remainingTime = Duration.zero;
//       });
//     } else {
//       setState(() {
//         isSessionAvailable = false;
//         remainingTime = Duration(
//             milliseconds: sessionCooldown - (currentTime - lastSessionTime));
//       });
//
//       timer = Timer.periodic(Duration(seconds: 1), (timer) {
//         if (remainingTime.inSeconds > 0) {
//           setState(() {
//             remainingTime = remainingTime - Duration(seconds: 1);
//           });
//         } else {
//           setState(() {
//             isSessionAvailable = true;
//             timer.cancel();
//           });
//         }
//       });
//     }
//   }
//
//   String formatDuration(Duration duration) {
//     int hours = duration.inHours;
//     int minutes = (duration.inMinutes % 60);
//     int seconds = (duration.inSeconds % 60);
//
//     return '\u202E${_convertToArabicNumbers(seconds)} : ${_convertToArabicNumbers(minutes)} : ${_convertToArabicNumbers(hours)}';
//   }
//
//   String _convertToArabicNumbers(int number) {
//     const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
//     return number
//         .toString()
//         .split('')
//         .map((digit) => arabicNumbers[int.parse(digit)])
//         .join('');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final double circleSize = screenWidth * 0.4;
//     final double editIconSize = circleSize * 0.3;
//
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         key: scaffoldKey,
//         backgroundColor: Colors.white,
//         endDrawer
//             : CustomDrawer(),
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: Builder(
//             builder: (context) => Padding(
//               padding: const EdgeInsets.only(left: 16.0, top: 16),
//               /*child: IconButton(
//                 // ✅ النوتفكيشن على اليمين
//                 icon: Icon(Icons.notifications, color: Color(0xff2C73D9)),
//                  onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => NotificationsScreen()),
//     );
//   },
//               ),*/
//               child: NotificationIcon(),
//             ),
//           ),
//           actions: [
//             IconButton(
//               // ✅ المنيو على اليسار وتفتح السايد بار
//               icon: Padding(
//                 padding: const EdgeInsets.only(right: 32.0, top: 20),
//                 child: Icon(
//                   Icons.menu,
//                   color: Color(0xff2C73D9),
//                   size: 32,
//                 ),
//               ),
//               onPressed: () {
//                 scaffoldKey.currentState
//                     ?.openEndDrawer(); // فتح السايد بار عند الضغط
//               },
//             ),
//           ],
//         ),
//
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.only(left: 10, right: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               //SizedBox(height: 16,),
//               Center(
//                   child: Text('مرحبا !',
//                       style: TextStyle(
//                           fontSize: 28,
//                           color: Color(0xff2C73D9),
//                           fontWeight: FontWeight.bold))),
//               SizedBox(height: 20),
//               Container(
//                 width: double.infinity,
//                 //height: 130,
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                     color: Color(0xff2C73D9),
//                     borderRadius: BorderRadius.circular(12)),
//                 child: Column(
//                   //crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Align(
//                       alignment: Alignment.centerRight, // يجعله على اليمين
//                       child: Text(
//                         isSessionAvailable
//                             ? 'حان وقت الجلسة!'
//                             : 'تبقى على الجلسة القادمة',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     isSessionAvailable
//                         ? Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: ElevatedButton(
//                             onPressed: ()  {
//                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>SessionView()));
//                               // final prefs =
//                               // await SharedPreferences.getInstance();
//                               // await prefs.setInt('lastSessionTime',
//                               //     DateTime.now().millisecondsSinceEpoch);
//                               // setState(() {
//                               //   isSessionAvailable = false;
//                               //   remainingTime = Duration(hours: 48);
//                               // });
//                               // _loadSessionData(); // إعادة تحميل البيانات
//                             },
//                             child: Text(
//                               'ابدأ الجلسة',
//                               style: TextStyle(
//                                   color: Color(0xff2C73D9), fontSize: 16),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius:
//                                     BorderRadius.circular(22))),
//                           ),
//                         ),
//                         // Image.asset(
//                         //   // 'assets/images/session.png',
//                         //   //   width: screenWidth * 0.4, // الحجم يتغير حسب العرض
//                         //   //   height: screenHeight * 0.2, // الحجم يتغير حسب الطول
//                         //   //   fit: BoxFit.contain,
//                         //
//                         // ),
//
//                       ],
//                     )
//                         : Column(
//                       children: [
//                         Text(
//                           formatDuration(remainingTime),
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 2),
//                         Text(
//                           'ثواني : دقيقة : ساعة',
//                           style: TextStyle(
//                               color: Colors.white, fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 10),
//
//               Container(
//                 width: double.infinity,
//                 //height: 130,
//                 padding: EdgeInsets.only(top: 8, left: 16, right: 16),
//                 decoration: BoxDecoration(
//                     color: Color(0xFFE3EBF8).withOpacity(0.24),
//                     borderRadius: BorderRadius.circular(12)),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'التقييم الشهري',
//                       textDirection: TextDirection.rtl,
//                       textAlign: TextAlign.right, // محاذاة النص لليمين
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xff2C73D9)),
//                     ),
//                     Text(
//                       'تقييم شهري وكل ثلاثة أشهر لمتابعة التقدم.',
//                       style: TextStyle(color: Color(0xff474747)),
//                       textDirection: TextDirection.rtl,
//                       textAlign: TextAlign.right, // محاذاة النص لليمين
//                     ),
//                     SizedBox(height: 12),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                     StartTest()), // استبدلي "TestScreen" بالشاشة التي تريدين عرضها
//                           );
//                         },
//                         child: Text('ابدأ الاختبار'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xff2C73D9),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16)),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 4,
//                     )
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: Text('تطوير المهارات وإدارة الانفعالات',
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xff2C73D9))),
//               ),
//               SizedBox(height: 10),
//               _buildProgressCard(
//                   'الانفعالات',
//                   'تمارين للتعرف على المشاعر وإدارتها',
//                   emotionProgress,
//                   Color(0xff2C73D9),
//                   '/emotions',
//                   0),
//               SizedBox(height: 10),
//               _buildProgressCard(
//                   'تنمية المهارات',
//                   'استكشف تمارين قيمة تساعدك على تطوير مهاراتك الشخصية والاجتماعية خطوة بخطوة!',
//                   skillsProgress,
//                   Color(0xff2C73D9),
//                   '/skills',
//                   1),
//               SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProgressCard(String title, String subtitle, double progress,
//       Color color, String route, int index) {
//     return Card(
//       color: Colors.white,
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         children: [
//           ListTile(
//             title: Text(title,
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold, color: Color(0xff2C73D9))),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   subtitle,
//                   style: TextStyle(color: Color(0xff474747)),
//                 ),
//                 SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: LinearProgressIndicator(
//                           value: progress,
//                           backgroundColor: Colors.grey[300],
//                           color: color),
//                     ),
//                     SizedBox(width: 10),
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 30.0),
//                       child: Text(
//                         '${(progress * 100).toInt()}%',
//                         style: TextStyle(
//                           // fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                             color: Color(0xff474747)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             trailing: InkWell(
//               borderRadius: BorderRadius.circular(12),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => index == 0
//                           ? EmotionScreen() // إذا كان أول كارد، انتقل إلى EmotionScreen
//                           : SkillsScreen()), // غير ذلك انتقل إلى SkillsScreen
//                 );
//               },
//               child: Padding(
//                 padding: EdgeInsets.all(8), // يوسع منطقة الضغط
//                 child: Icon(Icons.arrow_forward_ios,
//                     size: 18, color: Color(0xff2C73D9)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// lib/screens/home_screen.dart
// lib/screens/home_screen.dart
// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- استيراد الملفات الضرورية ---
// تأكد من صحة هذه المسارات في مشروعك
import 'skills.dart';                     // شاشة المهارات
import 'timetest.dart';                    // شاشة اختبار الوقت (StartTest)
//import '../session/seesion.dart';           // <-- الشاشة التي ينتقل إليها زر "لنبدأ"
import 'package:myfinalpro/widget/side_bar_menu.dart.dart';  // <-- ملف السايد بار المعتمد (تأكد من الاسم side_bar_menu.dart)
import '../widgets/Notifictionicon.dart'; // تأكد من المسارات والاسم
import 'emotion.dart';                    // شاشة الانفعالات
import '../services/Api_services.dart';       // خدمة الـ API (api_service.dart)
import '../login/login_view.dart';            // للعودة عند خطأ التوكن
import 'package:myfinalpro/session/session_details_screen.dart';     // <-- استيراد شاشة تفاصيل الجلسة

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- متغيرات الحالة ---
  bool isSessionAvailable = false;
  bool isSessionInProgressOrCoolingDown = true;
  Duration remainingTime = const Duration(hours: 48);
  Timer? timer;
  double emotionProgress = 0.65; // مثال
  double skillsProgress = 0.80; // مثال
  bool _isLoading = true;
  String? _errorMessage;
  String? _jwtToken;

  // --- متغير لتخزين بيانات الجلسة التالية ---
  Map<String, dynamic>? _nextSessionData;

  // --- ثابت مدة الانتظار ---
  static const sessionCooldownDuration = Duration(hours: 48);
  // static const sessionCooldownDuration = Duration(minutes: 1); // للاختبار

  @override
  void initState() {
    super.initState();
    print("--- HomeScreen initState START ---");
    _loadTokenAndInitialData();
    print("--- HomeScreen initState END ---");
  }

  @override
  void dispose() {
    print("--- HomeScreen dispose ---");
    timer?.cancel();
    super.dispose();
  }

  // --- دالة لتحديث الواجهة بأمان ---
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) { setState(fn); }
  }

  // --- تحميل التوكن ثم بيانات المؤقت والجلسة التالية ---
   Future<void> _loadTokenAndInitialData() async {
    if (!mounted) return;
    if (!_isLoading) setStateIfMounted(() { _isLoading = true; _errorMessage = null; });

    try {
       final prefs = await SharedPreferences.getInstance();
       _jwtToken = prefs.getString('auth_token');

       if (!mounted) return;

       if (_jwtToken == null || _jwtToken!.isEmpty) {
          print("HomeScreen: Token not found, redirecting to Login.");
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginView()), (route) => false);
          return;
       }

       // --- استدعاء الدوال بالتتابع بدلاً من Future.wait ---
       await _loadSessionCooldownData(prefs); // استدعاء دالة المؤقت أولاً
       if (!mounted) return; // تحقق بعد await
       final String? fetchError = await _fetchNextSessionData(); // استدعاء دالة جلب الجلسة ثانياً
       // ----------------------------------------------------

       if (!mounted) return; // تحقق بعد await

       // معالجة خطأ جلب الجلسة إن وجد
       if (fetchError != null) {
         setStateIfMounted(() { _errorMessage = fetchError; });
       }

    } catch (e) {
       print("Error during initial data load: $e");
       if (mounted) setStateIfMounted(() { _errorMessage = "حدث خطأ أثناء تحميل البيانات."; });
    } finally {
        if (mounted) { setStateIfMounted(() { _isLoading = false; }); }
    }
  }
  // --- تحميل بيانات وقت آخر جلسة وتحديد حالة المؤقت ---
  Future<void> _loadSessionCooldownData(SharedPreferences prefs) async {
    final lastSessionTimestamp = prefs.getInt('lastSessionStartTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    print("Last Session Start Timestamp: $lastSessionTimestamp");

    if (lastSessionTimestamp == 0) {
      print("No previous session found. Cooldown not active.");
      // لا نغير isSessionAvailable هنا، ننتظر نتيجة جلب الجلسة
      isSessionInProgressOrCoolingDown = false;
      remainingTime = Duration.zero;
      timer?.cancel();
      return;
    }

    final elapsedTime = currentTime - lastSessionTimestamp;
    if (elapsedTime >= sessionCooldownDuration.inMilliseconds) {
      print("Cooldown completed.");
      isSessionInProgressOrCoolingDown = false;
      remainingTime = Duration.zero;
      timer?.cancel();
    } else {
      final remainingMs = sessionCooldownDuration.inMilliseconds - elapsedTime;
      print("Session in cooldown. Remaining ms: $remainingMs");
      isSessionAvailable = false; // لا يمكن البدء الآن
      isSessionInProgressOrCoolingDown = true;
      remainingTime = Duration(milliseconds: remainingMs);
      _startCooldownTimer(lastSessionTimestamp);
    }
    // لا يوجد setState هنا، سيتم استدعاؤها في _loadTokenAndInitialData أو _fetchNextSessionData
  }

   // --- جلب بيانات الجلسة التالية من الـ API ---
   Future<String?> _fetchNextSessionData() async {
      if (_jwtToken == null) return "خطأ: التوكن مفقود.";
      print("Fetching next session data...");
      try {
         final result = await ApiService.getChildSessions(_jwtToken!);
         if (!mounted) return null; // توقف إذا تم إغلاق الويدجت

         if (result['success'] == true && result['sessions'] != null && result['sessions'] is List) {
             final List<dynamic> sessionsList = result['sessions'];
             if (sessionsList.isNotEmpty) {
                setStateIfMounted(() {
                   _nextSessionData = sessionsList[0];
                   // الجلسة تكون متاحة فقط إذا لم نكن في فترة انتظار
                   isSessionAvailable = !isSessionInProgressOrCoolingDown;
                   _errorMessage = null;
                });
                 print("Next session data loaded: ${_nextSessionData?['title']}");
                 return null; // لا خطأ
             } else {
                setStateIfMounted(() { _nextSessionData = null; isSessionAvailable = false; _errorMessage = "اكتملت الخطة التدريبية!"; });
                 print("No next session available.");
                 return null; // لا خطأ ولكن لا توجد جلسات
             }
         } else {
             final String message = result['message'] ?? 'فشل تحميل الجلسة التالية.';
             setStateIfMounted(() { _nextSessionData = null; isSessionAvailable = false; _errorMessage = message; });
             print("Failed to fetch next session: $message");
             return message; // إرجاع رسالة الخطأ
         }
      } catch (e) {
         print("Error fetching next session data: $e");
         if (mounted) setStateIfMounted(() { _nextSessionData = null; isSessionAvailable = false; _errorMessage = "خطأ في الاتصال لجلب الجلسة."; });
         return "خطأ في الاتصال."; // إرجاع رسالة الخطأ
      }
   }

  // --- بدء المؤقت ---
  void _startCooldownTimer(int sessionStartTime) {
    timer?.cancel();
    print("Starting/Resetting cooldown timer...");
    timer = Timer.periodic(const Duration(seconds: 1), (timerInstance) {
      if (!mounted) { timerInstance.cancel(); return; }
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - sessionStartTime;
      if (elapsed >= sessionCooldownDuration.inMilliseconds) {
        print("Timer: Cooldown completed.");
        // عند اكتمال المؤقت، اجعل الجلسة متاحة (إذا كانت هناك بيانات جلسة تالية)
        setStateIfMounted(() {
           isSessionAvailable = _nextSessionData != null; // <--- التحديث هنا
           isSessionInProgressOrCoolingDown = false;
           remainingTime = Duration.zero;
         });
        timerInstance.cancel();
      } else {
        final newRemainingTime = Duration(milliseconds: sessionCooldownDuration.inMilliseconds - elapsed);
        if (remainingTime.inSeconds != newRemainingTime.inSeconds) {
          setStateIfMounted(() { remainingTime = newRemainingTime; });
        }
      }
    });
  }

  // --- تنسيق الوقت ---
  String formatDuration(Duration duration) {
    duration = duration.isNegative ? Duration.zero : duration;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // --- التحويل للأرقام العربية ---
  String _convertToArabicNumbers(String number) {
     const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
     const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
     String result = number;
     for (int i = 0; i < english.length; i++) { result = result.replaceAll(english[i], arabic[i]); }
     return result;
  }

  // --- دالة بدء الجلسة التدريبية التالية ---
  Future<void> _startSession() async {
     if (!isSessionAvailable || _nextSessionData == null || _jwtToken == null) {
        print("Cannot start session. Available: $isSessionAvailable, NextData: ${_nextSessionData != null}, Token: ${_jwtToken != null}");
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('لا يمكن بدء الجلسة الآن.')));
        return;
     }
     try {
        print("Starting next session (Saving start time)...");
        final prefs = await SharedPreferences.getInstance();
        final nowMillis = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt('lastSessionStartTime', nowMillis);
        print("Saved current session start time: $nowMillis");
        if (!mounted) return;
        setState(() { isSessionAvailable = false; isSessionInProgressOrCoolingDown = true; remainingTime = sessionCooldownDuration; });
        _startCooldownTimer(nowMillis);

        print("Navigating to SessionDetailsScreen for session: ${_nextSessionData!['title']}");
        Navigator.push( context, MaterialPageRoute(
            builder: (context) => SessionDetailsScreen( sessionData: _nextSessionData!, jwtToken: _jwtToken!, ),
          ),
        ).then((_) {
          print("Returned from Session/Details, reloading initial data.");
          _loadTokenAndInitialData(); // أعد تحميل كل شيء عند العودة
        });
     } catch (e) {
        print("Error starting session: $e");
        if (mounted) ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('حدث خطأ عند بدء الجلسة.')));
     }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality( textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        endDrawer: const SideBarMenuTest(),
        appBar: AppBar(
           backgroundColor: Colors.white, elevation: 0,
           leading: Builder( builder: (context) => Padding( padding: const EdgeInsets.only(left: 16.0, top: 16), child: NotificationIcon(),),),
           actions: [ Builder( builder: (context) => IconButton( icon: const Padding( padding: EdgeInsets.only(right: 32.0, top: 20), child: Icon(Icons.menu, color: Color(0xff2C73D9), size: 32,), ), onPressed: () { Scaffold.of(context).openEndDrawer(); },),),],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xff2C73D9)))
            : _errorMessage != null && _nextSessionData == null // اعرض الخطأ فقط إذا لم تكن هناك جلسة تالية أيضاً
                ? Center(
                    child: Padding( padding: const EdgeInsets.all(20), child: Column( mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 50), const SizedBox(height: 10),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: _errorMessage == "اكتملت الخطة التدريبية!" ? Colors.green : Colors.red)), // لون أخضر لرسالة الاكتمال
                        const SizedBox(height: 15),
                        // لا تعرض زر إعادة المحاولة إذا كانت الخطة مكتملة
                        if (_errorMessage != "اكتملت الخطة التدريبية!")
                           ElevatedButton.icon(onPressed: _loadTokenAndInitialData, icon: const Icon(Icons.refresh), label: const Text("إعادة المحاولة"))
                    ],),)
                  )
                : RefreshIndicator(
                    onRefresh: _loadTokenAndInitialData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Center(child: Text('مرحبا !', style: TextStyle(fontSize: 28, color: Color(0xff2C73D9), fontWeight: FontWeight.bold))),
                          const SizedBox(height: 20),
                          // --- حاوية حالة الجلسة ---
                          Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
  decoration: BoxDecoration(
    color: const Color(0xff2C73D9),
    borderRadius: BorderRadius.circular(12)
  ),
  child: AnimatedSwitcher(
    duration: const Duration(milliseconds: 500),
    // تحديد نوع الانتقال (اختياري)
    transitionBuilder: (Widget child, Animation<double> animation) {
      return FadeTransition(opacity: animation, child: child);
    },
    child: isSessionInProgressOrCoolingDown
        // --- حالة عرض المؤقت (تبقى Column) ---
        ? Column(
            key: const ValueKey('timer_view'), // مفتاح مهم لـ AnimatedSwitcher
            mainAxisSize: MainAxisSize.min, // لجعل العمود يأخذ أقل ارتفاع
            children: [
              const Text('تبقى على الجلسة القادمة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
              const SizedBox(height: 8),
              Text( _convertToArabicNumbers(formatDuration(remainingTime)), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'monospace'), textDirection: TextDirection.ltr, textAlign: TextAlign.center,),
              const SizedBox(height: 4),
              const Text( 'ثانية : دقيقة : ساعة', style: TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center,),
            ],
          )
        // ******** حالة عرض الصورة والزر (تعديل إلى Row) ********
        : Container( // استخدام Container مع key لـ AnimatedSwitcher
             key: const ValueKey('start_view'),
             child: Row( // <-- استخدام Row لترتيب أفقي
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // توزيع المسافة
                crossAxisAlignment: CrossAxisAlignment.center, // توسيط عمودي
                children: [
                  // --- الصورة على اليسار ---
                  Expanded( // لإعطاء الصورة مساحة مرنة
                    flex: 4, // نسبة المساحة للصورة (يمكن تعديلها)
                    child: Image.asset(
                      "assets/images/session.png", // تأكد من المسار الصحيح
                      height: 85, // زيادة الارتفاع قليلاً
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => const SizedBox(height: 85, child: Center(child: Icon(Icons.image_not_supported, color: Colors.white54))), // أيقونة بديلة أوضح
                    ),
                  ),
                  const SizedBox(width: 16), // مسافة بين الصورة والعمود

                  // --- عمود النص والزر على اليمين ---
                  Expanded( // لإعطاء العمود مساحة مرنة
                    flex: 4, // نسبة المساحة للنص والزر (يمكن تعديلها)
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center, // توسيط محتويات العمود
                      children: [
                        const Text( 'حان وقت الجلسة!', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold), textAlign: TextAlign.center,), // تكبير الخط قليلاً
                        const SizedBox(height: 18), // زيادة المسافة
                        // --- زر لنبدأ ---
                        ElevatedButton(
                          onPressed: (isSessionAvailable && _nextSessionData != null) ? _startSession : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12), // تعديل padding
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // زيادة دائرية الحواف
                              disabledBackgroundColor: Colors.white.withOpacity(0.7),
                              disabledForegroundColor: const Color(0xff2C73D9).withOpacity(0.5),
                              elevation: 3 // إضافة ظل خفيف للزر
                           ),
                          child: Text( 'لنبدأ', style: TextStyle(color: (isSessionAvailable && _nextSessionData != null) ? const Color(0xff2C73D9) : Colors.grey, fontSize: 17, fontWeight: FontWeight.bold),), // تعديل حجم الخط
                        ),
                      ],
                    ),
                  ),
                ],
              ),
           ),
    // **********************************************************
  ),
),
                          const SizedBox(height: 20),
                          // --- قسم التقييم الشهري ---
                          Container( width: double.infinity, padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), decoration: BoxDecoration(color: const Color(0xFFE3EBF8).withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                            child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Text( 'التقييم الشهري', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff2C73D9)),), const SizedBox(height: 4),
                                const Text( 'تقييم شهري وكل ثلاثة أشهر لمتابعة التقدم.', style: TextStyle(color: Color(0xff474747), fontSize: 14),), const SizedBox(height: 12),
                                Align( alignment: Alignment.centerLeft, child: ElevatedButton( onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => StartTest())); }, child: const Text('ابدأ الاختبار'), style: ElevatedButton.styleFrom( backgroundColor: const Color(0xff2C73D9), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),),),),
                              ],),),
                          const SizedBox(height: 20),
                          // --- قسم تطوير المهارات ---
                          const Padding( padding: EdgeInsets.only(right: 8.0), child: Text('تطوير المهارات وإدارة الانفعالات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff2C73D9))),),
                          const SizedBox(height: 10),
                          _buildProgressCard('الانفعالات', 'تمارين للتعرف على المشاعر وإدارتها', emotionProgress, const Color(0xff2C73D9), () => Navigator.push(context, MaterialPageRoute(builder: (context)=> EmotionScreen()))),
                          const SizedBox(height: 10),
                          _buildProgressCard('تنمية المهارات', 'استكشف تمارين قيمة لتطوير مهاراتك!', skillsProgress, const Color(0xff2C73D9), () => Navigator.push(context, MaterialPageRoute(builder: (context)=> SkillsScreen()))),
                          const SizedBox(height: 40),
                        ],),),),),);
  }

  // --- دالة بناء كارت التقدم ---
  Widget _buildProgressCard(String title, String subtitle, double progress, Color color, VoidCallback onTap) {
    final String progressPercent = "${(progress * 100).toInt()}٪";
    return Card( color: Colors.white, elevation: 2, margin: const EdgeInsets.symmetric(vertical: 5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell( onTap: onTap, borderRadius: BorderRadius.circular(12),
        child: Padding( padding: const EdgeInsets.all(12.0),
          child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff2C73D9), fontSize: 16)),
                  const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xff2C73D9)),
                ],),
              const SizedBox(height: 4),
              Text( subtitle, style: const TextStyle(color: Color(0xff474747), fontSize: 14),),
              const SizedBox(height: 12),
              Row( children: [
                  Expanded( child: ClipRRect( borderRadius: const BorderRadius.all(Radius.circular(10)), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.grey[300], color: color,),),),
                  const SizedBox(width: 10),
                  Text( progressPercent, style: const TextStyle(fontSize: 13, color: Color(0xff474747), fontWeight: FontWeight.bold),),
                ],),
              const SizedBox(height: 5),
            ],
          ),),),);
  }

} // نهاية الكلاس _HomeScreenState
