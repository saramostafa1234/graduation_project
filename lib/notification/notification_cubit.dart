import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // لاستخدام الوقت الحالي
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationState.initial());

  void addNotification({required String title, String? time}) {
    final now = DateTime.now();
    // تنسيق بسيط للوقت (يمكن تحسينه)
    final formattedTime = time ?? DateFormat('HH:mm').format(now);
    final newNotification = NotificationItem(
      id: now.millisecondsSinceEpoch.toString(), // ID بسيط
      title: title,
      time: formattedTime,
      timestamp: now,
    );

    // إنشاء قائمة جديدة وإضافة الإشعار في البداية
    final updatedNotifications = List<NotificationItem>.from(state.notifications)
      ..insert(0, newNotification);

    // يمكنك وضع حد أقصى هنا إذا أردت
    // if (updatedNotifications.length > 20) { updatedNotifications.removeLast(); }

    emit(NotificationState(updatedNotifications));
    print("✅ Notification Added: ${newNotification.title}");
  }

  void clearNotifications() {
    emit(NotificationState.initial());
     print("🗑️ Notifications Cleared");
  }
}