import 'package:equatable/equatable.dart';

class NotificationItem extends Equatable {
  final String id;
  final String title;
  final String time;
  final DateTime timestamp;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.time,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, title, time, timestamp];

  Map<String, String> toMap() {
    return {"title": title, "time": time};
  }
}

class NotificationState extends Equatable {
  final List<NotificationItem> notifications;

  const NotificationState(this.notifications);

  // الحالة الأولية
  factory NotificationState.initial() => const NotificationState([]);

  @override
  List<Object> get props => [notifications];
}