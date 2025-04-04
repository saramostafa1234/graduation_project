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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myfinalpro/screens/skills.dart';
import 'package:myfinalpro/screens/timetest.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../session/seesion.dart';
import '../widget/custom_drawer.dart';
import '../widgets/Notifictionicon.dart';
import 'emotion.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSessionAvailable = false; // لتحديد ما إذا كانت الجلسة متاحة
  bool isSessionInProgress = false; // لتحديد ما إذا كانت الجلسة قيد التقدم
  Duration remainingTime =
      Duration(hours: 47, minutes: 59, seconds: 59); // الزمن المتبقي للجلسة
  Timer? timer; // المؤقت
  double emotionProgress = 0.5; // تقدم الانفعالات
  double skillsProgress = 0.9; // تقدم المهارات

  @override
  void initState() {
    super.initState();
    _loadSessionData(); // تحميل بيانات الجلسة عند بدء التطبيق
  }

  @override
  void dispose() {
    timer?.cancel(); // إيقاف المؤقت عند مغادرة الصفحة
    super.dispose();
  }

  Future<void> _loadSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSessionTime = prefs.getInt('lastSessionTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final sessionCooldown = 48 * 60 * 60 * 1000; // 48 ساعة بالمللي ثانية

    if (currentTime - lastSessionTime >= sessionCooldown) {
      setState(() {
        isSessionAvailable = true; // يمكن بدء الجلسة الجديدة
        isSessionInProgress = false; // الجلسة ليست قيد التقدم
        remainingTime = Duration.zero; // لا يوجد زمن متبقي
      });
    } else {
      setState(() {
        isSessionAvailable = false; // لا يمكن بدء الجلسة بعد
        isSessionInProgress = true; // نجعلها قيد التقدم في هذه الحالة
        remainingTime = Duration(
            milliseconds: sessionCooldown -
                (currentTime - lastSessionTime)); // حساب الزمن المتبقي
      });

      // إعداد مؤقت لتحديث الزمن المتبقي كل ثانية
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (remainingTime.inSeconds > 0) {
          setState(() {
            remainingTime = remainingTime - Duration(seconds: 1);
          });
        } else {
          setState(() {
            isSessionAvailable = true; // الجلسة الآن متاحة
            isSessionInProgress = false; // الجلسة انتهت
            timer.cancel();
          });
        }
      });
    }
  }

  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = (duration.inMinutes % 60);
    int seconds = (duration.inSeconds % 60);

    return '\u202E${_convertToArabicNumbers(seconds)} : ${_convertToArabicNumbers(minutes)} : ${_convertToArabicNumbers(hours)}';
  }

  String _convertToArabicNumbers(int number) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicNumbers[int.parse(digit)])
        .join('');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        endDrawer: CustomDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16),
              /*child: IconButton(
                // ✅ النوتفكيشن على اليمين
                icon: Icon(Icons.notifications, color: Color(0xff2C73D9)),
                 onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationsScreen()),
    );
  },
              ),*/
              child: NotificationIcon(),
            ),
          ),
          actions: [
            IconButton(
              // ✅ المنيو على اليسار وتفتح السايد بار
              icon: Padding(
                padding: const EdgeInsets.only(right: 32.0, top: 20),
                child: Icon(
                  Icons.menu,
                  color: Color(0xff2C73D9),
                  size: 32,
                ),
              ),
              onPressed: () {
                scaffoldKey.currentState
                    ?.openEndDrawer(); // فتح السايد بار عند الضغط
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('مرحبا !',
                    style: TextStyle(
                        fontSize: 28,
                        color: Color(0xff2C73D9),
                        fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Color(0xff2C73D9),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        isSessionInProgress
                            ? 'الجلسة قيد التقدم!' // حالة الجلسة
                            : isSessionAvailable
                                ? 'حان وقت الجلسة!' // عند توفر الجلسة
                                : 'تبقى على الجلسة القادمة', // الوقت المتبقي للجلسة
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 4),
                    if (isSessionInProgress || !isSessionAvailable) ...[
                      Text(
                        formatDuration(remainingTime), // الزمن المتبقي
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ثواني : دقيقة : ساعة',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ] else if (isSessionAvailable) ...[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SessionView()), // الانتقال إلى شاشة الجلسة
                          );
                        },
                        child: Text(
                          'ابدأ الجلسة',
                          style:
                              TextStyle(color: Color(0xff2C73D9), fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 10),
              // قسم التقييم الشهري
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                decoration: BoxDecoration(
                    color: Color(0xFFE3EBF8).withOpacity(0.24),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التقييم الشهري',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2C73D9)),
                    ),
                    Text(
                      'تقييم شهري وكل ثلاثة أشهر لمتابعة التقدم.',
                      style: TextStyle(color: Color(0xff474747)),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    StartTest()), // الانتقال إلى اختبار جديد
                          );
                        },
                        child: Text('ابدأ الاختبار'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff2C73D9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text('تطوير المهارات وإدارة الانفعالات',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2C73D9))),
              ),
              SizedBox(height: 10),
              _buildProgressCard(
                  'الانفعالات',
                  'تمارين للتعرف على المشاعر وإدارتها',
                  emotionProgress,
                  Color(0xff2C73D9),
                  'emotions',
                  0),
              SizedBox(height: 10),
              _buildProgressCard(
                  'تنمية المهارات',
                  'استكشف تمارين قيمة تساعدك على تطوير مهاراتك الشخصية والاجتماعية خطوة بخطوة!',
                  skillsProgress,
                  Color(0xff2C73D9),
                  'skills',
                  1),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, String subtitle, double progress,
      Color color, String route, int index) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xff2C73D9))),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(color: Color(0xff474747)),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          color: color),
                    ),
                    SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff474747),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pushNamed(context, route);
              },
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_forward_ios,
                    size: 18, color: Color(0xff2C73D9)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildProgressCard(BuildContext context, String title, String subtitle,
    double progress, Color color, String route, int index) {
  return Card(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(
      children: [
        ListTile(
          title: Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xff2C73D9))),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: TextStyle(color: Color(0xff474747)),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        color: color),
                  ),
                  SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xff474747)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => index == 0
                        ? EmotionScreen() // إذا كان أول كارد، انتقل إلى EmotionScreen
                        : SkillsScreen()), // غير ذلك انتقل إلى SkillsScreen
              );
            },
            child: Padding(
              padding: EdgeInsets.all(8), // يوسع منطقة الضغط
              child: Icon(Icons.arrow_forward_ios,
                  size: 18, color: Color(0xff2C73D9)),
            ),
          ),
        ),
      ],
    ),
  );
}
