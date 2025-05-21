// lib/services/notification_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart'; // تأكد من المسار الصحيح
import 'package:flutter/material.dart'; // For debugPrint

class NotificationManager {
  static const String _notificationsKey = 'app_notifications_list';
  static const String _monthlyTestNotifSentKey = 'monthly_test_notification_sent_flag';
  static const String _threeMonthTestNotifSentKey = 'three_month_test_notification_sent_flag';

  // --- تحميل كل الإشعارات النشطة ---
  static Future<List<NotificationItem>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? notificationsJson = prefs.getStringList(_notificationsKey);
    if (notificationsJson == null) {
      return [];
    }
    return notificationsJson
        .map((jsonString) => NotificationItem.fromJson(jsonDecode(jsonString)))
        .where((item) => item.isActive) // عرض الإشعارات النشطة فقط
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // الأحدث أولاً
  }

  // --- حفظ كل الإشعارات ---
  static Future<void> _saveNotifications(List<NotificationItem> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> notificationsJson =
    notifications.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_notificationsKey, notificationsJson);
    debugPrint("NotificationManager: Saved ${notifications.length} notifications.");
  }

  // --- إضافة أو تحديث إشعار ---
  static Future<void> addOrUpdateNotification(NotificationItem newItem) async {
    List<NotificationItem> currentNotifications = await loadNotifications();
    // البحث عن إشعار موجود بنفس النوع (للإشعارات التي تتحدث مثل الجلسة)
    // أو بنفس الـ ID إذا كان فريدًا
    int existingIndex = currentNotifications.indexWhere((n) => n.type == newItem.type || n.id == newItem.id);

    if (existingIndex != -1) {
      currentNotifications[existingIndex] = newItem; // تحديث
      debugPrint("NotificationManager: Updated notification: ${newItem.id} - ${newItem.title}");
    } else {
      currentNotifications.add(newItem); // إضافة
      debugPrint("NotificationManager: Added new notification: ${newItem.id} - ${newItem.title}");
    }
    await _saveNotifications(currentNotifications);
  }


  // --- إزالة إشعار بناءً على النوع ---
  static Future<void> removeNotificationByType(NotificationType typeToRemove) async {
    List<NotificationItem> currentNotifications = await loadNotifications();
    // إزالة جميع الإشعارات من هذا النوع أو جعلها غير نشطة
    // للخيار الثاني:
    bool changed = false;
    for (var item in currentNotifications) {
      if (item.type == typeToRemove && item.isActive) {
        item.isActive = false;
        changed = true;
        debugPrint("NotificationManager: Deactivated notification of type $typeToRemove, ID: ${item.id}");
      }
    }
    if (changed) {
      // إعادة حفظ القائمة الكاملة بعد إزالة/تعطيل العناصر
      // أو يمكنك فلترة العناصر النشطة فقط قبل الحفظ إذا أردت إزالتها نهائياً
      final activeNotifications = currentNotifications.where((n) => n.isActive).toList();
      await _saveNotifications(activeNotifications);
    }
  }

  // --- إزالة إشعارات الجلسة (المنتهية، القادمة، الجاهزة) ---
  static Future<void> clearSessionNotifications() async {
    List<NotificationItem> currentNotifications = await loadNotifications();
    currentNotifications.removeWhere((item) =>
    item.type == NotificationType.sessionEnded ||
        item.type == NotificationType.sessionUpcoming ||
        item.type == NotificationType.sessionReady);
    await _saveNotifications(currentNotifications);
    debugPrint("NotificationManager: Cleared all session-related notifications.");
  }

  // --- دوال خاصة بحالة "تم الإرسال" للاختبارات ---
  static Future<bool> isMonthlyTestNotificationSent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_monthlyTestNotifSentKey) ?? false;
  }

  static Future<void> setMonthlyTestNotificationSent(bool sent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_monthlyTestNotifSentKey, sent);
    debugPrint("NotificationManager: Monthly test notification sent flag set to $sent.");
  }

  static Future<bool> isThreeMonthTestNotificationSent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_threeMonthTestNotifSentKey) ?? false;
  }

  static Future<void> setThreeMonthTestNotificationSent(bool sent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_threeMonthTestNotifSentKey, sent);
    debugPrint("NotificationManager: 3-Month test notification sent flag set to $sent.");
  }
}