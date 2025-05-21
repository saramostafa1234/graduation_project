// lib/test3months/test_group_model.dart
import 'package:flutter/foundation.dart';

class TestGroupResponse {
  final int groupId;
  final String groupName;
  final List<TestGroupSession> sessions;
  final String? messageFromApi; // <-- الحقل الجديد للرسالة من الـ API

  TestGroupResponse({
    required this.groupId,
    required this.groupName,
    required this.sessions,
    this.messageFromApi, // <-- إضافة للكونستركتور
  });

  factory TestGroupResponse.fromJson(Map<String, dynamic> json) {
    var sessionsList = <TestGroupSession>[];
    if (json['sessions']?['\$values'] is List) {
      sessionsList = List<TestGroupSession>.from(
          (json['sessions']['\$values'] as List).map((x) {
            if (x is Map<String, dynamic>) {
              try {
                return TestGroupSession.fromJson(x);
              } catch (e) {
                debugPrint("Error parsing TestGroupSession: $e \nData: $x");
                return null;
              }
            }
            return null;
          }).where((s) => s != null).cast<TestGroupSession>()
      );
    } else {
      debugPrint("TestGroupResponse Warning: sessions['\$values'] missing or invalid in JSON.");
    }

    // --- قراءة الرسالة من الـ API إذا كانت موجودة ---
    // بناءً على المثال: return Ok(new { Message = $"قم باداء اختبار ال 3 شهور ل {groupTitle}" });
    // نفترض أن الرسالة تأتي مباشرة في حقل "Message" في الـ JSON الرئيسي لاستجابة test group
    String? apiMessage;
    if (json['Message'] is String) { // أو json['messageFromApi'] إذا كان هذا هو الاسم في الـ JSON
      apiMessage = json['Message'] as String?;
      debugPrint("TestGroupResponse: Parsed messageFromApi: $apiMessage");
    } else if (json['message'] is String) { // محاولة قراءة 'message' كاحتياطي
      apiMessage = json['message'] as String?;
      debugPrint("TestGroupResponse: Parsed message (fallback) fromApi: $apiMessage");
    }


    return TestGroupResponse(
      groupId: json['groupId'] ?? 0,
      groupName: json['groupName'] ?? 'مجموعة غير محددة',
      sessions: sessionsList,
      messageFromApi: apiMessage, // تمرير الرسالة المقروءة
    );
  }
}

class TestGroupSession {
  final int sessionId;
  final String title;
  final int detailsCount;
  final List<TestQuestionDetail> details;
  final TestQuestionDetail newDetail; // يفترض أنها ليست اختيارية بناءً على الكود السابق

  TestGroupSession({
    required this.sessionId,
    required this.title,
    required this.detailsCount,
    required this.details,
    required this.newDetail,
  });

  factory TestGroupSession.fromJson(Map<String, dynamic> json) {
    var detailsList = <TestQuestionDetail>[];
    if (json['details']?['\$values'] is List) {
      detailsList = List<TestQuestionDetail>.from(
          (json['details']['\$values'] as List).map((x) {
            if (x is Map<String, dynamic>) {
              try {
                return TestQuestionDetail.fromJson(x);
              } catch (e) {
                debugPrint("Error parsing TestQuestionDetail from details list: $e \nData: $x");
                return null; // تجاهل التفصيل الخاطئ
              }
            }
            return null;
          }).where((d) => d != null).cast<TestQuestionDetail>()
      );
    } else {
      debugPrint("TestGroupSession Warning: details['\$values'] missing or invalid for session '${json['title']}'.");
    }

    TestQuestionDetail parsedNewDetail;
    if (json['newDetail'] is Map<String, dynamic>) {
      try {
        parsedNewDetail = TestQuestionDetail.fromJson(json['newDetail']);
      } catch (e) {
        debugPrint("Error parsing newDetail for session '${json['title']}': $e \nData: ${json['newDetail']}");
        parsedNewDetail = TestQuestionDetail.empty(); // استخدام قيمة افتراضية في حالة الخطأ
      }
    } else {
      debugPrint("TestGroupSession Warning: newDetail missing or invalid for session '${json['title']}', using empty.");
      parsedNewDetail = TestQuestionDetail.empty(); // استخدام قيمة افتراضية
    }

    return TestGroupSession(
      sessionId: json['sessionId'] ?? 0,
      title: json['title'] ?? 'قسم غير مسمى',
      detailsCount: json['detailsCount'] ?? 0,
      details: detailsList,
      newDetail: parsedNewDetail,
    );
  }
}

class TestQuestionDetail {
  final int detailId;
  final String? imagePath; // المسار الأصلي من الباك اند (Image_)
  final String? video;
  final String? textContent; // النص (Text_)
  final String dataTypeOfContent; // نوع المحتوى (Img, Text, Video)
  final String? sound;
  final String? questions; // السؤال
  final String rightAnswer; // الإجابة الصحيحة
  final String? answers; // الخيارات مفصولة بـ '-'
  final int? groupId;
  final String? groupName;

  // Getters
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  bool get hasText => textContent != null && textContent!.isNotEmpty;
  bool get hasVideo => video != null && video!.isNotEmpty;

  // لتحويل مسار الصورة من الباك اند إلى مسار asset محلي
  String? get localAssetPath {
    if (hasImage && imagePath != null) {
      // 1. استبدال الشرطة المائلة العكسية بالشرطة المائلة الأمامية
      // 2. إزالة "assets/" من البداية إذا كانت موجودة (لتجنب assets/assets/)
      // 3. التأكد من عدم وجود "/" في بداية المسار النسبي
      // 4. إضافة "assets/" في البداية
      final corrected = imagePath!.replaceAll(r'\', '/').trim();
      String relativePath = corrected;
      if (relativePath.startsWith('assets/')) {
        relativePath = relativePath.substring('assets/'.length);
      }
      if (relativePath.startsWith('/')) {
        relativePath = relativePath.substring(1);
      }
      return 'assets/$relativePath';
    }
    return null;
  }

  List<String> get answerOptions {
    if (answers != null && answers!.isNotEmpty) {
      return answers!.split('-').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }


  TestQuestionDetail({
    required this.detailId,
    this.imagePath,
    this.video,
    this.textContent,
    required this.dataTypeOfContent,
    this.sound,
    this.questions,
    required this.rightAnswer, // الإجابة الصحيحة مطلوبة
    this.answers,
    this.groupId,
    this.groupName,
  });

  factory TestQuestionDetail.fromJson(Map<String, dynamic> json) {
    int pDetailId = 0;
    final detailIdVal = json['detail_ID']; // هذا هو الاسم في JSON حسب الـ GroupTest

    if (detailIdVal is int) {
      pDetailId = detailIdVal;
    } else if (detailIdVal is String) {
      pDetailId = int.tryParse(detailIdVal) ?? 0;
    } else if (json.containsKey('id') && json['id'] is int) { // كحالة احتياطية
      pDetailId = json['id'];
    }

    String? img = json['image_'] ?? json['image']; // اسم الحقل في JSON
    if (img != null) {
      img = img.replaceAll(r'\', '/').trim(); // تصحيح المسار مباشرة
    }
    String? txt = json['text_'] ?? json['text'];

    return TestQuestionDetail(
      detailId: pDetailId,
      imagePath: img,
      video: json['video'] as String?,
      textContent: txt,
      dataTypeOfContent: json['dataTypeOfContent'] as String? ?? (img != null && img.isNotEmpty ? 'Img' : (txt != null && txt.isNotEmpty ? 'Text' : 'Unknown')),
      sound: json['sound'] as String?,
      questions: json['questions'] as String?,
      rightAnswer: json['right_Answer'] as String? ?? '', // قيمة افتراضية إذا كانت null
      answers: json['answers'] as String?,
      groupId: json['groupId'] as int?,
      groupName: json['groupName'] as String?,
    );
  }

  // دالة لإنشاء كائن فارغ أو افتراضي
  factory TestQuestionDetail.empty() {
    return TestQuestionDetail(
      detailId: 0,
      dataTypeOfContent: 'Unknown',
      rightAnswer: '',
    );
  }
}