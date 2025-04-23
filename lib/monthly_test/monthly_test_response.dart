// lib/models/monthly_test_response.dart
// ! تأكد من المسار الصحيح لـ test_detail.dart
import 'test_detail.dart'; // <-- المسار الصحيح لملف test_detail

class MonthlyTestResponse {
  final int? childSessionId;
  final int? sessionId; // معرّف الجلسة الرئيسي للاختبار (يستخدم في markSessionDone)
  final String? title;
  final int? detailsCount;
  final List<TestDetail> details;
  final List<TestDetail> newDetails;

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
    // استخدام '\$values' للوصول للقائمة داخل details
    if (json['details'] != null && json['details']['\$values'] is List) {
      parsedDetails = (json['details']['\$values'] as List)
          .map((item) => TestDetail.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<TestDetail> parsedNewDetails = [];
    // استخدام '\$values' للوصول للقائمة داخل newDetail
    if (json['newDetail'] != null && json['newDetail']['\$values'] is List) {
      parsedNewDetails = (json['newDetail']['\$values'] as List)
          .map((item) => TestDetail.fromJson(item as Map<String, dynamic>))
          .toList();
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

  // دالة لدمج قائمتي التمارين في قائمة واحدة للعرض المتسلسل
  List<TestDetail> getAllExercises() {
    return [...details, ...newDetails];
  }
}