// lib/models/question_model.dart
// lib/models/question_model.dart
class Question {
  final int id;
  final String emotion;
  final String dimension;
  final String text;
  final String? explanation; // <-- حقل جديد: شرح السؤال (اختياري)

  Question({
    required this.id,
    required this.emotion,
    required this.dimension,
    required this.text,
    this.explanation, // <-- اجعله اختياريًا
  });
}