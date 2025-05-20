import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_cubit.dart'; // <--- استيراد
import 'notification_state.dart'; // <--- استيراد

class NotificationIcon extends StatefulWidget {
  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  final GlobalKey _iconKey = GlobalKey();
  bool _isNotificationOpen = false;

  void _toggleNotifications(BuildContext context, List<NotificationItem> currentNotifications) {
    if (!mounted) return; // تحقق إضافي

    // إذا كانت النافذة مفتوحة بالفعل، أغلقها
    if (_isNotificationOpen) {
      Navigator.of(context).pop();
      // سيتم تحديث الحالة في .then()
      return;
    }

    setState(() { _isNotificationOpen = true; });

    final RenderBox? renderBox = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
        print("Error: Cannot find RenderBox for notification icon.");
        setState(() { _isNotificationOpen = false; });
        return;
    }
    final Offset position = renderBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => GestureDetector(
        onTap: () {
          if (mounted) { // تحقق قبل إغلاق الـ dialog
            Navigator.of(dialogContext).pop();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
            Positioned(
              top: position.dy + renderBox.size.height + 5,
              right: 16,
              left: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           // زر لمسح الإشعارات (اختياري)
                           TextButton(
                              onPressed: () {
                                context.read<NotificationCubit>().clearNotifications();
                                // لا تغلق الـ dialog هنا، سيعاد بناؤه فارغًا
                              },
                              child: Text("مسح الكل", style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                           ),
                           Text("الإشعارات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                         ],
                      ),
                      SizedBox(height: 10),
                      // --- عرض الإشعارات من الكيوبت ---
                      if (currentNotifications.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: Text("لا توجد إشعارات جديدة.", style: TextStyle(color: Colors.grey))),
                        )
                      else
                        ConstrainedBox( // تحديد ارتفاع أقصى للقائمة
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.5, // نصف ارتفاع الشاشة مثلاً
                          ),
                          child: ListView.builder(
                             shrinkWrap: true, // مهم داخل Column
                             itemCount: currentNotifications.length,
                             itemBuilder: (ctx, index) => _buildNotificationItem(currentNotifications[index]),
                          ),
                        ),
                      // -------------------------------------
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // التأكد من تحديث الحالة عند إغلاق الـ Dialog
      if (mounted) {
        setState(() { _isNotificationOpen = false; });
      }
    });
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(12),
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
                  style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 5),
                Text(
                  notification.time,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.notifications, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- استخدام BlocBuilder لقراءة الحالة ---
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final notifications = state.notifications;

        return Padding(
          padding: const EdgeInsets.only(right: 16.0, top: 16),
          child: GestureDetector(
            key: _iconKey,
            onTap: () => _toggleNotifications(context, notifications),
            child: badges.Badge(
              position: badges.BadgePosition.topEnd(top: -5, end: -5),
              showBadge: notifications.isNotEmpty,
              badgeContent: Text(
                notifications.length.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              // يمكنك إضافة animationType إذا أردت
              // animationType: badges.BadgeAnimationType.scale,
              child: Icon(Icons.notifications, color: Color(0xff2C73D9), size: 28),
            ),
          ),
        );
      },
    );
    // -------------------------------------
  }
}