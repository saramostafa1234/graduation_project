// lib/cubit/exercise_flow_cubit.dart
import 'package:dartz/dartz.dart'; // For Either type
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfinalpro/core/errors/failures.dart'; // Ensure correct path for Failure
// Ensure correct path
import 'package:myfinalpro/monthly_test/test_detail.dart';
import 'package:myfinalpro/services/Api_services.dart'; // Ensure correct path
import 'package:myfinalpro/services/asset_service.dart'; // Ensure correct path for getRandomAssetPathFromFolder

import 'exercise_flow_state.dart';
import 'monthly_test_response.dart'; // Ensure correct path

class ExerciseFlowCubit extends Cubit<ExerciseFlowState> {
  final ApiService apiService;
  final String randomAssetFolderPath;

  // --- *** الاحتفاظ بالقوائم منفصلة *** ---
  List<TestDetail> _detailsList = [];
  List<TestDetail> _newDetailsList = [];

  // قائمة مدمجة للوصول السهل في بعض الحالات (إذا لزم الأمر لاحقًا أو للحسابات العامة)
  List<TestDetail> _combinedList = [];

  // --- *** نهاية التعديل *** ---

  int? _mainSessionId;
  int _currentStepIndex = -1;

  final int totalSteps = 4;

  ExerciseFlowCubit(this.apiService, {this.randomAssetFolderPath = 'assets/objects/'})
      : super(ExerciseFlowInitial()) {
    print("onCreate -- ExerciseFlowCubit");
  }

  // --- Fetching Initial Data (Modified to store lists separately) ---
  Future<void> fetchMonthlyTest() async {
    print("Cubit: Fetching monthly test...");
    emit(ExerciseFlowLoading());
    final Either<Failure, MonthlyTestResponse> result =
        await apiService.getMonthlyTestDetails();

    result.fold(
          (failure) {
        print("Cubit Error fetching test: ${failure.message}");
        emit(ExerciseFlowError("فشل تحميل الاختبار: ${failure.message}"));
      },
          (testResponse) {
        // --- *** تخزين القوائم منفصلة *** ---
        _detailsList = testResponse.details;
        _newDetailsList = testResponse.newDetails;
        _combinedList =
            testResponse.getAllExercises(); // لا نزال نحسبها للطول الكلي
        // --- *** نهاية التعديل *** ---

        _mainSessionId = testResponse.sessionId;
        print(
            "Cubit: Fetched ${_detailsList.length} details, ${_newDetailsList.length} newDetails. Total: ${_combinedList.length}. Session ID: $_mainSessionId");

        // --- *** التحقق من وجود عناصر في *كلتا* القائمتين الأساسيتين للخطوات 3 و 4 *** ---
            // نحتاج عنصر واحد على الأقل في details وعنصر واحد على الأقل في newDetails للخطوة 3
            // ونحتاج عنصر واحد على الأقل في details للخطوة 4
            if (_detailsList.isEmpty) {
              print("Cubit Error: 'details' list is empty. Cannot proceed.");
              emit(ExerciseFlowError(
                  "لا توجد بيانات أساسية (details) متاحة للاختبار."));
          return;
        }
        if (_newDetailsList.isEmpty && totalSteps > 2) {
          // Check if newDetails are needed for step 3 onwards
          print(
              "Cubit Error: 'newDetails' list is empty, but needed for step 3. Cannot proceed with all steps.");
          // يمكنك هنا إما إصدار خطأ، أو تعديل totalSteps ديناميكيًا
          // للتبسيط الآن، سنصدر خطأ إذا كانت newDetails فارغة ونحن نتوقع 4 خطوات
          emit(ExerciseFlowError(
              "لا توجد بيانات إضافية (newDetails) متاحة لإكمال جميع خطوات الاختبار."));
          return;
        }
        // --- *** نهاية التحقق الجديد *** ---

        _currentStepIndex = -1;
        _prepareExerciseStep(0); // البدء بالخطوة الأولى
      },
    );
  }

  // --- Preparing Data for Each Step (Using SEPARATE Lists and Modulo) ---
  Future<void> _prepareExerciseStep(int stepIndex) async {
    if (stepIndex >= totalSteps) {
      /* ... (نفس كود الإنهاء) ... */ await _completeSession(_mainSessionId);
      return;
    }
    if (stepIndex < 0) {
      /* ... (نفس كود الخطأ) ... */ emit(
          ExerciseFlowError("خطأ داخلي: رقم خطوة غير صالح."));
      return;
    }

    // --- التحقق الأساسي: هل القوائم المطلوبة فارغة؟ (تم التحقق جزئيًا في fetch) ---
    if (_detailsList.isEmpty || (_newDetailsList.isEmpty && stepIndex >= 2)) {
      print(
          "Cubit Error: Cannot prepare step $stepIndex, required lists are empty (_detailsList: ${_detailsList.length}, _newDetailsList: ${_newDetailsList.length}).");
      emit(ExerciseFlowError(
          "لا توجد بيانات كافية متاحة لتحضير الخطوة ${stepIndex + 1}."));
      return;
    }

    _currentStepIndex = stepIndex;
    final int detailsSize = _detailsList.length;
    final int newDetailsSize = _newDetailsList.length;
    print(
        "Cubit: Preparing step $stepIndex... (Details size: $detailsSize, NewDetails size: $newDetailsSize)");

    try {
      StepDisplayType displayType;
      String? question;
      DisplayItem item1;
      DisplayItem? item2;
      List<String> answerOptions = [];
      String correctAnswerIdentifier;

      // --- متغيرات لتخزين تفاصيل التمارين المطلوبة ---
      TestDetail detailItem, newItem, primaryItem, secondaryItem;

      // --- منطق كل خطوة مع استخدام القوائم المنفصلة ---
      switch (stepIndex) {
        case 0: // الخطوة 1: من details
          detailItem = _detailsList[0 % detailsSize]; // أول عنصر من details
          displayType = StepDisplayType.singleItemWithOptions;
          question = detailItem.question ?? "ما هو شعور هذا الشخص؟";
          item1 = _createDisplayItem(detailItem);
          answerOptions = detailItem.answerOptions;
          correctAnswerIdentifier = detailItem.rightAnswer ?? '';
          if (correctAnswerIdentifier.isEmpty || answerOptions.isEmpty)
            throw Exception("بيانات الإجابات أو الخيارات مفقودة للخطوة 1.");
          break;

        case 1: // الخطوة 2: من details
          detailItem =
              _detailsList[1 % detailsSize]; // ثاني عنصر من details (مع التفاف)
          displayType = StepDisplayType.singleItemWithOptions;
          question = detailItem.question ?? "ما هو شعور هذا الشخص؟";
          item1 = _createDisplayItem(detailItem);
          answerOptions = detailItem.answerOptions;
          correctAnswerIdentifier = detailItem.rightAnswer ?? '';
          if (correctAnswerIdentifier.isEmpty || answerOptions.isEmpty)
            throw Exception("بيانات الإجابات أو الخيارات مفقودة للخطوة 2.");
          break;

        case 2: // الخطوة 3: *** Details vs NewDetails ***
          print("Cubit: Step 2 (Index 2) - Details vs NewDetails scenario.");
          detailItem = _detailsList[
              2 % detailsSize]; // العنصر الصحيح من details (التفاف)
          newItem = _newDetailsList[0 %
              newDetailsSize]; // العنصر المشتت من newDetails (أول عنصر مع التفاف)

          displayType = StepDisplayType.twoItemsChoice;
          question = detailItem.question ??
              "اختر العنصر المناسب"; // سؤال من العنصر الأول
          item1 = _createDisplayItem(detailItem); // Item 1 هو الصحيح
          item2 = _createDisplayItem(newItem); // Item 2 هو المشتت
          correctAnswerIdentifier = item1.identifier;

          // Check if items are identical (less likely now, but possible if content matches)
          if (item1.identifier == item2.identifier) {
            print(
                "Info: Items for step 2 might be the same (Details[${2 % detailsSize}] vs NewDetails[${0 % newDetailsSize}]). Identifier: '${item1.identifier}'.");
          }
          break;

        case 3: // الخطوة 4: *** Text vs Text OR Img vs Random Asset ***
          print("Cubit: Step 3 (Index 3) - Checking primary item type...");
          primaryItem = _detailsList[
              3 % detailsSize]; // العنصر الأساسي من details (التفاف)
          final String primaryType =
              primaryItem.dataTypeOfContent?.toLowerCase() ?? 'img';

          if (primaryType == 'text') {
            // --- Scenario: Text vs Text ---
            print("Cubit: Step 3 (Index 3) - Text vs Text scenario.");
            // نستخدم عنصرًا آخر من details كمشتت نصي (يمكن استخدام newDetails إذا أردت)
            secondaryItem = _detailsList[
                4 % detailsSize]; // العنصر التالي من details (التفاف)

            displayType = StepDisplayType.twoItemsChoice;
            question = primaryItem.question ?? "اختر الموقف الصحيح";
            item1 = _createDisplayItem(primaryItem); // النص الأساسي هو الصحيح
            item2 = _createDisplayItem(secondaryItem); // النص الثانوي هو المشتت
            correctAnswerIdentifier = item1.identifier;

            if (secondaryItem.dataTypeOfContent?.toLowerCase() != 'text') {
              print(
                  "Warning: Step 3 (Index 3) - Expected Text vs Text, but secondary item (details index ${4 % detailsSize}) is type '${secondaryItem.dataTypeOfContent}'. Displaying it anyway.");
            }
            if (item1.identifier == item2.identifier) {
              print(
                  "Info: Text items for step 3 might be the same due to list wrapping (details indices ${3 % detailsSize} & ${4 % detailsSize}). Identifier: '${item1.identifier}'.");
            }
          } else {
            // --- Scenario: Img vs Random Asset ---
            print("Cubit: Step 3 (Index 3) - Image vs Random Asset scenario.");
            displayType = StepDisplayType.twoItemsChoice;
            question = primaryItem.question ?? "اختر الصورة الصحيحة";
            item1 =
                _createDisplayItem(primaryItem); // صورة الباك اند هي الصحيحة
            correctAnswerIdentifier = item1.identifier;

            // تحميل صورة عشوائية
            emit(ExerciseFlowLoadingDistractor());
            String? randomAssetPath;
            try {
              randomAssetPath =
                  await _loadRandomObjectDistractor(randomAssetFolderPath);
              if (randomAssetPath == null)
                throw Exception("فشل تحميل صورة المشتت العشوائية.");
              print("Cubit: Random asset loaded for step 3: $randomAssetPath");
              item2 = DisplayItem(
                  type: 'Img',
                  content: randomAssetPath,
                  identifier: randomAssetPath);

              if (item1.identifier == item2.identifier) {
                print(
                    "Warning: Random asset is the same as backend image for step 3 ('${item1.identifier}').");
              }
            } catch (e) {
              print("Cubit Error loading random asset: $e");
              emit(ExerciseFlowError(
                  "خطأ أثناء تحميل الصورة العشوائية: ${e.toString()}"));
              return;
            }
          }
          break;

        default:
          throw Exception("رقم خطوة غير صالح: $stepIndex");
      }

      // --- إصدار حالة ExerciseStepLoaded ---
      emit(ExerciseStepLoaded(
        currentStepIndex: stepIndex,
        displayType: displayType,
        question: question,
        mainSessionId: _mainSessionId,
        item1: item1,
        item2: item2,
        answerOptions: answerOptions,
        correctAnswerIdentifier: correctAnswerIdentifier,
      ));
      print(
          "Cubit: Emitted ExerciseStepLoaded for step $stepIndex. Type: $displayType");
    } catch (e, s) {
      // --- التعامل مع أي خطأ ---
      print("Cubit Error preparing step $stepIndex: $e\n$s");
      emit(ExerciseFlowError("حدث خطأ أثناء تحضير الخطوة ${stepIndex + 1}: ${e.toString()}"));
    }
  }

  // --- Helper function to create DisplayItem from TestDetail ---
  // (No changes needed)
  DisplayItem _createDisplayItem(TestDetail detail) {
    final String type =
        detail.dataTypeOfContent?.toLowerCase() == 'text' ? 'Text' : 'Img';
    String? content;
    String identifier;
    if (type == 'Img') {
      content = detail.localAssetPath;
      identifier = content ??
          'missing_image_${detail.detailId}_${DateTime.now().millisecondsSinceEpoch}';
      if (content == null)
        print(
            "Warning: Image path is null for detailId ${detail.detailId}. Using placeholder identifier: $identifier");
    } else {
      // Text
      content = detail.textContent;
      identifier = content ??
          'missing_text_${detail.detailId}_${DateTime.now().millisecondsSinceEpoch}';
      if (content == null || content.trim().isEmpty) {
        print(
            "Warning: Text content is null or empty for detailId ${detail.detailId}. Using placeholder identifier: $identifier");
        content = "[نص غير متوفر]";
      }
    }
    return DisplayItem(type: type, content: content, identifier: identifier);
  }

  // --- Helper function to load a random asset image path ---
  // (No changes needed)
  Future<String?> _loadRandomObjectDistractor(String folderPath) async {
    String? randomPath;
    int attempts = 0;
    const int maxAttempts = 5;
    while (attempts < maxAttempts) {
      try {
        randomPath = await getRandomAssetPathFromFolder(folderPath);
      } catch (e, s) {
        print("Error in getRandomAssetPathFromFolder: $e\n$s");
        return null;
      }
      print("Distractor load attempt ${attempts + 1}: Got path '$randomPath' from folder '$folderPath'");
      if (randomPath != null &&
          randomPath.isNotEmpty &&
          randomPath.contains('/') &&
          randomPath.contains('.')) {
        return randomPath;
      } else if (randomPath != null) {
        print(
            "Warning: getRandomAssetPathFromFolder returned potentially invalid path: '$randomPath'");
      }
      attempts++;
      if (attempts < maxAttempts)
        await Future.delayed(Duration(milliseconds: 150 * attempts));
    }
    print(
        "Error: Failed to get a valid random asset path from '$folderPath' after $maxAttempts attempts.");
    return null;
  }

  // --- Handle User Answer Submission ---
  // (No changes needed)
  void submitAnswer(String selectedIdentifier) {
    final currentState = state;
    print(
        "submitAnswer called with identifier: '$selectedIdentifier'. Current state type: ${currentState.runtimeType}");
    ExerciseStepLoaded? loadedState;
    if (currentState is ExerciseStepLoaded)
      loadedState = currentState;
    else if (currentState is ExerciseIncorrectAnswer)
      loadedState = currentState.previousState;
    else {
      print(
          "Cubit: submitAnswer called in an invalid state (${currentState.runtimeType}). Ignoring.");
      return;
    }
    final String correctAnswerId = loadedState.correctAnswerIdentifier;
    print(
        "Cubit: Step ${loadedState.currentStepIndex} - Selected ID: '$selectedIdentifier', Correct ID: '$correctAnswerId'");
    bool isCorrect = (selectedIdentifier == correctAnswerId);
    if (isCorrect) {
      print("Cubit: Correct answer!");
      emit(ExerciseCorrectAnswer(loadedState));
    } else {
      print("Cubit: Incorrect answer.");
      emit(ExerciseIncorrectAnswer(loadedState));
    }
  }

  // --- Allow User to Retry the Current Step After Incorrect Answer ---
  // (No changes needed)
  void retryCurrentStep() {
    if (state is ExerciseIncorrectAnswer) {
      final incorrectState = state as ExerciseIncorrectAnswer;
      print("Cubit: Retrying step ${incorrectState.previousState.currentStepIndex}");
      emit(incorrectState.previousState);
    } else {
      print(
          "Cubit: retryCurrentStep called in invalid state (${state.runtimeType})");
    }
  }

  // --- Proceed to the Next Step After Correct Answer ---
  // (No changes needed)
  void proceedToNextExercise() {
    if (state is ExerciseCorrectAnswer) {
      final correctState = state as ExerciseCorrectAnswer;
      final nextStepIndex = correctState.previousState.currentStepIndex + 1;
      print(
          "Proceeding from CorrectAnswer state. Current step: ${correctState.previousState.currentStepIndex}, Next step: $nextStepIndex");
      _prepareExerciseStep(nextStepIndex);
    } else {
      print(
          "Warning: proceedToNextExercise called in unexpected state: ${state.runtimeType}");
    }
  }

  // --- Mark Session as Done via API After Last Step ---
  // (No changes needed - assuming ApiService uses PUT / SessionController)
  Future<void> _completeSession(int? sessionId) async {
    if (sessionId == null) {
      /* ... (handle null session id) ... */ if (state is! ExerciseFlowFinished)
        emit(ExerciseFlowFinished());
      return;
    }
    print("Cubit: Attempting to mark session $sessionId as complete...");
    if (state is! ExerciseFlowUpdatingSession)
      emit(ExerciseFlowUpdatingSession());
    final Either<Failure, bool> result =
        await apiService.markSessionDone(sessionId);
    result.fold(
      (failure) {
        /* ... (handle failure) ... */ emit(
            ExerciseFlowError("فشل تحديث حالة الجلسة: ${failure.message}"));
        Future.delayed(const Duration(seconds: 3), () {
          if (state is ExerciseFlowError ||
              state is ExerciseFlowUpdatingSession)
            emit(ExerciseFlowFinished());
        });
      },
      (success) {
        /* ... (handle success) ... */ print(
            "Cubit: Successfully marked session $sessionId as done.");
        if (state is! ExerciseFlowError && state is! ExerciseFlowFinished)
          emit(ExerciseFlowFinished());
      },
    );
  }

  // --- Cubit Cleanup Logic ---
  @override
  Future<void> close() {
    print("onClose -- ExerciseFlowCubit");
    return super.close();
  }
} // End of ExerciseFlowCubit class