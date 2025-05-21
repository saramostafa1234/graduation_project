import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import '../models/notification_item.dart'; // استيراد المودل
import '../services/notification_manager.dart'; // استيراد مدير الإشعارات

class NotificationIcon extends StatefulWidget {
  final Function? onNotificationsUpdated;

  // تعديل الكونستركتور لاستقبال المفتاح بشكل صحيح
  const NotificationIcon({super.key, this.onNotificationsUpdated});

  @override
  // تعديل اسم الحالة ليكون عامًا إذا أردنا الوصول إليه من الخارج عبر المفتاح
  // ولكن الطريقة الأفضل هي توفير دالة عامة refresh
  NotificationIconState createState() => NotificationIconState();
}

// جعل اسم الحالة عامًا (NotificationIconState بدلاً من _NotificationIconState)
class NotificationIconState extends State<NotificationIcon> {
  final GlobalKey _iconKey = GlobalKey();
  bool _isNotificationOpen = false;
  List<NotificationItem> _activeNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationsFromPrefs();
  }

  Future<void> _loadNotificationsFromPrefs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      _activeNotifications = await NotificationManager.loadNotifications();
      _activeNotifications = _activeNotifications.where((n) => n.isActive).toList();
      _activeNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // الأحدث أولاً
    } catch (e) {
      debugPrint("Error loading notifications in Icon: $e");
      _activeNotifications = [];
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // دالة عامة لتحديث الإشعارات من الخارج
  void refreshNotifications() {
    _loadNotificationsFromPrefs();
  }

  void _toggleNotifications(BuildContext context) {
    if (_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("جاري تحميل الإشعارات...")),
      );
      return;
    }

    _loadNotificationsFromPrefs().then((_) {
      if (!mounted) return;
      setState(() {
        _isNotificationOpen = !_isNotificationOpen;
      });

      if (_isNotificationOpen) {
        final RenderBox renderBox =
        _iconKey.currentContext!.findRenderObject() as RenderBox;
        final Offset position = renderBox.localToGlobal(Offset.zero);

        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          builder: (context) => GestureDetector(
            onTap: () {
              if (mounted) {
                setState(() {
                  _isNotificationOpen = false;
                });
              }
              Navigator.of(context).pop();
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                Positioned(
                  top: position.dy + renderBox.size.height + 5,
                  right: 16,
                  left: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "الإشعارات",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 10),
                          if (_activeNotifications.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(
                                child: Text(
                                  "لا توجد إشعارات حاليًا.",
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height * 0.5,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _activeNotifications.length,
                                itemBuilder: (ctx, index) {
                                  final notification = _activeNotifications[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                notification.title,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.right,
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                formatTimeAgo(notification.createdAt),
                                                style: const TextStyle(
                                                    fontSize: 12, color: Colors.grey),
                                                textAlign: TextAlign.right,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        CircleAvatar(
                                          backgroundColor: Colors.blue.shade100,
                                          child: const Icon(Icons.notifications, color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).then((_) {
          if (mounted) {
            setState(() {
              _isNotificationOpen = false;
            });
          }
          if (widget.onNotificationsUpdated != null) {
            widget.onNotificationsUpdated!();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 16),
      child: GestureDetector(
        key: _iconKey,
        onTap: () => _toggleNotifications(context),
        child: badges.Badge(
          position: badges.BadgePosition.topEnd(top: -5, end: -5),
          showBadge: !_isLoading && _activeNotifications.isNotEmpty,
          badgeContent: Text(
            _isLoading ? ".." : _activeNotifications.length.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          child: const Icon(Icons.notifications, color: Color(0xff2C73D9), size: 28),
        ),
      ),
    );
  }
}