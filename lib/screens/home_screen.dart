import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myfinalpro/screens/skills.dart';
import 'package:myfinalpro/screens/timetest.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../session/seesion.dart';
import '../widget/custom_drawer.dart'; // <-- استخدم هذا الكود للـ Drawer
import '../widgets/Notifictionicon.dart'; // لاحظ حرف i صغير
import 'emotion.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- لا حاجة لـ GlobalKey بعد الآن ---
  // final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool isSessionAvailable = false;
  bool isSessionInProgress = false;
  Duration remainingTime = Duration.zero;
  Timer? timer;
  double emotionProgress = 0.5;
  double skillsProgress = 0.9;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print("--- HomeScreen initState START ---");
    _loadSessionData();
    print("--- HomeScreen initState END ---");
  }

  @override
  void dispose() {
    print("--- HomeScreen dispose ---");
    timer?.cancel();
    super.dispose();
  }

  // --- _loadSessionData, _startCooldownTimer, formatDuration, _convertToArabicNumbers تبقى كما هي ---
  Future<void> _loadSessionData() async {
    if (mounted && _isLoading == false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else if (!mounted) {
      return;
    }

    try {
      print("--- _loadSessionData: Attempting to load SharedPreferences ---");
      final prefs = await SharedPreferences.getInstance();
      final lastSessionTimestamp = prefs.getInt('lastSessionDuration');
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final sessionCooldown = 48 * 60 * 60 * 1000; // 48 hours

      print("--- _loadSessionData ---");
      print("Last Session Timestamp: $lastSessionTimestamp");
      print("Current Time: $currentTime");

      if (lastSessionTimestamp == null) {
        print("No previous session found. Session available.");
        if (mounted) {
          setState(() {
            isSessionAvailable = true;
            isSessionInProgress = false;
            remainingTime = Duration.zero;
            _isLoading = false;
          });
        }
        return;
      }

      final elapsedTime = currentTime - lastSessionTimestamp;
      print("Elapsed Time (ms): $elapsedTime");
      print("Cooldown Time (ms): $sessionCooldown");

      if (elapsedTime >= sessionCooldown) {
        print("Cooldown completed. Session available.");
        if (mounted) {
          setState(() {
            isSessionAvailable = true;
            isSessionInProgress = false;
            remainingTime = Duration.zero;
            _isLoading = false;
          });
        }
        timer?.cancel();
      } else {
        final remainingMs = sessionCooldown - elapsedTime;
        print("Session in cooldown. Remaining ms: $remainingMs");

        if (mounted) {
          setState(() {
            isSessionAvailable = false;
            isSessionInProgress = true;
            remainingTime = Duration(milliseconds: remainingMs);
            _isLoading = false;
          });
        }
        _startCooldownTimer(lastSessionTimestamp, sessionCooldown);
      }
    } catch (e) {
      print("Error loading session data: $e");
      if (mounted) {
        setState(() {
          isSessionAvailable = true;
          isSessionInProgress = false;
          remainingTime = Duration.zero;
          _isLoading = false;
          _errorMessage = "حدث خطأ أثناء تحميل بيانات الجلسة.";
        });
      }
    }
  }

  void _startCooldownTimer(int sessionStartTime, int sessionCooldown) {
    timer?.cancel();
    print("Starting/Resetting cooldown timer...");
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        print("Timer: Widget unmounted, cancelling timer.");
        timer.cancel();
        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - sessionStartTime;

      if (elapsed >= sessionCooldown) {
        print("Timer: Cooldown completed.");
        if (mounted) {
          setState(() {
            isSessionAvailable = true;
            isSessionInProgress = false;
            remainingTime = Duration.zero;
          });
        }
        timer.cancel();
      } else {
        final remaining = sessionCooldown - elapsed;
        if (remainingTime.inSeconds != Duration(milliseconds: remaining).inSeconds) {
          if(mounted){
            setState(() {
              remainingTime = Duration(milliseconds: remaining);
            });
          }
        }
      }
    });
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.clamp(0, 48);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final arabicHours = _convertToArabicNumbers(hours.toString().padLeft(2, '0'));
    final arabicMinutes = _convertToArabicNumbers(minutes.toString().padLeft(2, '0'));
    final arabicSeconds = _convertToArabicNumbers(seconds.toString().padLeft(2, '0'));
    return '$arabicHours:$arabicMinutes:$arabicSeconds';
  }

  String _convertToArabicNumbers(String number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.replaceAllMapped(RegExp(r'[0-9]'),
            (match) => arabicNumerals[int.parse(match.group(0)!)]);
  }

  @override
  Widget build(BuildContext context) {
    print("--- HomeScreen build START ---");
    print("State: isLoading: $_isLoading, isSessionAvailable: $isSessionAvailable, isSessionInProgress: $isSessionInProgress, errorMessage: $_errorMessage");

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // --- إزالة GlobalKey ---
        // key: scaffoldKey,
        backgroundColor: Colors.white,
        // --- استخدام CustomDrawer ---
        endDrawer: CustomDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder( // لا يزال Builder مفيداً هنا لو احتجت context مختلف
            builder: (context) => Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16),
              child: NotificationIcon(),
            ),
          ),
          actions: [
            // --- استخدام Builder لـ IconButton للحصول على context الصحيح ---
            Builder(
              builder: (context) => IconButton(
                icon: Padding(
                  padding: const EdgeInsets.only(right: 32.0, top: 20),
                  child: Icon(
                    Icons.menu,
                    color: Color(0xff2C73D9),
                    size: 32,
                  ),
                ),
                onPressed: () {
                  // --- استخدام Scaffold.of(context) لفتح الـ endDrawer ---
                  Scaffold.of(context).openEndDrawer();
                  print("Menu icon pressed, attempting to open endDrawer.");
                },
              ),
            ),
            // --------------------------------------------------------------
          ],
        ),
        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(color: Color(0xff2C73D9)),
        )
            : _errorMessage != null
            ? Center( /* ... كود عرض الخطأ ... */ )
            : SingleChildScrollView( /* ... كود المحتوى الرئيسي ... */
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
              // --- حاوية حالة الجلسة ---
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
                            ? 'تبقى على الجلسة القادمة'
                            : isSessionAvailable
                            ? 'حان وقت الجلسة!'
                            : 'لا توجد جلسة حالية',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 4),
                    if (isSessionInProgress) ...[
                      Text(
                        formatDuration(remainingTime),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ثواني : دقيقة : ساعة',
                        style: TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ] else if (isSessionAvailable) ...[
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            print("Starting session...");
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setInt('lastSessionDuration', DateTime.now().millisecondsSinceEpoch);
                            print("Saved current session start time.");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SessionView()),
                            ).then((_) {
                              print("Returned from SessionView, reloading session data.");
                              _loadSessionData();
                            });
                          } catch (e) {
                            print("Error starting session: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('حدث خطأ عند بدء الجلسة.'))
                            );
                          }
                        },
                        child: Text(
                          'ابدأ الجلسة',
                          style: TextStyle(
                              color: Color(0xff2C73D9), fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(22)),
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
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2C73D9)),
                    ),
                    Text(
                      'تقييم شهري وكل ثلاثة أشهر لمتابعة التقدم.',
                      style: TextStyle(color: Color(0xff474747)),
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
                                    StartTest()),
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
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => EmotionScreen())),
                  0),
              SizedBox(height: 10),
              _buildProgressCard(
                  'تنمية المهارات',
                  'استكشف تمارين قيمة تساعدك على تطوير مهاراتك الشخصية والاجتماعية خطوة بخطوة!',
                  skillsProgress,
                  Color(0xff2C73D9),
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => SkillsScreen())),
                  1),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- _buildProgressCard يبقى كما هو ---
  Widget _buildProgressCard(String title, String subtitle, double progress,
      Color color, VoidCallback onTap, int index) {
    // ... الكود الخاص بـ _buildProgressCard ...
    return Card(
      color: Colors.white,
      elevation: 2,
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
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Color(0xff2C73D9), fontSize: 16)),
                  Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xff2C73D9)),
                ],
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Color(0xff474747), fontSize: 14),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        color: color,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '${_convertToArabicNumbers((progress * 100).toInt().toString())}٪',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff474747),
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}