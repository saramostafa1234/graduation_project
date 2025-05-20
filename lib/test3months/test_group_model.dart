import 'package:flutter/foundation.dart';

class TestGroupResponse {
  final int groupId;
  final String groupName;
  final List<TestGroupSession> sessions;

  TestGroupResponse({
    required this.groupId,
    required this.groupName,
    required this.sessions,
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

    return TestGroupResponse(
      groupId: json['groupId'] ?? 0,
      groupName: json['groupName'] ?? 'مجموعة غير محددة',
      sessions: sessionsList,
    );
  }
}

class TestGroupSession {
  final int sessionId;
  final String title;
  final int detailsCount;
  final List<TestQuestionDetail> details;
  final TestQuestionDetail newDetail;

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
              return null;
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
        parsedNewDetail = TestQuestionDetail.empty();
      }
    } else {
      debugPrint("TestGroupSession Warning: newDetail missing or invalid for session '${json['title']}', using empty.");
      parsedNewDetail = TestQuestionDetail.empty();
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
  final String? imagePath;
  final String? video;
  final String? textContent;
  final String dataTypeOfContent;
  final String? sound;
  final String? questions;
  final String rightAnswer;
  final String? answers;
  final int? groupId;
  final String? groupName;

  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  bool get hasText => textContent != null && textContent!.isNotEmpty;
  bool get hasVideo => video != null && video!.isNotEmpty;

  String? get localAssetPath {
    if (hasImage && imagePath != null) {
      final corrected = imagePath!.replaceAll(r'\', '/').trim();
      return corrected.startsWith('assets/') ? corrected : 'assets/$corrected';
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
    required this.rightAnswer,
    this.answers,
    this.groupId,
    this.groupName,
  });

  factory TestQuestionDetail.fromJson(Map<String, dynamic> json) {
    int pDetailId = 0;
    final detailIdVal = json['detail_ID'];

    if (detailIdVal is int) {
      pDetailId = detailIdVal;
    } else if (detailIdVal is String) {
      pDetailId = int.tryParse(detailIdVal) ?? 0;
    } else if (json.containsKey('id') && json['id'] is int) {
        pDetailId = json['id'];
    }

    String? img = json['image_'] ?? json['image'];
    if (img != null) {
      img = img.replaceAll(r'\', '/').trim();
    }

    return TestQuestionDetail(
      detailId: pDetailId,
      imagePath: img,
      video: json['video'] as String?,
      textContent: json['text_'] ?? json['text'] as String?,
      dataTypeOfContent: json['dataTypeOfContent'] as String? ?? (img != null ? 'Img' : (json['text_'] != null || json['text'] != null ? 'Text' : 'Unknown')),
      sound: json['sound'] as String?,
      questions: json['questions'] as String?,
      rightAnswer: json['right_Answer'] as String? ?? '',
      answers: json['answers'] as String?,
      groupId: json['groupId'] as int?,
      groupName: json['groupName'] as String?,
    );
  }

  factory TestQuestionDetail.empty() {
    return TestQuestionDetail(
      detailId: 0,
      dataTypeOfContent: 'Unknown',
      rightAnswer: '',
    );
  }
}