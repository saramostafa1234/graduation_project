import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../monthly_test/exercise_flow_screen.dart';
import 'skills.dart';
import 'package:myfinalpro/widget/side_bar_menu.dart.dart';
import '../widgets/notifictionicon.dart';
import '../services/Api_services.dart';
import '../login/login_view.dart';
import 'package:myfinalpro/session/session_intro_screen.dart';
import 'package:myfinalpro/session/models/session_model.dart';
import 'package:myfinalpro/emotion/sequential_session_screen.dart';
import 'package:myfinalpro/screens/start_test_screen.dart';
import 'package:myfinalpro/test3months/test_group_model.dart';
import 'package:myfinalpro/test3months/group_test_manager_screen.dart';

import '../models/notification_item.dart' as notif_model;
import '../services/notification_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSessionAvailable = false;
  bool isSessionInProgressOrCoolingDown = true;
  Duration remainingTime = Duration.zero;
  Timer? cooldownTimer;
  double emotionProgress = 0.0;
  double skillsProgress = 0.0;
  bool _isLoading = true;
  String? _errorMessage;
  String? _jwtToken;
  Session? _nextSessionData;
  bool _isFetchingTestGroup = false;

  final GlobalKey<NotificationIconState> _notificationIconKey = GlobalKey<NotificationIconState>();
  //static const sessionCooldownDuration = Duration(hours: 48);
  static const sessionCooldownDuration = Duration(minutes: 1);

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

  Future<void> _updateSessionNotifications() async {
    await NotificationManager.clearSessionNotifications();
    final prefs = await SharedPreferences.getInstance();
    final lastSessionTimestamp = prefs.getInt('lastSessionStartTime') ?? 0;

    if (isSessionInProgressOrCoolingDown && lastSessionTimestamp > 0) {
      final timeSinceLastSessionEnd = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastSessionTimestamp));
      String endedTimeString = "منذ ";
      if (timeSinceLastSessionEnd.inDays > 0) endedTimeString += "${timeSinceLastSessionEnd.inDays} يوم ";
      else if (timeSinceLastSessionEnd.inHours > 0) endedTimeString += "${timeSinceLastSessionEnd.inHours} س ";
      else if (timeSinceLastSessionEnd.inMinutes > 0) endedTimeString += "${timeSinceLastSessionEnd.inMinutes} د ";
      else endedTimeString += "دقائق قليلة";

      await NotificationManager.addOrUpdateNotification(notif_model.NotificationItem(
        id: 'session_status_ended',
        title: "انتهت الجلسة ${endedTimeString.trim()}",
        timeAgo: notif_model.formatTimeAgo(DateTime.now()),
        createdAt: DateTime.now(),
        type: notif_model.NotificationType.sessionEnded,
      ));

      String remainingTimeString = "";
      if (remainingTime.inHours > 0) remainingTimeString += "${remainingTime.inHours} س ";
      if (remainingTime.inMinutes.remainder(60) > 0) remainingTimeString += "${remainingTime.inMinutes.remainder(60)} د";

      if (remainingTimeString.isNotEmpty) {
        await NotificationManager.addOrUpdateNotification(notif_model.NotificationItem(
          id: 'session_status_upcoming',
          title: "تبدأ الجلسة القادمة بعد ${remainingTimeString.trim()}",
          timeAgo: notif_model.formatTimeAgo(DateTime.now()),
          createdAt: DateTime.now(),
          type: notif_model.NotificationType.sessionUpcoming,
        ));
      }

    } else if (isSessionAvailable && _nextSessionData != null) {
      await NotificationManager.addOrUpdateNotification(notif_model.NotificationItem(
        id: 'session_status_ready',
        title: "حان وقت الجلسة! (${_nextSessionData?.title ?? 'غير محدد'})",
        timeAgo: notif_model.formatTimeAgo(DateTime.now()),
        createdAt: DateTime.now(),
        type: notif_model.NotificationType.sessionReady,
      ));
    }
    _notificationIconKey.currentState?.refreshNotifications();
  }

  Future<void> _loadTokenAndInitialData() async {
    if (!mounted) return;
    if (!_isLoading && !_isFetchingTestGroup && (cooldownTimer == null || !cooldownTimer!.isActive)) {
      setStateIfMounted(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else if (_isLoading && !_isFetchingTestGroup && (cooldownTimer == null || !cooldownTimer!.isActive)){
      setStateIfMounted(() {
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
          if (mounted) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LoginView()));
          }
        });
        if (mounted) setStateIfMounted(() => _isLoading = false);
        return;
      }
      debugPrint("HomeScreen: Token loaded.");
      await _loadSessionCooldownDataFromPrefs(prefs);
      if (!mounted) return;

      if (!isSessionInProgressOrCoolingDown) {
        // handled by _loadSessionCooldownDataFromPrefs or _fetchNextSessionDataFromApi
      } else {
        if (isSessionAvailable) setStateIfMounted(() => isSessionAvailable = false);
        if (_nextSessionData != null) setStateIfMounted(() => _nextSessionData = null);
      }

      if (_nextSessionData != null) {
        await _checkAndGenerateTestNotificationsFromSessionData(_nextSessionData!);
      }

    } catch (e) {
      debugPrint("Error during initial data load: $e");
      if (mounted) {
        setStateIfMounted(() {
          _errorMessage = "حدث خطأ أثناء تحميل البيانات.";
        });
      }
    } finally {
      if (mounted && !_isFetchingTestGroup) {
        setStateIfMounted(() {
          _isLoading = false;
        });
      }
      await _updateSessionNotifications();
      debugPrint(
          "HomeScreen: Load finished. Loading: $_isLoading, Error: $_errorMessage, Available: $isSessionAvailable, CoolingDown: $isSessionInProgressOrCoolingDown, FetchingGroup: $_isFetchingTestGroup");
    }
  }

  Future<void> _checkAndGenerateTestNotificationsFromSessionData(Session sessionData) async {
    final monthlyTestApiResponseMessage = sessionData.attributes?['monthly_test_message'] as String?;
    if (monthlyTestApiResponseMessage != null && monthlyTestApiResponseMessage.isNotEmpty) {
      bool alreadySent = await NotificationManager.isMonthlyTestNotificationSent();
      if (!alreadySent) {
        await NotificationManager.addOrUpdateNotification(notif_model.NotificationItem(
          id: 'monthly_test_available_from_session',
          title: monthlyTestApiResponseMessage,
          timeAgo: notif_model.formatTimeAgo(DateTime.now()),
          createdAt: DateTime.now(),
          type: notif_model.NotificationType.monthlyTestAvailable,
        ));
        await NotificationManager.setMonthlyTestNotificationSent(true);
        _notificationIconKey.currentState?.refreshNotifications();
        debugPrint("HomeScreen: Monthly test notification generated from session data: $monthlyTestApiResponseMessage");
      }
    }

    final threeMonthTestApiResponseMessage = sessionData.attributes?['three_month_test_message'] as String?;
    if (threeMonthTestApiResponseMessage != null && threeMonthTestApiResponseMessage.isNotEmpty) {
      bool alreadySent = await NotificationManager.isThreeMonthTestNotificationSent();
      if (!alreadySent) {
        await NotificationManager.addOrUpdateNotification(notif_model.NotificationItem(
          id: '3_month_test_available_from_session',
          title: threeMonthTestApiResponseMessage,
          timeAgo: notif_model.formatTimeAgo(DateTime.now()),
          createdAt: DateTime.now(),
          type: notif_model.NotificationType.threeMonthTestAvailable,
        ));
        await NotificationManager.setThreeMonthTestNotificationSent(true);
        _notificationIconKey.currentState?.refreshNotifications();
        debugPrint("HomeScreen: 3-Month test notification generated from session data: $threeMonthTestApiResponseMessage");
      }
    }
  }

  Future<void> _loadSessionCooldownDataFromPrefs(SharedPreferences prefs) async {
    final lastSessionTimestamp = prefs.getInt('lastSessionStartTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (lastSessionTimestamp == 0) {
      debugPrint("Cooldown not active (timestamp 0).");
      if (isSessionInProgressOrCoolingDown || remainingTime != Duration.zero) {
        setStateIfMounted(() {
          isSessionInProgressOrCoolingDown = false;
          remainingTime = Duration.zero;
        });
      }
      cooldownTimer?.cancel();
      await _fetchNextSessionDataFromApi();
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
      await _fetchNextSessionDataFromApi();
    } else {
      final remainingMs = sessionCooldownDuration.inMilliseconds - elapsedTime;
      if (!isSessionInProgressOrCoolingDown || remainingTime.inMilliseconds.round() != remainingMs.round()) {
        setStateIfMounted(() {
          isSessionAvailable = false;
          isSessionInProgressOrCoolingDown = true;
          remainingTime = Duration(milliseconds: remainingMs);
        });
      }
      _startUiUpdateTimer(lastSessionTimestamp);
    }
    await _updateSessionNotifications();
  }

  Future<void> _fetchNextSessionDataFromApi() async {
    if (isSessionInProgressOrCoolingDown) return;
    if (_jwtToken == null) {
      if (mounted) setStateIfMounted(() => _errorMessage = "Token missing.");
      return;
    }
    if (!_isLoading && !_isFetchingTestGroup) setStateIfMounted(() => _isLoading = true);
    try {
      _nextSessionData = await ApiService.getNextPendingSession(_jwtToken!);
      if (!mounted) return;
      if (_nextSessionData != null) {
        setStateIfMounted(() {
          isSessionAvailable = true;
          _errorMessage = null;
        });
        await _checkAndGenerateTestNotificationsFromSessionData(_nextSessionData!);
      } else {
        setStateIfMounted(() {
          _nextSessionData = null;
          isSessionAvailable = false;
        });
        if (mounted && _errorMessage == null) {
          setStateIfMounted(() {
            _errorMessage = "اكتملت الخطة التدريبية للجلسات اليومية!";
          });
        }
      }
    } on Exception catch (e) {
      if (!mounted) return;
      String errorMsg = "خطأ أثناء جلب الجلسة.";
      if (e.toString().contains('Unauthorized')) {
        errorMsg = "انتهت صلاحية الدخول.";
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView()));
        });
      } else if (e.toString().contains('Network') || e.toString().contains('SocketException')) {
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
      if (mounted && !_isFetchingTestGroup) setStateIfMounted(() => _isLoading = false);
      await _updateSessionNotifications();
    }
  }

  void _startUiUpdateTimer(int sessionStartTimeRef) {
    cooldownTimer?.cancel();
    updateRemainingTime() async {
      if (!mounted) {
        cooldownTimer?.cancel();
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - sessionStartTimeRef;
      if (elapsed >= sessionCooldownDuration.inMilliseconds) {
        cooldownTimer?.cancel();
        if(isSessionInProgressOrCoolingDown || remainingTime != Duration.zero || isSessionAvailable){
          setStateIfMounted(() {
            isSessionInProgressOrCoolingDown = false;
            remainingTime = Duration.zero;
            isSessionAvailable = false;
          });
        }
        await _fetchNextSessionDataFromApi();
      } else {
        final newRemainingTime = sessionCooldownDuration - Duration(milliseconds: elapsed);
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
      await _updateSessionNotifications();
    }
    if(isSessionInProgressOrCoolingDown){
      updateRemainingTime();
      cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) => updateRemainingTime());
    } else {
      cooldownTimer?.cancel();
    }
  }

  String formatDuration(Duration duration) {
    duration = duration.isNegative ? Duration.zero : duration;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String _convertToArabicNumbers(String number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = number;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  Future<void> _startSession() async {
    if (!isSessionAvailable || _nextSessionData == null || _jwtToken == null) return;
    try {
      final sessionId = _nextSessionData?.id;
      if (sessionId == null) return;
      if (!mounted) return;
      final sessionResult = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => SessionIntroScreen(session: _nextSessionData!, jwtToken: _jwtToken!),
        ),
      );
      if (sessionResult == true && mounted) {
        final prefs = await SharedPreferences.getInstance();
        final sessionCompletionTimeMillis = DateTime.now().millisecondsSinceEpoch;
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
        if(!isSessionInProgressOrCoolingDown){
          await _fetchNextSessionDataFromApi();
        }
      }
    } catch (e) {
      debugPrint("Error in _startSession: $e");
    }
    await _updateSessionNotifications();
  }

  Future<void> _startThreeMonthTest() async {
    if (_jwtToken == null || _jwtToken!.isEmpty) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("خطأ: التوكن غير موجود.")));
      return;
    }
    if (_isFetchingTestGroup) return;
    setStateIfMounted(() => _isFetchingTestGroup = true);
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("جاري تحميل اختبار الـ 3 شهور..."), duration: Duration(seconds: 1),));

    try {
      final TestGroupResponse? testGroupData = await ApiService.fetchNextTestGroup(_jwtToken!);
      if (!mounted) return;

      if (testGroupData != null && testGroupData.sessions.isNotEmpty) {
        bool alreadySent = await NotificationManager.isThreeMonthTestNotificationSent();
        if (!alreadySent) {
          // استخدام messageFromApi من TestGroupResponse إذا كان متاحًا
          String notificationMessage = testGroupData.messageFromApi ?? "حان موعد اختبار الـ 3 شهور لـ ${testGroupData.groupName}";
          await NotificationManager.addOrUpdateNotification(notif_model.NotificationItem(
            id: '3_month_test_available_${testGroupData.groupId}',
            title: notificationMessage,
            timeAgo: notif_model.formatTimeAgo(DateTime.now()),
            createdAt: DateTime.now(),
            type: notif_model.NotificationType.threeMonthTestAvailable,
          ));
          await NotificationManager.setThreeMonthTestNotificationSent(true);
          _notificationIconKey.currentState?.refreshNotifications();
          debugPrint("HomeScreen: 3-Month test notification generated: $notificationMessage");
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupTestManagerScreen(testGroupData: testGroupData, jwtToken: _jwtToken!),
          ),
        ).then((_) {
          _loadTokenAndInitialData();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("لا يوجد اختبار 3 شهور متاح حاليًا أو حدث خطأ في التحميل.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error starting three month test: $e");
      if (mounted) {
        String errorMsg = "حدث خطأ أثناء تحميل اختبار الـ 3 شهور.";
        if (e.toString().contains('Unauthorized')) errorMsg = "انتهت صلاحية الدخول.";
        else if (e.toString().contains('Failed to load test group data')) errorMsg = "فشل تحميل بيانات اختبار المجموعة.";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } finally {
      if (mounted) setStateIfMounted(() => _isFetchingTestGroup = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2C73D9);
    const Color assessmentCardBgColor = Color(0xFFE3F2FD);
    const Color assessmentTextColor = primaryBlue;
    const Color assessmentButtonBgColor = primaryBlue;
    const Color assessmentButtonFgColor = Colors.white;
    bool showGlobalLoading = (_isLoading || _isFetchingTestGroup) && (cooldownTimer == null || !cooldownTimer!.isActive);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
                  icon: const Icon(Icons.menu, color: primaryBlue, size: 32),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
              ),
            ),
          ],
          leading: NotificationIcon(
            key: _notificationIconKey,
            onNotificationsUpdated: () {
              _loadTokenAndInitialData();
            },
          ),
        ),
        body: showGlobalLoading
            ? const Center(child: CircularProgressIndicator(color: primaryBlue))
            : RefreshIndicator(
          onRefresh: _loadTokenAndInitialData,
          color: primaryBlue,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              const Center(child: Text('مرحبا !', style: TextStyle(fontSize: 28, color: primaryBlue, fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              if (_errorMessage != null && !isSessionInProgressOrCoolingDown && !_isFetchingTestGroup)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Center(child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: _errorMessage!.contains("اكتملت") ? Colors.green.shade700 : Colors.redAccent, fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w500))),
                ),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 112),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0,2))]),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) => FadeTransition(opacity: animation, child: child),
                  child: isSessionInProgressOrCoolingDown
                      ? Column(
                    key: const ValueKey('timer_view'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('تبقى على الجلسة القادمة', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(_convertToArabicNumbers(formatDuration(remainingTime)), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'monospace'), textDirection: TextDirection.ltr, textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      const Text('ساعة : دقيقة : ثانية', style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Cairo'), textAlign: TextAlign.center),
                    ],
                  )
                      : Container(
                    key: const ValueKey('start_view'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('حان وقت الجلسة${_nextSessionData?.title != null ? " (${_nextSessionData!.title})" : "!"}', style: const TextStyle(color: Colors.white, fontSize: 19, fontFamily: 'Cairo', fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              const SizedBox(height: 18),
                              ElevatedButton(
                                onPressed: (isSessionAvailable && !_isFetchingTestGroup) ? _startSession : null,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), disabledBackgroundColor: Colors.white.withAlpha(178), disabledForegroundColor: primaryBlue.withAlpha(128), elevation: 3),
                                child: Text('لنبدأ', style: TextStyle(color: (isSessionAvailable && !_isFetchingTestGroup) ? primaryBlue : Colors.grey.shade400, fontSize: 17, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Image.asset("assets/images/session.png", height: 90, fit: BoxFit.contain, errorBuilder: (ctx, err, st) => const SizedBox( height: 90, child: Center(child: Icon(Icons.image_not_supported, color: Colors.white54, size: 50)))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildAssessmentCard(
                      title: 'التقييم الشهري',
                      subtitle: 'تقييم شهري وكل ثلاثة أشهر لمتابعة التقدم.',
                      buttonText: 'ابدأ الاختبار',
                      onPressed: _isFetchingTestGroup ? null : () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ExerciseFlowScreen())).then((value) {
                          _notificationIconKey.currentState?.refreshNotifications();
                          _loadTokenAndInitialData();
                        });
                      },
                      isLoading: false,
                      cardBgColor: assessmentCardBgColor,
                      textColor: assessmentTextColor,
                      buttonBgColor: assessmentButtonBgColor,
                      buttonFgColor: assessmentButtonFgColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAssessmentCard(
                      title: 'اختبار الـ 3 شهور',
                      subtitle: 'تقييم شامل كل ثلاثة أشهر لمتابعة التطور العام.',
                      buttonText: 'ابدأ الاختبار',
                      onPressed: _startThreeMonthTest,
                      isLoading: _isFetchingTestGroup,
                      cardBgColor: assessmentCardBgColor,
                      textColor: assessmentTextColor,
                      buttonBgColor: assessmentButtonBgColor,
                      buttonFgColor: assessmentButtonFgColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(right: 8.0, bottom: 6.0),
                child: Text('تطوير المهارات وإدارة الانفعالات', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: primaryBlue)),
              ),
              _buildProgressCard('الانفعالات', 'تمارين للتعرف على المشاعر وإدارتها بفعالية.',/* emotionProgress*/ primaryBlue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => TrainingSessionsScreen()))),
              const SizedBox(height: 12),
              _buildProgressCard('تنمية المهارات', 'استكشف تمارين قيمة لتطوير مهاراتك الشخصية والاجتماعية!',/* skillsProgress*/ primaryBlue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => SkillsScreen()))),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentCard({ required String title, required String subtitle, required String buttonText, required VoidCallback? onPressed, required bool isLoading, required Color cardBgColor, required Color textColor, required Color buttonBgColor, required Color buttonFgColor, }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 175),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0,1))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: textColor)),
              const SizedBox(height: 5),
              Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.75), fontSize: 13, fontFamily: 'Cairo', height: 1.3)),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              child: isLoading ? const SizedBox(width:18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,)) : Text(buttonText, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: buttonBgColor, foregroundColor: buttonFgColor, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, String subtitle, /*double progress*/Color color, VoidCallback onTap) {
    //final String progressPercent = "${(progress * 100).toInt()}٪";
    return Card(
      color: Colors.white,
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo', fontSize: 17)),
                  Icon(Icons.arrow_forward_ios, size: 18, color: color.withOpacity(0.8)),
                ],
              ),
              const SizedBox(height: 5),
              Text(subtitle, style: const TextStyle(color: Color(0xff555555), fontSize: 14, fontFamily: 'Cairo', height: 1.3)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      //child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.grey[200], color: color),
                    ),
                  ),
                  const SizedBox(width: 12),
                  //Text(_convertToArabicNumbers(progressPercent), style: const TextStyle(fontSize: 14, color: Color(0xff333333), fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}