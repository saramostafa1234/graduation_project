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
// lib/screens/home_screen.dart
// lib/screens/home_screen.dart
// lib/screens/home_screen.dart// lib/screens/home_screen.dart
// lib/screens/home_screen.dart
// lib/screens/home_screen.dart
// lib/screens/home_screen.dart
// lib/screens/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- استيراد الملفات الضرورية ---
// تأكد من صحة هذه المسارات في مشروعك
import 'skills.dart'; // شاشة المهارات
import '../session/timetest.dart'; // شاشة اختبار الوقت (StartTest)
//import '../session/seesion.dart';           // <-- الشاشة التي ينتقل إليها زر "لنبدأ"
import 'package:myfinalpro/widget/side_bar_menu.dart.dart'; // <-- ملف السايد بار المعتمد (تأكد من الاسم side_bar_menu.dart)
import '../widgets/Notifictionicon.dart'; // تأكد من المسارات والاسم
// شاشة الانفعالات
import '../services/Api_services.dart'; // خدمة الـ API (api_service.dart)
import '../login/login_view.dart'; // للعودة عند خطأ التوكن
import 'package:myfinalpro/session/session_intro_screen.dart'; // شاشة مقدمة الجلسة
import 'package:myfinalpro/session/models/session_model.dart'; // نموذج الجلسة
import 'package:myfinalpro/emotion/sequential_session_screen.dart';
import 'package:myfinalpro/screens/start_test_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- متغيرات الحالة ---
  bool isSessionAvailable = false;
  bool isSessionInProgressOrCoolingDown = true;
  Duration remainingTime = Duration.zero;
  Timer? cooldownTimer;
  double emotionProgress = 0.5; // مثال
  double skillsProgress = 0.0; // مثال
  bool _isLoading = true;
  String? _errorMessage;
  String? _jwtToken;
  Session? _nextSessionData;
  

  static const sessionCooldownDuration = Duration(minutes: 1); // للاختبار

  @override
  void initState() {
    super.initState();
    debugPrint("--- HomeScreen initState START ---");
    _loadTokenAndInitialData();
    debugPrint("--- HomeScreen initState END ---");
  }

  @override
  void dispose() {
    debugPrint("--- HomeScreen dispose ---");
    cooldownTimer?.cancel();
    super.dispose();
  }

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // --- تحميل البيانات الأولية ---
  Future<void> _loadTokenAndInitialData() async {
    if (!mounted) return;
    if (_isLoading || !(cooldownTimer?.isActive ?? false)) {
      setStateIfMounted(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _jwtToken = prefs.getString('auth_token');
      if (!mounted) return;
      if (_jwtToken == null || _jwtToken!.isEmpty) {
        debugPrint("HomeScreen: Token not found. Redirecting...");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted)
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LoginView()));
        });
        return;
      }
      debugPrint("HomeScreen: Token loaded.");
      await _loadSessionCooldownDataFromPrefs(prefs);
      if (!mounted) return;
      if (!isSessionInProgressOrCoolingDown) {
        await _fetchNextSessionDataFromApi();
      } else {
        if (isSessionAvailable)
          setStateIfMounted(() => isSessionAvailable = false);
        if (_nextSessionData != null)
          setStateIfMounted(() => _nextSessionData = null);
      }
      // TODO: Fetch actual progress data here
    } catch (e) {
      debugPrint("Error during initial data load: $e");
      if (mounted)
        setStateIfMounted(() {
          _errorMessage = "حدث خطأ أثناء تحميل البيانات.";
        });
    } finally {
      if (mounted)
        setStateIfMounted(() {
          _isLoading = false;
        });
      debugPrint(
          "HomeScreen: Load finished. Loading: $_isLoading, Error: $_errorMessage, Available: $isSessionAvailable, CoolingDown: $isSessionInProgressOrCoolingDown");
    }
  }

  // --- تحميل بيانات المؤقت ---
  Future<void> _loadSessionCooldownDataFromPrefs(
      SharedPreferences prefs) async {
    final lastSessionTimestamp = prefs.getInt('lastSessionStartTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    debugPrint(
        "Current Time: $currentTime / Last Session Ref Timestamp: $lastSessionTimestamp");
    if (lastSessionTimestamp == 0) {
      debugPrint("Cooldown not active (timestamp 0).");
      if (isSessionInProgressOrCoolingDown || remainingTime != Duration.zero) {
        setStateIfMounted(() {
          isSessionInProgressOrCoolingDown = false;
          remainingTime = Duration.zero;
        });
      }
      cooldownTimer?.cancel();
      return;
    }
    final elapsedTime = currentTime - lastSessionTimestamp;
    if (elapsedTime >= sessionCooldownDuration.inMilliseconds) {
      debugPrint("Cooldown completed.");
      if (isSessionInProgressOrCoolingDown || remainingTime != Duration.zero) {
        setStateIfMounted(() {
          isSessionInProgressOrCoolingDown = false;
          remainingTime = Duration.zero;
          isSessionAvailable = false;
          _nextSessionData = null;
        });
      }
      cooldownTimer?.cancel();
    } else {
      final remainingMs = sessionCooldownDuration.inMilliseconds - elapsedTime;
      debugPrint("In cooldown. Remaining ms: $remainingMs");
      if (!isSessionInProgressOrCoolingDown ||
          remainingTime.inMilliseconds != remainingMs) {
        setStateIfMounted(() {
          isSessionAvailable = false;
          isSessionInProgressOrCoolingDown = true;
          remainingTime = Duration(milliseconds: remainingMs);
        });
      }
      _startUiUpdateTimer(lastSessionTimestamp);
    }
  }

  

  // --- جلب الجلسة التالية ---
  Future<void> _fetchNextSessionDataFromApi() async {
    if (isSessionInProgressOrCoolingDown) {
      debugPrint("Skipping fetch (cooldown active).");
      return;
    }
    if (_jwtToken == null) {
      if (mounted) setStateIfMounted(() => _errorMessage = "Token missing.");
      return;
    }
    debugPrint("Fetching next session data...");
    if (!_isLoading) setStateIfMounted(() => _isLoading = true);
    try {
      _nextSessionData = await ApiService.getNextPendingSession(_jwtToken!);
      if (!mounted) return;
      if (_nextSessionData != null) {
        setStateIfMounted(() {
          isSessionAvailable = true;
          isSessionInProgressOrCoolingDown = false;
          _errorMessage = null;
          cooldownTimer?.cancel();
          remainingTime = Duration.zero;
        });
        debugPrint("Next session loaded: ${_nextSessionData?.title}");
      } else {
        setStateIfMounted(() {
          _nextSessionData = null;
          isSessionAvailable = false;
          isSessionInProgressOrCoolingDown = false;
          _errorMessage = "اكتملت الخطة التدريبية!";
          cooldownTimer?.cancel();
          remainingTime = Duration.zero;
        });
        debugPrint("No next session available or parse error.");
      }
    } on Exception catch (e) {
      if (!mounted) return;
      debugPrint("Error fetching next session: $e");
      String errorMsg = "خطأ أثناء جلب الجلسة.";
      if (e.toString().contains('Unauthorized')) {
        errorMsg = "انتهت صلاحية الدخول.";
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted)
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LoginView()));
        });
      } else if (e.toString().contains('Network') ||
          e.toString().contains('Socket')) {
        errorMsg = "خطأ في الاتصال بالشبكة.";
      } else if (e.toString().contains('Timeout')) {
        errorMsg = "انتهت مهلة الطلب.";
      }
      setStateIfMounted(() {
        _nextSessionData = null;
        isSessionAvailable = false;
        _errorMessage = errorMsg;
      });
    } finally {
      if (mounted) setStateIfMounted(() => _isLoading = false);
    }
  }

  // --- بدء مؤقت تحديث الواجهة ---
  void _startUiUpdateTimer(int sessionStartTimeRef) {
    cooldownTimer?.cancel();
    debugPrint(
        "Starting UI cooldown timer from ref time: $sessionStartTimeRef");
    updateRemainingTime() {
      if (!mounted) {
        cooldownTimer?.cancel();
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - sessionStartTimeRef;
      if (elapsed >= sessionCooldownDuration.inMilliseconds) {
        debugPrint("UI Timer: Cooldown complete.");
        cooldownTimer?.cancel();
        setStateIfMounted(() {
          isSessionInProgressOrCoolingDown = false;
          remainingTime = Duration.zero;
          isSessionAvailable = false;
        });
        _fetchNextSessionDataFromApi();
      } else {
        final newRemainingTime =
            sessionCooldownDuration - Duration(milliseconds: elapsed);
        if (remainingTime.inSeconds != newRemainingTime.inSeconds) {
          setStateIfMounted(() {
            if (isSessionInProgressOrCoolingDown) {
              remainingTime = newRemainingTime;
            } else {
              cooldownTimer?.cancel();
            }
          });
        }
      }
    }

    setStateIfMounted(() {
      isSessionInProgressOrCoolingDown = true;
      isSessionAvailable = false;
      updateRemainingTime();
    });
    cooldownTimer = Timer.periodic(
        const Duration(seconds: 1), (timer) => updateRemainingTime());
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

  // --- تحويل الأرقام ---
  String _convertToArabicNumbers(String number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = number;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  // --- بدء الجلسة ---
  Future<void> _startSession() async {
    if (!isSessionAvailable || _nextSessionData == null || _jwtToken == null) {
      return;
    }
    try {
      final sessionId = _nextSessionData?.id;
      if (sessionId == null) {
        return;
      }
      debugPrint("Navigating to Intro Screen for session ID: $sessionId");
      if (!mounted) return;
      final sessionResult = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => SessionIntroScreen(
            session: _nextSessionData!,
            jwtToken: _jwtToken!,
          ),
        ),
      );
      debugPrint("Returned from session flow. Result: $sessionResult");
      if (sessionResult == true && mounted) {
        debugPrint("Session completed. Starting cooldown.");
        final prefs = await SharedPreferences.getInstance();
        final sessionCompletionTimeMillis =
            DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt('lastSessionStartTime', sessionCompletionTimeMillis);
        setStateIfMounted(() {
          isSessionAvailable = false;
          isSessionInProgressOrCoolingDown = true;
          remainingTime = sessionCooldownDuration;
          _nextSessionData = null;
          _errorMessage = null;
        });
        _startUiUpdateTimer(sessionCompletionTimeMillis);
      } else if (mounted) {
        debugPrint(
            "Session not completed or returned false. Reloading home data.");
        _loadTokenAndInitialData();
      }
    } catch (e) {
      debugPrint("Error in _startSession: $e");
    }
  }

  // ================== بناء الواجهة ==================
  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2C73D9);
    //const Color lightBlueBackground = Color(0xFFE3F2FD);
    //const Color greyTextColor = Color(0xff555555);

    // --- !!! إضافة Directionality هنا !!! ---
    return Directionality(
      textDirection: TextDirection.rtl, // تحديد الاتجاه
      child: Scaffold(
        // الـ Scaffold الآن داخل Directionality
        backgroundColor: Colors.grey[100],
        endDrawer: const SideBarMenuTest(),
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8),
              child: Builder(
                builder: (context) => IconButton(
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 16.0, top: 8),
                    child: Icon(Icons.menu, color: primaryBlue, size: 32),
                  ),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
              ),
            ),
          ],
          leading: NotificationIcon(),
        ),
        body: _isLoading && (cooldownTimer == null || !cooldownTimer!.isActive)
            ? const Center(child: CircularProgressIndicator(color: primaryBlue))
            : RefreshIndicator(
                onRefresh: _loadTokenAndInitialData,
                color: primaryBlue,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    const Center(
                        child: Text('مرحبا !',
                            style: TextStyle(
                                fontSize: 28,
                                color: primaryBlue,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Center(
                            child: Text(_errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: _errorMessage!.contains("اكتملت")
                                        ? Colors.green.shade700
                                        : Colors.redAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500))),
                      ),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 112),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 16),
                      decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(12)),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child,
                                Animation<double> animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: isSessionInProgressOrCoolingDown
                            ? Column(
                                key: const ValueKey('timer_view'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'تبقى على الجلسة القادمة',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _convertToArabicNumbers(
                                        formatDuration(remainingTime)),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace'),
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'ساعة : دقيقة : ثانية',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : Container(
                                key: const ValueKey('start_view'),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'حان وقت الجلسة!',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 18),
                                          ElevatedButton(
                                            onPressed: isSessionAvailable
                                                ? _startSession
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 45,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                disabledBackgroundColor:
                                                    Colors.white.withAlpha(178),
                                                disabledForegroundColor:
                                                    primaryBlue.withAlpha(128),
                                                elevation: 3),
                                            child: Text(
                                              'لنبدأ',
                                              style: TextStyle(
                                                  color: isSessionAvailable
                                                      ? primaryBlue
                                                      : Colors.grey.shade400,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Image.asset(
                                        "assets/images/session.png",
                                        height: 80,
                                        fit: BoxFit.contain,
                                        errorBuilder: (ctx, err, st) =>
                                            const SizedBox(
                                                height: 80,
                                                child: Center(
                                                    child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color:
                                                            Colors.white54))),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    // --- قسم التقييم الشهري ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE3EBF8).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'التقييم الشهري',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2C73D9)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'تقييم شهري وكل ثلاثة أشهر لمتابعة التقدم.',
                            style: TextStyle(
                                color: Color(0xff474747), fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Timetest()));
                                    },
                              child: const Text('ابدأ الاختبار'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2C73D9),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // --- قسم تطوير المهارات ---
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text('تطوير المهارات وإدارة الانفعالات',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff2C73D9))),
                    ),
                    const SizedBox(height: 10),
                    _buildProgressCard(
                        'الانفعالات',
                        'تمارين للتعرف على المشاعر وإدارتها',
                        emotionProgress,
                        const Color(0xff2C73D9),
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TrainingSessionsScreen()))),
                    const SizedBox(height: 10),
                    _buildProgressCard(
                        'تنمية المهارات',
                        'استكشف تمارين قيمة لتطوير مهاراتك!',
                        skillsProgress,
                        const Color(0xff2C73D9),
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SkillsScreen()))),
                    const SizedBox(height: 40), //
                  ],
                ),
              ),
      ),
    );
  }

  // --- دالة بناء كارت التقدم ---
  Widget _buildProgressCard(String title, String subtitle, double progress,
      Color color, VoidCallback onTap) {
    final String progressPercent = "${(progress * 100).toInt()}٪";
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2C73D9),
                          fontSize: 16)),
                  const Icon(Icons.arrow_forward_ios,
                      size: 18, color: Color(0xff2C73D9)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xff474747), fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    progressPercent,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xff474747),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
} // نهاية الكلاس _HomeScreenState
