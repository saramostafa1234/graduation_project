// lib/cubit/exercise_flow_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfinalpro/core/errors/failures.dart';

import 'package:myfinalpro/monthly_test/test_detail.dart';
import 'package:myfinalpro/services/Api_services.dart';
import 'package:myfinalpro/services/asset_service.dart';
import 'package:flutter/material.dart'; // For debugPrint

import 'exercise_flow_state.dart';

// --- استيرادات جديدة للإشعارات ---
import '../models/notification_item.dart' as notif_model;
import '../services/notification_manager.dart';
import 'monthly_test_response.dart';


class ExerciseFlowCubit extends Cubit<ExerciseFlowState> {
  final ApiService apiService;
  final String randomAssetFolderPath;

  List<TestDetail> _detailsList = [];
  List<TestDetail> _newDetailsList = [];
  List<TestDetail> _combinedList = [];

  int? _mainSessionId;
  String? _monthlyTestTitle;
  int _currentStepIndex = -1;

  final int totalSteps = 4;

  ExerciseFlowCubit(this.apiService, {this.randomAssetFolderPath = 'assets/objects/'})
      : super(ExerciseFlowInitial()) {
    print("onCreate -- ExerciseFlowCubit");
  }

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
          (testResponse) async {
        _detailsList = testResponse.details;
        _newDetailsList = testResponse.newDetails;
        _combinedList = testResponse.getAllExercises();
        _mainSessionId = testResponse.sessionId;
        _monthlyTestTitle = testResponse.title;

        print(
            "Cubit: Fetched ${_detailsList.length} details, ${_newDetailsList.length} newDetails. Total: ${_combinedList.length}. Session ID: $_mainSessionId, Title: $_monthlyTestTitle");

        // --- إنشاء إشعار اختبار الشهر ---
        // سيتم استخدام testResponse.messageFromApi إذا كان موجودًا، وإلا سيتم بناء رسالة افتراضية
        String? effectiveMonthlyTestMessage = testResponse.messageFromApi;

        // إذا لم تكن هناك رسالة مباشرة من الـ API، ولكن لدينا عنوان للاختبار، نبني رسالة
        if ((effectiveMonthlyTestMessage == null || effectiveMonthlyTestMessage.isEmpty) &&
            _monthlyTestTitle != null && _monthlyTestTitle!.isNotEmpty) {
          effectiveMonthlyTestMessage = "قم بأداء اختبار الشهر لـ ${_monthlyTestTitle!}";
        }
        // إذا كان SessionId في الـ JSON الرئيسي للـ response (كما في مثالك)،
        // يمكن قراءته من testResponse.sessionId أيضًا.
        // int? testSessionIdForNotification = testResponse.sessionId; (هذا هو _mainSessionId بالفعل)


        if (effectiveMonthlyTestMessage != null && effectiveMonthlyTestMessage.isNotEmpty && _mainSessionId != null) {
          bool alreadySent = await NotificationManager.isMonthlyTestNotificationSent();
          if (!alreadySent) {
            await NotificationManager.addOrUpdateNotification(notif_model.NotificationItem(
              id: 'monthly_test_available_${_mainSessionId}',
              title: effectiveMonthlyTestMessage,
              timeAgo: notif_model.formatTimeAgo(DateTime.now()),
              createdAt: DateTime.now(),
              type: notif_model.NotificationType.monthlyTestAvailable,
            ));
            await NotificationManager.setMonthlyTestNotificationSent(true);
            debugPrint("ExerciseFlowCubit: Monthly test notification generated: $effectiveMonthlyTestMessage");
          }
        }
        // --- نهاية إنشاء الإشعار ---

        if (_detailsList.isEmpty) {
          print("Cubit Error: 'details' list is empty. Cannot proceed.");
          emit(ExerciseFlowError(
              "لا توجد بيانات أساسية (details) متاحة للاختبار."));
          return;
        }
        if (_newDetailsList.isEmpty && totalSteps > 2) {
          print(
              "Cubit Error: 'newDetails' list is empty, but needed for step 3. Cannot proceed with all steps.");
          emit(ExerciseFlowError(
              "لا توجد بيانات إضافية (newDetails) متاحة لإكمال جميع خطوات الاختبار."));
          return;
        }

        _currentStepIndex = -1;
        _prepareExerciseStep(0);
      },
    );
  }

  Future<void> _prepareExerciseStep(int stepIndex) async {
    if (stepIndex >= totalSteps) {
      await _completeSession(_mainSessionId);
      return;
    }
    if (stepIndex < 0) {
      emit(ExerciseFlowError("خطأ داخلي: رقم خطوة غير صالح."));
      return;
    }

    if (_detailsList.isEmpty || (_newDetailsList.isEmpty && stepIndex >= 2 && totalSteps > 2)) {
      print(
          "Cubit Error: Cannot prepare step $stepIndex, required lists are empty (_detailsList: ${_detailsList.length}, _newDetailsList: ${_newDetailsList.length}).");
      emit(ExerciseFlowError(
          "لا توجد بيانات كافية متاحة لتحضير الخطوة ${stepIndex + 1}."));
      return;
    }

    _currentStepIndex = stepIndex;
    final int detailsSize = _detailsList.length;
    final int newDetailsSize = _newDetailsList.isNotEmpty ? _newDetailsList.length : 0;
    print(
        "Cubit: Preparing step $stepIndex... (Details size: $detailsSize, NewDetails size: $newDetailsSize)");

    try {
      StepDisplayType displayType;
      String? question;
      DisplayItem item1;
      DisplayItem? item2;
      List<String> answerOptions = [];
      String correctAnswerIdentifier;

      TestDetail detailItem, newItem, primaryItem, secondaryItem;

      switch (stepIndex) {
        case 0:
          detailItem = _detailsList[0 % detailsSize];
          displayType = StepDisplayType.singleItemWithOptions;
          question = detailItem.question ?? "ما هو شعور هذا الشخص؟";
          item1 = _createDisplayItem(detailItem);
          answerOptions = detailItem.answerOptions;
          correctAnswerIdentifier = detailItem.rightAnswer ?? '';
          if (correctAnswerIdentifier.isEmpty || answerOptions.isEmpty) {
            throw Exception("بيانات الإجابات أو الخيارات مفقودة للخطوة 1.");
          }
          break;

        case 1:
          detailItem =
          _detailsList[1 % detailsSize];
          displayType = StepDisplayType.singleItemWithOptions;
          question = detailItem.question ?? "ما هو شعور هذا الشخص؟";
          item1 = _createDisplayItem(detailItem);
          answerOptions = detailItem.answerOptions;
          correctAnswerIdentifier = detailItem.rightAnswer ?? '';
          if (correctAnswerIdentifier.isEmpty || answerOptions.isEmpty) {
            throw Exception("بيانات الإجابات أو الخيارات مفقودة للخطوة 2.");
          }
          break;

        case 2:
          if (newDetailsSize == 0) {
            emit(ExerciseFlowError("لا توجد بيانات (newDetails) للخطوة 3."));
            return;
          }
          print("Cubit: Step 2 (Index 2) - Details vs NewDetails scenario.");
          detailItem = _detailsList[2 % detailsSize];
          newItem = _newDetailsList[0 % newDetailsSize];

          displayType = StepDisplayType.twoItemsChoice;
          question = detailItem.question ?? "اختر العنصر المناسب";
          item1 = _createDisplayItem(detailItem);
          item2 = _createDisplayItem(newItem);
          correctAnswerIdentifier = item1.identifier;

          if (item1.identifier == item2.identifier) {
            print(
                "Info: Items for step 2 might be the same (Details[${2 % detailsSize}] vs NewDetails[${0 % newDetailsSize}]). Identifier: '${item1.identifier}'.");
          }
          break;

        case 3:
          print("Cubit: Step 3 (Index 3) - Checking primary item type...");
          primaryItem = _detailsList[3 % detailsSize];
          final String primaryType =
              primaryItem.dataTypeOfContent?.toLowerCase() ?? 'img';

          if (primaryType == 'text') {
            print("Cubit: Step 3 (Index 3) - Text vs Text scenario.");
            secondaryItem = _detailsList[4 % detailsSize];

            displayType = StepDisplayType.twoItemsChoice;
            question = primaryItem.question ?? "اختر الموقف الصحيح";
            item1 = _createDisplayItem(primaryItem);
            item2 = _createDisplayItem(secondaryItem);
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
            print("Cubit: Step 3 (Index 3) - Image vs Random Asset scenario.");
            displayType = StepDisplayType.twoItemsChoice;
            question = primaryItem.question ?? "اختر الصورة الصحيحة";
            item1 = _createDisplayItem(primaryItem);
            correctAnswerIdentifier = item1.identifier;

            emit(ExerciseFlowLoadingDistractor());
            String? randomAssetPath;
            try {
              randomAssetPath =
              await _loadRandomObjectDistractor(randomAssetFolderPath);
              if (randomAssetPath == null) {
                throw Exception("فشل تحميل صورة المشتت العشوائية.");
              }
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
      print("Cubit Error preparing step $stepIndex: $e\n$s");
      emit(ExerciseFlowError("حدث خطأ أثناء تحضير الخطوة ${stepIndex + 1}: ${e.toString()}"));
    }
  }

  DisplayItem _createDisplayItem(TestDetail detail) {
    final String type =
    detail.dataTypeOfContent?.toLowerCase() == 'text' ? 'Text' : 'Img';
    String? content;
    String identifier;
    if (type == 'Img') {
      content = detail.localAssetPath;
      identifier = content ??
          'missing_image_${detail.detailId}_${DateTime.now().millisecondsSinceEpoch}';
      if (content == null) {
        print(
            "Warning (ExerciseFlowCubit): Image path is null for detailId ${detail.detailId}. Using placeholder identifier: $identifier");
      }
    } else {
      content = detail.textContent;
      identifier = content ??
          'missing_text_${detail.detailId}_${DateTime.now().millisecondsSinceEpoch}';
      if (content == null || content.trim().isEmpty) {
        print(
            "Warning (ExerciseFlowCubit): Text content is null or empty for detailId ${detail.detailId}. Using placeholder identifier: $identifier");
        content = "[نص غير متوفر]";
      }
    }
    return DisplayItem(type: type, content: content, identifier: identifier);
  }

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
      if (attempts < maxAttempts) {
        await Future.delayed(Duration(milliseconds: 150 * attempts));
      }
    }
    print(
        "Error: Failed to get a valid random asset path from '$folderPath' after $maxAttempts attempts.");
    return null;
  }

  void submitAnswer(String selectedIdentifier) {
    final currentState = state;
    print(
        "submitAnswer called with identifier: '$selectedIdentifier'. Current state type: ${currentState.runtimeType}");
    ExerciseStepLoaded? loadedState;
    if (currentState is ExerciseStepLoaded) {
      loadedState = currentState;
    } else if (currentState is ExerciseCorrectAnswer) {
      loadedState = currentState.previousState;
    } else if (currentState is ExerciseIncorrectAnswer){
      loadedState = currentState.previousState;
    }
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

  Future<void> _completeSession(int? sessionId) {
    if (sessionId == null) {
      if (state is! ExerciseFlowFinished) emit(ExerciseFlowFinished());
      return Future.value(); // Added to return Future
    }
    print("Cubit: Attempting to mark session (monthly test) $sessionId as complete...");
    if (state is! ExerciseFlowUpdatingSession) emit(ExerciseFlowUpdatingSession());

    return apiService.markSessionDone(sessionId).then((result) async { // Added async here
      result.fold(
            (failure) {
          emit(ExerciseFlowError("فشل تحديث حالة الاختبار الشهري: ${failure.message}"));
          Future.delayed(const Duration(seconds: 3), () {
            if (state is ExerciseFlowError || state is ExerciseFlowUpdatingSession) {
              emit(ExerciseFlowFinished());
            }
          });
        },
            (success) async {
          print("Cubit: Successfully marked session (monthly test) $sessionId as done.");
          await NotificationManager.removeNotificationByType(notif_model.NotificationType.monthlyTestAvailable);
          await NotificationManager.setMonthlyTestNotificationSent(false);
          debugPrint("ExerciseFlowCubit: Monthly test notification removed and flag reset.");
          if (state is! ExerciseFlowError && state is! ExerciseFlowFinished) {
            emit(ExerciseFlowFinished());
          }
        },
      );
    });
  }


  @override
  Future<void> close() {
    print("onClose -- ExerciseFlowCubit");
    return super.close();
  }
}