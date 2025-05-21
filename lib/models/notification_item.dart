// lib/models/notification_item.dart
import 'dart:convert';

enum NotificationType {
  sessionEnded,
  sessionUpcoming,
  sessionReady,
  monthlyTestAvailable,
  threeMonthTestAvailable,
}

class NotificationItem {
  final String id;
  final String title;
  final String timeAgo; // هذا سيكون محسوبًا عند العرض، لكن سنخزن وقت الإنشاء
  final DateTime createdAt;
  final NotificationType type;
  bool isActive; // لتتبع ما إذا كان الإشعار لا يزال صالحًا

  NotificationItem({
    required this.id,
    required this.title,
    required this.timeAgo,
    required this.createdAt,
    required this.type,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'timeAgo': timeAgo, // سنقوم بتحديث هذا عند الحاجة، لكنه جيد للبداية
    'createdAt': createdAt.toIso8601String(),
    'type': type.toString(),
    'isActive': isActive,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        timeAgo: json['timeAgo'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        type: NotificationType.values
            .firstWhere((e) => e.toString() == json['type']),
        isActive: json['isActive'] as bool? ?? true,
      );

  // دالة لإنشاء نسخة محدثة من الإشعار
  NotificationItemcopyWith({
    String? id,
    String? title,
    String? timeAgo,
    DateTime? createdAt,
    NotificationType? type,
    bool? isActive,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      timeAgo: timeAgo ?? this.timeAgo,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
    );
  }
}

// دالة مساعدة لحساب "الوقت المنقضي منذ"
String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return "الآن";
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes} د";
  } else if (difference.inHours < 24) {
    return "${difference.inHours} س";
  } else if (difference.inDays < 7) {
    return "${difference.inDays} ي";
  } else {
    // يمكنك إضافة تنسيق أكثر تفصيلاً هنا إذا أردت
    return "${(difference.inDays / 7).floor()} أ"; // أسابيع
  }
}