// lib/models/quiz_models.dart
import 'package:flutter/foundation.dart';

class QuizSession {
  final int childSessionId;
  final int sessionId;
  final String title;
  final int detailsCount;
  final String question;
  final String answer;
  final List<QuizDetail> details;
  final QuizDetail newDetail;
 

  int get id => sessionId; // Getter for easier access if needed elsewhere

  QuizSession({
    required this.childSessionId,
    required this.sessionId,
    required this.title,
    required this.detailsCount,
    required this.question,
    required this.answer,
    required this.details,
    required this.newDetail,
    
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    var detailsList = <QuizDetail>[];
    QuizDetail parsedNewDetail;

    if (json['details']?['\$values'] is List) {
      detailsList = List<QuizDetail>.from(
        (json['details']['\$values'] as List).map((x) {
          if (x is Map<String, dynamic>) {
            try {
              return QuizDetail.fromJson(x);
            } catch (e) {
              debugPrint("Err parsing QuizDetail: $e");
              return null;
            }
          }
          return null;
        }).where((d) => d != null).cast<QuizDetail>()
      );
    } else {
      debugPrint("Warn: details['\$values'] missing/invalid");
    }

    if (json['newDetail'] is Map<String, dynamic>) {
      try {
        parsedNewDetail = QuizDetail.fromJson(json['newDetail']);
      } catch (e) {
        debugPrint("Err parsing newDetail: $e");
        parsedNewDetail = QuizDetail.empty();
      }
    } else {
       debugPrint("Warn: newDetail missing/invalid, using empty");
      parsedNewDetail = QuizDetail.empty();
    }

    return QuizSession(
      childSessionId: json['childSessionId'] ?? 0,
      sessionId: json['sessionId'] ?? 0,
      title: json['title'] ?? 'اختبار',
      detailsCount: json['detailsCount'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      details: detailsList,
      newDetail: parsedNewDetail,
    );
  }
}

class QuizDetail {
  final int id;
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
  final String? quizStepQuestion; // <-- هل هذا السطر موجود؟
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  bool get hasText => textContent != null && textContent!.isNotEmpty;

  String? get localAssetPath {
    if (hasImage) {
      final corrected = imagePath!.replaceAll(r'\', '/').trim();
      return 'assets/$corrected';
    }
    return null;
  }

  List<String> get answerOptions {
    if (answers != null && answers!.isNotEmpty) {
      return answers!.split('-').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  QuizDetail({
    required this.id,
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
    this.quizStepQuestion,
  });

  factory QuizDetail.fromJson(Map<String, dynamic> json) {
    int pId = 0, pDetailId = 0;
    final idVal = json['id'];
    final detailIdVal = json['detail_ID'];

    if (idVal is int) {
      pId = idVal;
    } else if (idVal is String) {
      pId = int.tryParse(idVal) ?? 0;
    }

    if (detailIdVal is int) {
      pDetailId = detailIdVal;
    } else if (detailIdVal is String) {
      pDetailId = int.tryParse(detailIdVal) ?? 0;
    }

    String? img = json['image_'] ?? json['image'];
    if (img != null) {
      img = img.replaceAll(r'\', '/').trim();
    }

    return QuizDetail(
      id: pId,
      detailId: pDetailId,
      imagePath: img,
      video: json['video'],
      textContent: json['text_'] ?? json['text'],
      dataTypeOfContent: json['dataTypeOfContent'] ?? 'Text',
      sound: json['sound'],
      questions: json['questions'],
      rightAnswer: json['right_Answer'] ?? '',
      answers: json['answers'],
      groupId: json['groupId'],
      groupName: json['groupName'],
      

    );
  }

  factory QuizDetail.empty() {
    return QuizDetail(
      id: 0,
      detailId: 0,
      dataTypeOfContent: 'Unknown',
      rightAnswer: '',
    );
  }
}