// lib/cubit/exercise_flow_state.dart
import 'package:equatable/equatable.dart';
//import '../models/test_detail.dart'; // تأكد من المسار الصحيح

// --- أنواع الخطوات في السيناريو ---
enum ExerciseStepType {
  singleBackendImage, // الخطوة 1 و 2: صورة واحدة من الباك + خيارات
  doubleBackendImage, // الخطوة 3: صورتان من الباك للاختيار بينهما
  backendAndAssetImage, // الخطوة 4: صورة باك + صورة asset للاختيار بينهما
  unknown // حالة غير متوقعة
}

// الكلاس الأساسي للحالات
abstract class ExerciseFlowState extends Equatable {
  const ExerciseFlowState();
  @override
  List<Object?> get props => [];
}

// --- الحالات الأساسية ---
class ExerciseFlowInitial extends ExerciseFlowState {}

class ExerciseFlowLoading extends ExerciseFlowState {}

class ExerciseFlowLoadingDistractor extends ExerciseFlowState {} // لتحميل صورة الـ asset

class ExerciseFlowError extends ExerciseFlowState {
  final String message;
  const ExerciseFlowError(this.message);
  @override
  List<Object> get props => [message];
}

class ExerciseFlowFinished extends ExerciseFlowState {}

class ExerciseFlowUpdatingSession extends ExerciseFlowState {}

// --- الحالة الرئيسية لعرض التمرين/الخطوة ---
class ExerciseStepLoaded extends ExerciseFlowState {
  final int currentStepIndex; // 0, 1, 2, 3
  final ExerciseStepType stepType;
  final String? question; // السؤال العام للخطوة
  final int? mainSessionId; // ID الاختبار الرئيسي

  // بيانات محددة لكل خطوة
  final String? image1Path; // مسار الصورة الأولى (URL من باك أو Asset)
  final String? image2Path; // مسار الصورة الثانية (URL من باك أو Asset)
  final List<String> answerOptions; // الخيارات النصية (لـ singleBackendImage)
  final String? correctAnswer; // الإجابة الصحيحة (نص أو مسار صورة)

  const ExerciseStepLoaded({
    required this.currentStepIndex,
    required this.stepType,
    required this.correctAnswer,
    this.question,
    this.mainSessionId,
    this.image1Path,
    this.image2Path,
    this.answerOptions = const [], // قيمة افتراضية
  });

  @override
  List<Object?> get props => [
    currentStepIndex,
    stepType,
    question,
    mainSessionId,
    image1Path,
    image2Path,
    answerOptions,
    correctAnswer,
  ];
}

// --- حالات الإجابة (تحتفظ بالحالة السابقة) ---
class ExerciseCorrectAnswer extends ExerciseFlowState {
  final ExerciseStepLoaded previousState;
  const ExerciseCorrectAnswer(this.previousState);
  @override
  List<Object?> get props => [previousState];
}

class ExerciseIncorrectAnswer extends ExerciseFlowState {
  final ExerciseStepLoaded previousState;
  const ExerciseIncorrectAnswer(this.previousState);
  @override
  List<Object?> get props => [previousState];
}