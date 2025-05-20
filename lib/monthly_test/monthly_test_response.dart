// lib/models/monthly_test_response.dart
// ! تأكد من المسار الصحيح لـ test_detail.dart
import 'test_detail.dart'; // <-- المسار الصحيح لملف test_detail

class MonthlyTestResponse {
  final int? childSessionId;
  final int?
      sessionId; // معرّف الجلسة الرئيسي للاختبار (يستخدم في markSessionDone)
  final String? title;
  final int? detailsCount;
  final List<TestDetail> details; // <-- القائمة الأولى
  final List<TestDetail> newDetails; // <-- القائمة الثانية

  MonthlyTestResponse({
    this.childSessionId,
    this.sessionId,
    this.title,
    this.detailsCount,
    required this.details,
    required this.newDetails,
  });

  factory MonthlyTestResponse.fromJson(Map<String, dynamic> json) {
    List<TestDetail> parsedDetails = [];
    // *** التعديل هنا: استخدام "\$values" ***
    if (json['details'] != null && json['details']["\$values"] is List) {
      parsedDetails = (json['details']["\$values"] as List)
          .map((item) => TestDetail.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (json['details'] is List) {
      // احتياطي إذا كانت القائمة مباشرة
      parsedDetails = (json['details'] as List)
          .map((item) => TestDetail.fromJson(item as Map<String, dynamic>))
          .toList();
      print("Warning: 'details' was a direct list, not wrapped in '\$values'.");
    }

    List<TestDetail> parsedNewDetails = [];
    // *** التعديل هنا: استخدام "\$values" ***
    if (json['newDetail'] != null && json['newDetail']["\$values"] is List) {
      parsedNewDetails = (json['newDetail']["\$values"] as List)
          .map((item) => TestDetail.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (json['newDetail'] is List) {
      // احتياطي إذا كانت القائمة مباشرة
      parsedNewDetails = (json['newDetail'] as List)
          .map((item) => TestDetail.fromJson(item as Map<String, dynamic>))
          .toList();
      print(
          "Warning: 'newDetail' was a direct list, not wrapped in '\$values'.");
    }

    return MonthlyTestResponse(
      childSessionId: json['childSessionId'] as int?,
      sessionId: json['sessionId'] as int?,
      title: json['title'] as String?,
      detailsCount: json['detailsCount'] as int?,
      details: parsedDetails,
      newDetails: parsedNewDetails,
    );
  }

  // دالة لدمج قائمتي التمارين في قائمة واحدة
  List<TestDetail> getAllExercises() {
    return [...details, ...newDetails];
  }
}
// lib/models/monthly_test_response.dart
///////////
// import 'test_detail.dart';
//
// class MonthlyTestResponse {
//   final int? childSessionId;
//   final int? sessionId;
//   final String? title;
//   final int? detailsCount;
//   final List<TestDetail> details;
//   final List<TestDetail> newDetails;
//
//   MonthlyTestResponse({
//     this.childSessionId,
//     this.sessionId,
//     this.title,
//     this.detailsCount,
//     required this.details,
//     required this.newDetails,
//   });
//
//   factory MonthlyTestResponse.fromJson(Map<String, dynamic> json) {
//     List<TestDetail> parsedDetails = [];
//     if (json['details'] != null && json['details']["\$values"] is List) {
//       parsedDetails = (json['details']["\$values"] as List)
//           .map((item) => TestDetail.fromJson(item as Map<String, dynamic>))
//           .toList();
//     } else if (json['details'] is List) {
//       parsedDetails = (json['details'] as List)
//           .map((item) => TestDetail.fromJson(item as Map<String, dynamic>))
//           .toList();
//       print("Warning: 'details' was a direct list, not wrapped in '\$values'.");
//     }
//
//     List<TestDetail> parsedNewDetails = [];
//     if (json['newDetail'] != null && json['newDetail']["\$values"] is List) {
//       parsedNewDetails = (json['newDetail']["\$values"] as List)
//           .map((item) => TestDetail.fromJson(item as Map<String, dynamic>))
//           .toList();
//     } else if (json['newDetail'] is List) {
//       parsedNewDetails = (json['newDetail'] as List)
//           .map((item) => TestDetail.fromJson(item as Map<String, dynamic>))
//           .toList();
//       print("Warning: 'newDetail' was a direct list, not wrapped in '\$values'.");
//     }
//
//     return MonthlyTestResponse(
//       childSessionId: json['childSessionId'] as int?,
//       sessionId: json['sessionId'] as int?,
//       title: json['title'] as String?,
//       detailsCount: json['detailsCount'] as int?,
//       details: parsedDetails,
//       newDetails: parsedNewDetails,
//     );
//   }
//
//   List<TestDetail> getAllExercises() {
//     return [...details, ...newDetails];
//   }
// }