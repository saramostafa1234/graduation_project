// lib/cubit/exercise_flow_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:myfinalpro/monthly_test/test_detail.dart';
import 'package:myfinalpro/services/Api_services.dart';
import '../services/Api_services.dart';
import 'exercise_flow_state.dart';
import 'dart:math';
import 'package:myfinalpro/services/asset_service.dart';

class ExerciseFlowCubit extends Cubit<ExerciseFlowState> {
  // ... (باقي المتغيرات والدوال كما هي) ...
  final ApiService apiService;
  final String randomAssetFolderPath;

  List<TestDetail> _backendExercises = [];
  int? _mainSessionId;
  int _currentStepIndex = -1;

  final int totalSteps = 4;

  ExerciseFlowCubit(this.apiService, {this.randomAssetFolderPath = 'assets/objects/'})
      : super(ExerciseFlowInitial()){
    print("onCreate -- ExerciseFlowCubit");
  }

  Future<void> fetchMonthlyTest() async {
    // ... (الكود كما هو) ...
    print("Cubit: Fetching monthly test...");
    emit(ExerciseFlowLoading());
    final result = await apiService.getMonthlyTestDetails();

    result.fold(
          (failure) {
        print("Cubit Error fetching test: ${failure.message}");
        emit(ExerciseFlowError(failure.message));
      },
          (testResponse) {
        _backendExercises = testResponse.getAllExercises();
        _mainSessionId = testResponse.sessionId;
        print("Cubit: Fetched ${_backendExercises.length} backend exercises. Session ID: $_mainSessionId");

        if (_backendExercises.length < 5) {
          emit(ExerciseFlowError("لا توجد صور كافية من الـ API لتنفيذ سيناريو الاختبار المطلوب (مطلوب 5 على الأقل)."));
          return;
        }
        _currentStepIndex = -1;
        _prepareExerciseStep(0);
      },
    );
  }

  Future<void> _prepareExerciseStep(int stepIndex) async {
    // ... (الكود كما هو) ...
    if (stepIndex < 0 || stepIndex >= totalSteps) {
      print("Cubit Info: Invalid step index requested ($stepIndex) or all steps completed. Finishing session.");
      _completeSession(_mainSessionId);
      return;
    }
    _currentStepIndex = stepIndex;

    print("Cubit: Preparing step $stepIndex...");

    ExerciseStepType currentStepType = ExerciseStepType.unknown;
    String? question;
    String? img1AssetPath, img2AssetPath; // تغيير الأسماء لتعكس أنها مسارات asset
    List<String> options = [];
    String? correctAnswer; // يمكن أن يكون نصًا أو مسار asset

    try {
      if (_backendExercises.length <= stepIndex ||
          (stepIndex == 2 && _backendExercises.length <= stepIndex + 1) ||
          (stepIndex == 3 && _backendExercises.length <= stepIndex + 1)) {
        throw Exception("Insufficient backend exercises for step $stepIndex.");
      }

      switch (stepIndex) {
        case 0:
          currentStepType = ExerciseStepType.singleBackendImage;
          question = _backendExercises[0].question;
          img1AssetPath = _backendExercises[0].localAssetPath;
          options = _backendExercises[0].answerOptions;
          correctAnswer = _backendExercises[0].rightAnswer; // الإجابة النصية
          if (img1AssetPath == null || options.isEmpty || correctAnswer == null) throw Exception("بيانات ناقصة للخطوة 0");
          break;
        case 1:
          currentStepType = ExerciseStepType.singleBackendImage;
          question = _backendExercises[1].question;
          img1AssetPath = _backendExercises[1].localAssetPath;
          options = _backendExercises[1].answerOptions;
          correctAnswer = _backendExercises[1].rightAnswer;
          if (img1AssetPath == null || options.isEmpty || correctAnswer == null) throw Exception("بيانات ناقصة للخطوة 1");
          break;
        case 2:
          currentStepType = ExerciseStepType.doubleBackendImage;
          question = _backendExercises[2].question ?? "اختر الصورة الصحيحة";
          img1AssetPath = _backendExercises[2].localAssetPath;
          img2AssetPath = _backendExercises[3].localAssetPath;
          correctAnswer = _backendExercises[2].rightAnswerImagePathOrUrl; // الإجابة هي مسار الصورة الأولى
          if (img1AssetPath == null || img2AssetPath == null || correctAnswer == null) throw Exception("بيانات ناقصة للخطوة 2");
          if (img1AssetPath == img2AssetPath) {
            print("Warning: Backend images for step 2 are the same ($img1AssetPath). Attempting to use 5th image.");
            final altImg2 = _backendExercises[4].localAssetPath;
            if (_backendExercises.length > 4 && altImg2 != null && altImg2 != img1AssetPath) {
              img2AssetPath = altImg2;
              print("Using 5th image as alternative for step 2: $img2AssetPath");
            } else {
              print("Error: Could not find a different second backend image for step 2.");
              throw Exception("لا يمكن العثور على صورة asset ثانية مختلفة للخطوة 3.");
            }
          }
          break;
        case 3:
          currentStepType = ExerciseStepType.backendAndAssetImage;
          question = _backendExercises[4].question ?? "اختر الصورة الصحيحة";
          img1AssetPath = _backendExercises[4].localAssetPath; // صورة الباك (الآن كـ asset)
          correctAnswer = _backendExercises[4].rightAnswerImagePathOrUrl; // الإجابة هي مسار الـ asset هذا
          if (img1AssetPath == null || correctAnswer == null) throw Exception("صورة الـ Asset أو الإجابة الصحيحة مفقودة للخطوة 3");

          emit(ExerciseFlowLoadingDistractor());
          try {
            img2AssetPath = await _loadRandomObjectDistractor(randomAssetFolderPath);
            if (img2AssetPath == null) {
              throw Exception("فشل تحميل صورة المشتت العشوائية.");
            }
            print("Cubit: Random asset loaded for step 3: $img2AssetPath");
          } catch (e) {
            print("Cubit Error loading random asset: $e");
            emit(ExerciseFlowError("خطأ أثناء تحميل الصورة العشوائية: $e"));
            return;
          }
          break;
      }

      if (currentStepType == ExerciseStepType.unknown ||
          ((currentStepType == ExerciseStepType.doubleBackendImage || currentStepType == ExerciseStepType.backendAndAssetImage) && img2AssetPath == null)) {
        throw Exception("بيانات الخطوة $stepIndex غير مكتملة أو غير صالحة.");
      }

      emit(ExerciseStepLoaded(
        currentStepIndex: stepIndex,
        stepType: currentStepType,
        question: question,
        mainSessionId: _mainSessionId,
        image1Path: img1AssetPath,
        image2Path: img2AssetPath,
        answerOptions: options,
        correctAnswer: correctAnswer,
      ));
      print("Cubit: Emitted ExerciseStepLoaded for step $stepIndex.");

    } catch (e, s) {
      print("Cubit Error preparing step $stepIndex: $e\n$s");
      emit(ExerciseFlowError("حدث خطأ أثناء تحضير الخطوة ${stepIndex + 1}: ${e.toString()}"));
    }
  }

  Future<String?> _loadRandomObjectDistractor(String folderPath) async {
    // ... (الكود كما هو) ...
    String? randomPath;
    int attempts = 0;
    const maxAttempts = 5; // عدد محاولات التحميل
    while (attempts < maxAttempts) {
      try {
        randomPath = await getRandomAssetPathFromFolder(folderPath);
      } catch (e, s) {
        print("Error in getRandomAssetPathFromFolder: $e\n$s");
        return null; // فشل الاستدعاء نفسه
      }
      print("Distractor load attempt ${attempts + 1}: Got path '$randomPath' from folder '$folderPath'");
      if (randomPath != null && randomPath.isNotEmpty) { // التأكد من أنه ليس فارغًا
        return randomPath; // تم العثور على مسار صالح
      }
      attempts++;
      if (attempts < maxAttempts) {
        // انتظر قليلاً قبل المحاولة مرة أخرى
        await Future.delayed(Duration(milliseconds: 100 * attempts));
      }
    }
    print("Warning: Failed to get random asset path from '$folderPath' after $maxAttempts attempts.");
    return null; // فشل العثور على مسار بعد عدة محاولات
  }

  // --- *** التعديل الأخير لـ submitAnswer *** ---
  void submitAnswer(String selectedAnswer) {
    final currentState = state; // اقرأ الحالة مرة واحدة
    print("submitAnswer called with: $selectedAnswer. Current state type: ${currentState.runtimeType}");

    // --- تحديد loadedState بناءً على نوع currentState ---
    ExerciseStepLoaded? loadedState; // اجعله nullable

    if (currentState is ExerciseStepLoaded) {
      loadedState = currentState;
    } else if (currentState is ExerciseIncorrectAnswer) {
      // --- *** الوصول الآمن إلى previousState بعد التحقق من النوع *** ---
      loadedState = currentState.previousState;
    } else {
      print("Cubit: submitAnswer called in an invalid state (${currentState.runtimeType}). Ignoring.");
      return; // الخروج إذا لم تكن الحالة متوقعة
    }
    // --- نهاية التحديد ---

    // الآن loadedState مضمون أنه ليس null إذا وصلنا لهنا
    final correctAnswer = loadedState.correctAnswer;
    print("Cubit: Step ${loadedState.currentStepIndex} - Selected: '$selectedAnswer', Correct: '$correctAnswer'");

    if (correctAnswer == null) {
      print("Cubit Error: Correct answer is null. Cannot verify.");
      emit(ExerciseFlowError("خطأ داخلي: الإجابة الصحيحة غير محددة لهذه الخطوة."));
      return;
    }

    bool isCorrect = (selectedAnswer == correctAnswer);

    if (isCorrect) {
      print("Cubit: Correct answer!");
      emit(ExerciseCorrectAnswer(loadedState)); // OK
    } else {
      print("Cubit: Incorrect answer.");
      emit(ExerciseIncorrectAnswer(loadedState)); // OK
    }
  }
  // --- *** نهاية التعديل *** ---


  void retryCurrentStep() {
    // ... (الكود كما هو) ...
    if (state is ExerciseIncorrectAnswer) {
      // --- *** الوصول الآمن هنا أيضًا *** ---
      final incorrectState = state as ExerciseIncorrectAnswer;
      print("Cubit: Retrying step ${incorrectState.previousState.currentStepIndex}");
      emit(incorrectState.previousState);
    } else {
      print("Cubit: retryCurrentStep called in invalid state (${state.runtimeType})");
    }
  }


  void proceedToNextExercise() {
    // ... (الكود كما هو) ...
    if (state is ExerciseCorrectAnswer) {
      // --- *** الوصول الآمن هنا أيضًا *** ---
      final correctState = state as ExerciseCorrectAnswer;
      final previousState = correctState.previousState;
      print("Proceeding from CorrectAnswer state (previous step ${previousState.currentStepIndex})");

      final nextStepIndex = previousState.currentStepIndex + 1;
      print("Calculating next step index: $nextStepIndex");

      if (nextStepIndex < totalSteps) {
        print("Preparing next step: $nextStepIndex");
        _prepareExerciseStep(nextStepIndex);
      } else {
        print("All steps completed. Completing session...");
        _completeSession(_mainSessionId);
      }
    } else {
      print("Warning: proceedToNextExercise called in unexpected state: ${state.runtimeType}");
    }
  }


  Future<void> _completeSession(int? sessionId) async {
    // ... (الكود كما هو) ...
    if (sessionId == null) {
      print("Cubit Error: Cannot complete session, sessionId is null.");
      emit(ExerciseFlowFinished());
      return;
    }

    if (state is! ExerciseFlowUpdatingSession) {
      emit(ExerciseFlowUpdatingSession());
    }

    final result = await apiService.markSessionDone(sessionId);
    result.fold(
          (failure) {
        print("Cubit Error: Failed to mark session $sessionId as done - ${failure.message}");
        emit(ExerciseFlowError("فشل تحديث حالة الجلسة: ${failure.message}"));
        Future.delayed(Duration(seconds: 3), () {
          if (state is ExerciseFlowError) {
            emit(ExerciseFlowFinished());
          }
        });
      },
          (success) {
        print("Cubit: Successfully marked session $sessionId as done.");
        if (state is! ExerciseFlowError) {
          emit(ExerciseFlowFinished());
        }
      },
    );
  }

  @override
  Future<void> close() {
    print("onClose -- ExerciseFlowCubit");
    return super.close();
  }
}