// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:confetti/confetti.dart';
//
// // تأكد من أن مسارات الاستيراد هذه صحيحة في مشروعك
// import 'test_group_model.dart';
// import 'package:myfinalpro/services/Api_services.dart';
// import 'package:myfinalpro/screens/common/loading_indicator.dart';
// import 'package:myfinalpro/screens/home_screen.dart';
// import 'group_test_question_display_screen.dart';
//
// // GeneratedQuestion class
// class GeneratedQuestion {
//   final String questionText;
//   final List<String> options; // للخيار النصي أو كقيم مرتبطة بالصور
//   final String correctAnswer;
//   final String? imagePath1;
//   final String? textContent1;
//   final String? imagePath2;
//   final String? textContent2;
//   final bool isTwoElements;
//   final String? mainItemName;
//   final String? secondItemName;
//   final int originalDetailId;
//   final String sectionTitle;
//   final bool isImageOptions;
//   final List<String?> optionImagePaths;
//
//   GeneratedQuestion({
//     required this.questionText,
//     required this.options,
//     required this.correctAnswer,
//     required this.originalDetailId,
//     required this.sectionTitle,
//     this.imagePath1,
//     this.textContent1,
//     this.imagePath2,
//     this.textContent2,
//     this.isTwoElements = false,
//     this.mainItemName,
//     this.secondItemName,
//     this.isImageOptions = false,
//     this.optionImagePaths = const [],
//   });
// }
//
// class GroupTestManagerScreen extends StatefulWidget {
//   final TestGroupResponse testGroupData;
//   final String jwtToken;
//
//   const GroupTestManagerScreen({
//     super.key,
//     required this.testGroupData,
//     required this.jwtToken,
//   });
//
//   @override
//   State<GroupTestManagerScreen> createState() => _GroupTestManagerScreenState();
// }
//
// class _GroupTestManagerScreenState extends State<GroupTestManagerScreen> {
//   int _currentGlobalQuestionIndex = 0;
//   List<GeneratedQuestion> _allGeneratedQuestions = [];
//
//   bool _isLoadingScreen = true;
//   bool _isProcessingAnswer = false;
//   bool _isCompletingGroup = false;
//   int _totalCorrectAnswers = 0;
//
//   List<String> _objectImagePaths = [];
//   final Random _random = Random();
//   int _buildCount = 0;
//
//   late ConfettiController _confettiController;
//
//   void setStateIfMounted(VoidCallback fn) {
//     if (mounted) {
//       setState(fn);
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _confettiController = ConfettiController(duration: const Duration(milliseconds: 800));
//     debugPrint("GroupTestManager: initState - Screen Initializing. Total Sessions: ${widget.testGroupData.sessions.length}");
//     _initializeScreen();
//   }
//
//   @override
//   void dispose() {
//     _confettiController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _initializeScreen() async {
//     setStateIfMounted(() => _isLoadingScreen = true);
//     await _loadObjectImagePaths();
//     _generateAllQuestionsAndSetState();
//   }
//
//   Future<void> _loadObjectImagePaths() async {
//     try {
//       const String objectsFolderPath = 'assets/objects/';
//       final manifestContent = await rootBundle.loadString('AssetManifest.json');
//       final Map<String, dynamic> manifestMap = json.decode(manifestContent);
//       _objectImagePaths = manifestMap.keys
//           .where((String key) =>
//       key.startsWith(objectsFolderPath) &&
//           key != objectsFolderPath &&
//           (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg') || key.endsWith('.gif') || key.endsWith('.webp')))
//           .toList();
//       debugPrint("GroupTestManager: Loaded ${_objectImagePaths.length} random object images from $objectsFolderPath");
//       if (_objectImagePaths.isEmpty) {
//         debugPrint("GroupTestManager: Warning - No images found in $objectsFolderPath. Random image questions might be affected.");
//       }
//     } catch (e) {
//       debugPrint("GroupTestManager: Error loading object image paths: $e");
//       _objectImagePaths = [];
//     }
//   }
//
//   String? _getRandomObjectImagePath() {
//     if (_objectImagePaths.isEmpty) return null;
//     return _objectImagePaths[_random.nextInt(_objectImagePaths.length)];
//   }
//
//   void _generateAllQuestionsAndSetState() {
//     if (!mounted) return;
//     if (!_isLoadingScreen && _currentGlobalQuestionIndex == 0) {
//       setStateIfMounted(() => _isLoadingScreen = true);
//     }
//
//     List<GeneratedQuestion> allQuestionsCollector = [];
//     final String mainGroupNameFromResponse = widget.testGroupData.groupName;
//     debugPrint("GroupTestManager: Generating ALL questions for group: $mainGroupNameFromResponse. Total sessions: ${widget.testGroupData.sessions.length}");
//
//     for (int sessionIdx = 0; sessionIdx < widget.testGroupData.sessions.length; sessionIdx++) {
//       final currentSession = widget.testGroupData.sessions[sessionIdx];
//       final String currentSessionTitle = currentSession.title.isNotEmpty ? currentSession.title : mainGroupNameFromResponse;
//       debugPrint("  Processing Session ${sessionIdx + 1}: $currentSessionTitle");
//
//       if (sessionIdx == 0 && currentSession.title.contains("فهم")) {
//         debugPrint("    This is 'Fahm' section.");
//         final detailsForFahm = currentSession.details;
//         final newDetailForFahm = currentSession.newDetail;
//
//         // السؤال 1 (خيارات نصية)
//         if (detailsForFahm.isNotEmpty) {
//           final detail0 = detailsForFahm[0];
//           allQuestionsCollector.add(GeneratedQuestion(
//             originalDetailId: detail0.detailId, sectionTitle: currentSessionTitle,
//             questionText: detail0.questions ?? "ما هو الشعور الظاهر؟",
//             options: detail0.answerOptions.isNotEmpty ? detail0.answerOptions : ["فارغ1", "فارغ2"],
//             correctAnswer: detail0.rightAnswer.isNotEmpty ? detail0.rightAnswer : (detail0.answerOptions.isNotEmpty ? detail0.answerOptions[0] : "فارغ1"),
//             imagePath1: detail0.localAssetPath, textContent1: detail0.textContent, mainItemName: mainGroupNameFromResponse,
//             isImageOptions: false, optionImagePaths: [],
//           ));
//           debugPrint("      Fahm Q1: '${allQuestionsCollector.last.questionText}' (original detailId: ${detail0.detailId})");
//         } else { debugPrint("      Fahm Q1: SKIPPED - No details[0] for Fahm section."); }
//
//         // السؤال 2 (خيارات صور)
//         if (detailsForFahm.length >= 2 && newDetailForFahm.detailId != 0) {
//           final detail1 = detailsForFahm[1];
//           List<String?> imageOptPathsQ2 = [];
//           List<String> imageOptValuesQ2 = [];
//
//           if (detail1.localAssetPath != null) {
//             imageOptPathsQ2.add(detail1.localAssetPath);
//             imageOptValuesQ2.add(detail1.rightAnswer); // القيمة النصية للصورة الأولى
//           }
//           if (newDetailForFahm.localAssetPath != null) {
//             imageOptPathsQ2.add(newDetailForFahm.localAssetPath);
//             imageOptValuesQ2.add(newDetailForFahm.rightAnswer); // القيمة النصية للصورة الثانية
//           }
//
//           if (imageOptPathsQ2.length == 2) {
//             allQuestionsCollector.add(GeneratedQuestion(
//               originalDetailId: detail1.detailId, sectionTitle: currentSessionTitle,
//               questionText: "من يكون $mainGroupNameFromResponse؟",
//               options: imageOptValuesQ2, // هذه هي القيم النصية المرتبطة بالصور للمقارنة
//               correctAnswer: detail1.rightAnswer, // الإجابة الصحيحة هي قيمة الصورة الأولى (detail1)
//               imagePath1: detail1.localAssetPath, textContent1: detail1.textContent,
//               imagePath2: newDetailForFahm.localAssetPath, textContent2: newDetailForFahm.textContent,
//               isTwoElements: true, mainItemName: mainGroupNameFromResponse, secondItemName: newDetailForFahm.groupName ?? "الكائن الآخر",
//               isImageOptions: true, optionImagePaths: imageOptPathsQ2,
//             ));
//             debugPrint("      Fahm Q2 (Image Options): '${allQuestionsCollector.last.questionText}' (original detailId: ${detail1.detailId}, newDetail used: ${newDetailForFahm.detailId})");
//           } else { debugPrint("      Fahm Q2: SKIPPED - Not enough image paths for image options (expected 2, got ${imageOptPathsQ2.length}).");}
//         } else { debugPrint("      Fahm Q2: SKIPPED - Not enough details for Q2 or invalid newDetail. Details count: ${detailsForFahm.length}, newDetailId: ${newDetailForFahm.detailId}"); }
//
//         // السؤال 3 (خيارات صور)
//         if (detailsForFahm.length >= 3) {
//           final detail2 = detailsForFahm[2];
//           final randomImagePath = _getRandomObjectImagePath();
//           List<String?> imageOptPathsQ3 = [];
//           List<String> imageOptValuesQ3 = [];
//
//           if (detail2.localAssetPath != null) {
//             imageOptPathsQ3.add(detail2.localAssetPath);
//             imageOptValuesQ3.add(detail2.rightAnswer); // القيمة النصية للصورة الأولى
//           }
//           if (randomImagePath != null) {
//             imageOptPathsQ3.add(randomImagePath);
//             imageOptValuesQ3.add("random_image_placeholder_value"); // قيمة فريدة لا تطابق الإجابة الصحيحة
//           }
//
//           if (imageOptPathsQ3.length == 2) {
//             allQuestionsCollector.add(GeneratedQuestion(
//               originalDetailId: detail2.detailId, sectionTitle: currentSessionTitle,
//               questionText: "من يكون $mainGroupNameFromResponse؟",
//               options: imageOptValuesQ3, // القيم النصية المرتبطة بالصور
//               correctAnswer: detail2.rightAnswer, // الإجابة الصحيحة هي قيمة الصورة الأولى (detail2)
//               imagePath1: detail2.localAssetPath, textContent1: detail2.textContent,
//               imagePath2: randomImagePath, isTwoElements: true,
//               mainItemName: mainGroupNameFromResponse, secondItemName: "الكائن العشوائي",
//               isImageOptions: true, optionImagePaths: imageOptPathsQ3,
//             ));
//             debugPrint("      Fahm Q3 (Image Options): '${allQuestionsCollector.last.questionText}' (original detailId: ${detail2.detailId})");
//           } else { debugPrint("      Fahm Q3: SKIPPED - Not enough image paths for image options (expected 2, got ${imageOptPathsQ3.length}).");}
//         } else { debugPrint("      Fahm Q3: SKIPPED - Not enough details for Q3. Details count: ${detailsForFahm.length}"); }
//       } else { // الأقسام الأخرى أو قسم الفهم إذا لم ينطبق الشرط الأول
//         debugPrint("    This is another section or Fahm section didn't meet special criteria: ${currentSession.title}");
//         int questionsAddedForThisSection = 0;
//         int detailLoopStartIndex = (sessionIdx == 0 && currentSession.title.contains("فهم")) ? 3 : 0;
//         if (sessionIdx == 0 && currentSession.title.contains("فهم") && currentSession.details.length < 3) {
//           detailLoopStartIndex = currentSession.details.length;
//         }
//
//         for (int i = detailLoopStartIndex; i < currentSession.details.length && questionsAddedForThisSection < 3; i++) {
//           final detail = currentSession.details[i];
//           allQuestionsCollector.add(GeneratedQuestion(
//             originalDetailId: detail.detailId, sectionTitle: currentSessionTitle,
//             questionText: detail.questions ?? "بماذا يشعر هذا الشخص؟",
//             options: detail.answerOptions.isNotEmpty ? detail.answerOptions : ["فارغ1", "فارغ2"],
//             correctAnswer: detail.rightAnswer.isNotEmpty ? detail.rightAnswer : (detail.answerOptions.isNotEmpty ? detail.answerOptions[0] : "فارغ1"),
//             imagePath1: detail.localAssetPath, textContent1: detail.textContent,
//             mainItemName: mainGroupNameFromResponse,
//             isImageOptions: false, optionImagePaths: [], // خيارات نصية هنا
//           ));
//           questionsAddedForThisSection++;
//           debugPrint("      Other/Remaining Section Q${questionsAddedForThisSection} (from session ${sessionIdx+1}): '${allQuestionsCollector.last.questionText}' (original detailId: ${detail.detailId})");
//         }
//         if (questionsAddedForThisSection == 0 && currentSession.details.isEmpty && detailLoopStartIndex == 0) {
//           debugPrint("      No details to process for session '${currentSession.title}'.");
//         } else if (questionsAddedForThisSection < 3) {
//           debugPrint("      Warning: Section '${currentSession.title}' provided only $questionsAddedForThisSection normal questions (expected up to 3).");
//         }
//       }
//     } // نهاية حلقة الأقسام
//
//     setStateIfMounted(() {
//       _allGeneratedQuestions = allQuestionsCollector;
//       _currentGlobalQuestionIndex = 0;
//       _isLoadingScreen = false;
//       debugPrint("GroupTestManager: setState after generating ALL questions. Total Qs: ${_allGeneratedQuestions.length}, isLoadingScreen: $_isLoadingScreen");
//       if (_allGeneratedQuestions.isEmpty && mounted && !_isCompletingGroup) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if(mounted && !_isCompletingGroup) _completeTestGroup(showError: true);
//         });
//       }
//     });
//   }
//
//   Future<void> _showInternalSuccessDialog() async {
//     if (!mounted) return;
//     _confettiController.play();
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: Stack(alignment: Alignment.topCenter, children: [
//             ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive, shouldLoop: false, numberOfParticles: 20, gravity: 0.1, emissionFrequency: 0.03, colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple]),
//             const Padding(padding: EdgeInsets.only(top: 10.0), child: Text('🎉 أحسنت!', style: TextStyle(fontFamily: 'Cairo', color: Color(0xff2C73D9), fontWeight: FontWeight.bold, fontSize: 22))),
//           ]),
//           content: const Text('إجابة صحيحة.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: <Widget>[
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2C73D9), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10), textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
//               child: const Text('التالي'),
//               onPressed: () {
//                 if (_confettiController.state == ConfettiControllerState.playing) _confettiController.stop();
//                 Navigator.of(dialogContext).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _handleAnswer(bool isCorrect) {
//     if (_isLoadingScreen || _isProcessingAnswer || _isCompletingGroup) return;
//     setStateIfMounted(() => _isProcessingAnswer = true);
//     debugPrint("GroupTestManager: _handleAnswer called. isCorrect: $isCorrect. GlobalQ_idx: $_currentGlobalQuestionIndex. _isProcessingAnswer SET TO TRUE.");
//
//     if (isCorrect) {
//       _totalCorrectAnswers++;
//       debugPrint("GroupTestManager: Correct answer. Total correct: $_totalCorrectAnswers.");
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _showInternalSuccessDialog().then((_) {
//             debugPrint("GroupTestManager: _showInternalSuccessDialog().then() - Dialog is now closed. Calling _advanceToNextGlobalQuestion.");
//             _advanceToNextGlobalQuestion();
//             if (mounted) setStateIfMounted(() { _isProcessingAnswer = false; debugPrint("GroupTestManager: _handleAnswer (Success path) - _isProcessingAnswer set to false AFTER dialog and advance."); });
//           }).catchError((error){
//             debugPrint("GroupTestManager: Error after _showInternalSuccessDialog: $error");
//             if (mounted) { setStateIfMounted(() => _isProcessingAnswer = false); }
//           });
//         } else {
//           _isProcessingAnswer = false;
//         }
//       });
//     } else {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("إجابة خاطئة، حاول مرة أخرى!"), backgroundColor: Colors.redAccent, duration: Duration(seconds: 1)));
//       if (mounted) setStateIfMounted(() { _isProcessingAnswer = false; debugPrint("GroupTestManager: _handleAnswer (Incorrect path) - _isProcessingAnswer set to false."); });
//     }
//   }
//
//   void _advanceToNextGlobalQuestion() {
//     if (!mounted) return;
//     debugPrint("GroupTestManager: _advanceToNextGlobalQuestion - Current Global Q_idx: $_currentGlobalQuestionIndex, Total Qs: ${_allGeneratedQuestions.length}");
//     int newGlobalIndex = _currentGlobalQuestionIndex + 1;
//     if (newGlobalIndex >= _allGeneratedQuestions.length) {
//       debugPrint("  All global questions completed. Preparing to call _completeTestGroup.");
//       if (!_isCompletingGroup) {
//         WidgetsBinding.instance.addPostFrameCallback((_) { if(mounted && !_isCompletingGroup) _completeTestGroup(); });
//       }
//     } else {
//       debugPrint("  Moved to next global question. New Global Q_idx: $newGlobalIndex");
//       setStateIfMounted(() { _currentGlobalQuestionIndex = newGlobalIndex; });
//     }
//   }
//
//   Future<void> _completeTestGroup({bool showError = false}) async {
//     if (!mounted || _isCompletingGroup) return;
//     setStateIfMounted(() => _isCompletingGroup = true);
//     debugPrint("All test group questions completed. GroupID: ${widget.testGroupData.groupId}. Total correct: $_totalCorrectAnswers. Marking group as done. ShowError: $showError");
//     bool success = false;
//     if (!showError) { success = await ApiService.markTestGroupDone(widget.jwtToken, widget.testGroupData.groupId); }
//     if (mounted) {
//       String title = showError ? "خطأ في الاختبار" : (success ? "اختبار مكتمل" : "خطأ في الحفظ");
//       String content = showError ? "لم يتم تحميل أسئلة الاختبار بشكل صحيح." : (success ? "أحسنت! لقد أكملت اختبار الـ 3 شهور بنجاح." : "حدث خطأ أثناء حفظ نتيجة الاختبار.");
//       await showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(title: Text(title, style: const TextStyle(fontFamily: 'Cairo')), content: Text(content, style: const TextStyle(fontFamily: 'Cairo')), actions: [TextButton(onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const HomeScreen()), (Route<dynamic> route) => false); }, child: const Text("العودة للرئيسية", style: TextStyle(fontFamily: 'Cairo')))]));
//     }
//     if (mounted && _isCompletingGroup) { setStateIfMounted(() => _isCompletingGroup = false); }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _buildCount++;
//     debugPrint("GroupTestManager BUILD #$_buildCount: isLoadingScreen: $_isLoadingScreen, GlobalQ_idx: $_currentGlobalQuestionIndex, TotalGenQs: ${_allGeneratedQuestions.length}, isCompletingGroup: $_isCompletingGroup, isProcessingAns: $_isProcessingAnswer");
//
//     if (_isLoadingScreen) {
//       return Scaffold(
//         appBar: AppBar(title: Text(widget.testGroupData.groupName, style: const TextStyle(fontFamily: 'Cairo'))),
//         body: const LoadingIndicator(message: "جاري تجهيز أسئلة اختبار الـ 3 شهور..."),
//       );
//     }
//
//     if (_isCompletingGroup) {
//       return Scaffold(
//           appBar: AppBar(title: Text(widget.testGroupData.groupName, style: const TextStyle(fontFamily: 'Cairo'))),
//           body: const LoadingIndicator(message: "جاري إنهاء الاختبار...")
//       );
//     }
//
//     if (_allGeneratedQuestions.isEmpty) {
//       debugPrint("GroupTestManager: Build - _allGeneratedQuestions is EMPTY. This is critical.");
//       if (!_isCompletingGroup) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if(mounted && !_isCompletingGroup) _completeTestGroup(showError: true);
//         });
//       }
//       return Scaffold(
//         appBar: AppBar(title: Text(widget.testGroupData.groupName, style: const TextStyle(fontFamily: 'Cairo'))),
//         body: const Center(child: Text("لا توجد أسئلة تم توليدها.", style: TextStyle(fontFamily: 'Cairo'))),
//       );
//     }
//
//     if (_currentGlobalQuestionIndex >= _allGeneratedQuestions.length) {
//       debugPrint("GroupTestManager: Build - Index out of bounds but list is not empty. Likely test completion path.");
//       if (!_isCompletingGroup) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if(mounted && !_isCompletingGroup) _completeTestGroup();
//         });
//       }
//       return Scaffold(
//           appBar: AppBar(title: Text("إنهاء الاختبار", style: const TextStyle(fontFamily: 'Cairo'))),
//           body: const LoadingIndicator(message: "جاري إنهاء الاختبار...")
//       );
//     }
//
//     final currentGeneratedQuestion = _allGeneratedQuestions[_currentGlobalQuestionIndex];
//     final String appBarTitle = "${currentGeneratedQuestion.sectionTitle} (${_currentGlobalQuestionIndex + 1}/${_allGeneratedQuestions.length})";
//
//     return GroupTestQuestionDisplayScreen(
//       key: ValueKey('group_q_global_${_currentGlobalQuestionIndex}_${currentGeneratedQuestion.originalDetailId}_build$_buildCount'),
//       appBarTitle: appBarTitle,
//       question: currentGeneratedQuestion,
//       isLoading: _isProcessingAnswer || _isCompletingGroup || _isLoadingScreen,
//       onAnswerSelected: _handleAnswer,
//     );
//   }
// }
// lib/test3months/group_test_manager_screen.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:confetti/confetti.dart';

import 'test_group_model.dart';
import 'package:myfinalpro/services/Api_services.dart';
import 'package:myfinalpro/screens/common/loading_indicator.dart';
import 'package:myfinalpro/screens/home_screen.dart';
import 'group_test_question_display_screen.dart';

// --- استيرادات جديدة للإشعارات ---
import 'package:myfinalpro/models/notification_item.dart' as notif_model;
import 'package:myfinalpro/services/notification_manager.dart';

class GeneratedQuestion {
  final String questionText;
  final List<String> options; // للخيار النصي أو كقيم مرتبطة بالصور
  final String correctAnswer;
  final String? imagePath1;
  final String? textContent1;
  final String? imagePath2;
  final String? textContent2;
  final bool isTwoElements;
  final String? mainItemName;
  final String? secondItemName;
  final int originalDetailId; // ID السؤال الأصلي من TestQuestionDetail
  final String sectionTitle; // عنوان القسم (مثل "فهم"، "تعبير"، إلخ)
  final bool isImageOptions; // هل الخيارات هي صور؟
  final List<String?> optionImagePaths; // مسارات الصور إذا كانت الخيارات صورًا

  GeneratedQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.originalDetailId,
    required this.sectionTitle,
    this.imagePath1,
    this.textContent1,
    this.imagePath2,
    this.textContent2,
    this.isTwoElements = false,
    this.mainItemName,
    this.secondItemName,
    this.isImageOptions = false,
    this.optionImagePaths = const [],
  });
}

class GroupTestManagerScreen extends StatefulWidget {
  final TestGroupResponse testGroupData;
  final String jwtToken;

  const GroupTestManagerScreen({
    super.key,
    required this.testGroupData,
    required this.jwtToken,
  });

  @override
  State<GroupTestManagerScreen> createState() => _GroupTestManagerScreenState();
}

class _GroupTestManagerScreenState extends State<GroupTestManagerScreen> {
  int _currentGlobalQuestionIndex = 0;
  List<GeneratedQuestion> _allGeneratedQuestions = [];

  bool _isLoadingScreen = true;
  bool _isProcessingAnswer = false;
  bool _isCompletingGroup = false;
  int _totalCorrectAnswers = 0;

  List<String> _objectImagePaths = []; // مسارات الصور العشوائية
  final Random _random = Random();
  int _buildCount = 0; // لتتبع عدد مرات بناء الواجهة (للتصحيح)

  late ConfettiController _confettiController;

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 800));
    debugPrint("GroupTestManager: initState - Screen Initializing. GroupID: ${widget.testGroupData.groupId}, GroupName: ${widget.testGroupData.groupName}, Total Sessions: ${widget.testGroupData.sessions.length}");
    _initializeScreen();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    setStateIfMounted(() => _isLoadingScreen = true);
    await _loadObjectImagePaths();
    _generateAllQuestionsAndSetState();
  }

  Future<void> _loadObjectImagePaths() async {
    try {
      const String objectsFolderPath = 'assets/objects/'; // تأكد من صحة المسار
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      _objectImagePaths = manifestMap.keys
          .where((String key) =>
      key.startsWith(objectsFolderPath) &&
          key != objectsFolderPath && // استبعاد المجلد نفسه
          (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg') || key.endsWith('.gif') || key.endsWith('.webp')))
          .toList();
      debugPrint("GroupTestManager: Loaded ${_objectImagePaths.length} random object images from $objectsFolderPath");
      if (_objectImagePaths.isEmpty) {
        debugPrint("GroupTestManager: Warning - No images found in $objectsFolderPath. Random image questions might be affected.");
      }
    } catch (e) {
      debugPrint("GroupTestManager: Error loading object image paths: $e");
      _objectImagePaths = []; // ضمان وجود قائمة فارغة في حالة الخطأ
    }
  }

  String? _getRandomObjectImagePath() {
    if (_objectImagePaths.isEmpty) return null;
    return _objectImagePaths[_random.nextInt(_objectImagePaths.length)];
  }

  void _generateAllQuestionsAndSetState() {
    if (!mounted) return;
    // إذا لم تكن الشاشة قيد التحميل بالفعل ولم نبدأ بعد (السؤال الأول)، ضعها في حالة تحميل
    if (!_isLoadingScreen && _currentGlobalQuestionIndex == 0) {
      setStateIfMounted(() => _isLoadingScreen = true);
    }

    List<GeneratedQuestion> allQuestionsCollector = [];
    final String mainGroupNameFromResponse = widget.testGroupData.groupName; // "المجموعة الرئيسية"
    debugPrint("GroupTestManager: Generating ALL questions for group: $mainGroupNameFromResponse. Total sessions: ${widget.testGroupData.sessions.length}");

    for (int sessionIdx = 0; sessionIdx < widget.testGroupData.sessions.length; sessionIdx++) {
      final currentSession = widget.testGroupData.sessions[sessionIdx]; // قسم مثل "فهم"، "تعبير"
      final String currentSessionTitle = currentSession.title.isNotEmpty ? currentSession.title : mainGroupNameFromResponse;
      debugPrint("  Processing Session ${sessionIdx + 1}: $currentSessionTitle (ID: ${currentSession.sessionId})");

      // منطق خاص لقسم "فهم" (عادةً أول قسم)
      if (sessionIdx == 0 && currentSession.title.toLowerCase().contains("فهم")) {
        debugPrint("    This is 'Fahm' section (Session ID: ${currentSession.sessionId}).");
        final detailsForFahm = currentSession.details; // الأسئلة الأساسية لقسم فهم
        final newDetailForFahm = currentSession.newDetail; // السؤال الإضافي لقسم فهم

        // السؤال 1 (خيارات نصية، صورة واحدة)
        if (detailsForFahm.isNotEmpty) {
          final detail0 = detailsForFahm[0];
          allQuestionsCollector.add(GeneratedQuestion(
            originalDetailId: detail0.detailId, sectionTitle: currentSessionTitle,
            questionText: detail0.questions ?? "ما هو الشعور الظاهر؟",
            options: detail0.answerOptions.isNotEmpty ? detail0.answerOptions : ["فارغ1", "فارغ2"], // ضمان وجود خيارات
            correctAnswer: detail0.rightAnswer.isNotEmpty ? detail0.rightAnswer : (detail0.answerOptions.isNotEmpty ? detail0.answerOptions[0] : "فارغ1"),
            imagePath1: detail0.localAssetPath, // مسار الصورة من السؤال الأساسي
            textContent1: detail0.textContent,   // النص المرافق للصورة (إذا وجد)
            mainItemName: mainGroupNameFromResponse, // اسم المجموعة الرئيسية
            isImageOptions: false, optionImagePaths: [], // الخيارات نصية
          ));
          debugPrint("      Fahm Q1 (Text Options): '${allQuestionsCollector.last.questionText}' (original detailId: ${detail0.detailId})");
        } else { debugPrint("      Fahm Q1: SKIPPED - No details[0] for Fahm section."); }

        // السؤال 2 (خيارات صور، صورتان: detail[1] و newDetail)
        if (detailsForFahm.length >= 2 && newDetailForFahm.detailId != 0) { // تأكد أن newDetail صالح
          final detail1 = detailsForFahm[1];
          List<String?> imageOptPathsQ2 = [];
          List<String> imageOptValuesQ2 = []; // القيم النصية المقابلة للصور للمقارنة

          if (detail1.localAssetPath != null) {
            imageOptPathsQ2.add(detail1.localAssetPath);
            imageOptValuesQ2.add(detail1.rightAnswer); // القيمة النصية للصورة الأولى (الصحيحة)
          }
          if (newDetailForFahm.localAssetPath != null) {
            imageOptPathsQ2.add(newDetailForFahm.localAssetPath);
            imageOptValuesQ2.add(newDetailForFahm.rightAnswer); // القيمة النصية للصورة الثانية (المشتت)
          }

          if (imageOptPathsQ2.length == 2) { // يجب أن يكون لدينا مساران للصور
            allQuestionsCollector.add(GeneratedQuestion(
              originalDetailId: detail1.detailId, sectionTitle: currentSessionTitle,
              questionText: "من يكون $mainGroupNameFromResponse؟", // أو سؤال مناسب آخر
              options: imageOptValuesQ2, // هذه هي القيم النصية المرتبطة بالصور للمقارنة
              correctAnswer: detail1.rightAnswer, // الإجابة الصحيحة هي قيمة الصورة الأولى (detail1)
              imagePath1: detail1.localAssetPath, textContent1: detail1.textContent,
              imagePath2: newDetailForFahm.localAssetPath, textContent2: newDetailForFahm.textContent,
              isTwoElements: true, // نعرض الصورتين في السؤال نفسه
              mainItemName: mainGroupNameFromResponse, // اسم الكائن الرئيسي
              secondItemName: newDetailForFahm.groupName ?? "الكائن الآخر", // اسم الكائن الثاني
              isImageOptions: true, optionImagePaths: imageOptPathsQ2, // الخيارات هي الصور
            ));
            debugPrint("      Fahm Q2 (Image Options): '${allQuestionsCollector.last.questionText}' (original detailId: ${detail1.detailId}, newDetail used: ${newDetailForFahm.detailId})");
          } else { debugPrint("      Fahm Q2: SKIPPED - Not enough image paths for image options (expected 2, got ${imageOptPathsQ2.length}).");}
        } else { debugPrint("      Fahm Q2: SKIPPED - Not enough details for Q2 or invalid newDetail. Details count: ${detailsForFahm.length}, newDetailId: ${newDetailForFahm.detailId}"); }

        // السؤال 3 (خيارات صور، صورتان: detail[2] وصورة عشوائية)
        if (detailsForFahm.length >= 3) {
          final detail2 = detailsForFahm[2];
          final randomImagePath = _getRandomObjectImagePath();
          List<String?> imageOptPathsQ3 = [];
          List<String> imageOptValuesQ3 = []; // القيم النصية المقابلة

          if (detail2.localAssetPath != null) {
            imageOptPathsQ3.add(detail2.localAssetPath);
            imageOptValuesQ3.add(detail2.rightAnswer); // القيمة النصية للصورة الأولى (الصحيحة)
          }
          if (randomImagePath != null) {
            imageOptPathsQ3.add(randomImagePath);
            imageOptValuesQ3.add("random_image_placeholder_value"); // قيمة فريدة لا تطابق الإجابة الصحيحة
          }

          if (imageOptPathsQ3.length == 2) {
            allQuestionsCollector.add(GeneratedQuestion(
              originalDetailId: detail2.detailId, sectionTitle: currentSessionTitle,
              questionText: "من يكون $mainGroupNameFromResponse؟",
              options: imageOptValuesQ3, // القيم النصية المرتبطة بالصور
              correctAnswer: detail2.rightAnswer, // الإجابة الصحيحة هي قيمة الصورة الأولى (detail2)
              imagePath1: detail2.localAssetPath, textContent1: detail2.textContent,
              imagePath2: randomImagePath, // مسار الصورة العشوائية
              isTwoElements: true, // نعرض الصورتين
              mainItemName: mainGroupNameFromResponse,
              secondItemName: "الكائن العشوائي", // أو اسم مناسب آخر
              isImageOptions: true, optionImagePaths: imageOptPathsQ3,
            ));
            debugPrint("      Fahm Q3 (Image Options): '${allQuestionsCollector.last.questionText}' (original detailId: ${detail2.detailId})");
          } else { debugPrint("      Fahm Q3: SKIPPED - Not enough image paths for image options (expected 2, got ${imageOptPathsQ3.length}).");}
        } else { debugPrint("      Fahm Q3: SKIPPED - Not enough details for Q3. Details count: ${detailsForFahm.length}"); }
      } else { // الأقسام الأخرى أو قسم الفهم إذا لم ينطبق الشرط الأول
        debugPrint("    This is another section or Fahm section didn't meet special criteria: ${currentSession.title} (Session ID: ${currentSession.sessionId})");
        int questionsAddedForThisSection = 0;
        // إذا كان هذا هو القسم الأول (sessionIdx == 0) ولم يكن "فهم"، أو كان "فهم" ولكن لم يولد الأسئلة الخاصة به
        // نبدأ من detailLoopStartIndex = 0
        // إذا كان هذا قسم "فهم" (sessionIdx == 0) وتم توليد الأسئلة الثلاثة الأولى منه، نبدأ من 3
        int detailLoopStartIndex = (sessionIdx == 0 && currentSession.title.toLowerCase().contains("فهم")) ? 3 : 0;

        // إذا كان قسم فهم ولكن لم يكن لديه 3 تفاصيل على الأقل، فابدأ من حيث توقفت التفاصيل
        if (sessionIdx == 0 && currentSession.title.toLowerCase().contains("فهم") && currentSession.details.length < 3) {
          detailLoopStartIndex = currentSession.details.length; // ابدأ من حيث انتهت التفاصيل المتاحة
        }


        for (int i = detailLoopStartIndex; i < currentSession.details.length && questionsAddedForThisSection < 3; i++) {
          final detail = currentSession.details[i];
          allQuestionsCollector.add(GeneratedQuestion(
            originalDetailId: detail.detailId, sectionTitle: currentSessionTitle,
            questionText: detail.questions ?? "بماذا يشعر هذا الشخص؟", // سؤال افتراضي
            options: detail.answerOptions.isNotEmpty ? detail.answerOptions : ["غير محدد1", "غير محدد2"],
            correctAnswer: detail.rightAnswer.isNotEmpty ? detail.rightAnswer : (detail.answerOptions.isNotEmpty ? detail.answerOptions[0] : "غير محدد1"),
            imagePath1: detail.localAssetPath, // قد يكون null إذا كان السؤال نصيًا
            textContent1: detail.textContent, // قد يكون null إذا كان السؤال صوريًا
            mainItemName: mainGroupNameFromResponse,
            isImageOptions: false, optionImagePaths: [], // خيارات نصية هنا
          ));
          questionsAddedForThisSection++;
          debugPrint("      Other/Remaining Section Q${questionsAddedForThisSection} (from session ${sessionIdx+1}, detail index $i): '${allQuestionsCollector.last.questionText}' (original detailId: ${detail.detailId})");
        }
        if (questionsAddedForThisSection == 0 && currentSession.details.isEmpty && detailLoopStartIndex == 0) {
          debugPrint("      No details to process for session '${currentSession.title}'.");
        } else if (questionsAddedForThisSection < 3 && detailLoopStartIndex < currentSession.details.length) {
          // هذا يعني أننا لم نصل إلى 3 أسئلة ولكن لا يزال هناك تفاصيل متبقية
          debugPrint("      Warning: Section '${currentSession.title}' provided only $questionsAddedForThisSection normal questions (expected up to 3, but loop ended). Details processed: ${currentSession.details.length - detailLoopStartIndex}");
        }
      }
    } // نهاية حلقة الأقسام (sessions)

    setStateIfMounted(() {
      _allGeneratedQuestions = allQuestionsCollector;
      _currentGlobalQuestionIndex = 0; // البدء من السؤال الأول دائمًا
      _isLoadingScreen = false; // تم الانتهاء من التحميل
      debugPrint("GroupTestManager: setState after generating ALL questions. Total Qs: ${_allGeneratedQuestions.length}, isLoadingScreen: $_isLoadingScreen");

      // إذا لم يتم توليد أي أسئلة، أنهِ الاختبار مع رسالة خطأ
      if (_allGeneratedQuestions.isEmpty && mounted && !_isCompletingGroup) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(mounted && !_isCompletingGroup) _completeTestGroup(showError: true, errorMessage: "لم يتم العثور على أسئلة صالحة لهذا الاختبار.");
        });
      }
    });
  }


  Future<void> _showInternalSuccessDialog() async {
    if (!mounted) return;
    _confettiController.play();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // لا يمكن الإغلاق بالضغط خارج الحوار
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Stack(alignment: Alignment.topCenter, children: [
            ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive, shouldLoop: false, numberOfParticles: 20, gravity: 0.1, emissionFrequency: 0.03, colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple]),
            const Padding(padding: EdgeInsets.only(top: 10.0), child: Text('🎉 أحسنت!', style: TextStyle(fontFamily: 'Cairo', color: Color(0xff2C73D9), fontWeight: FontWeight.bold, fontSize: 22))),
          ]),
          content: const Text('إجابة صحيحة.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2C73D9), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10), textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
              child: const Text('التالي'),
              onPressed: () {
                if (_confettiController.state == ConfettiControllerState.playing) _confettiController.stop();
                Navigator.of(dialogContext).pop(); // إغلاق الحوار فقط
              },
            ),
          ],
        );
      },
    );
  }

  void _handleAnswer(bool isCorrect) {
    if (_isLoadingScreen || _isProcessingAnswer || _isCompletingGroup) return; // منع المعالجة المتعددة

    setStateIfMounted(() => _isProcessingAnswer = true);
    debugPrint("GroupTestManager: _handleAnswer called. isCorrect: $isCorrect. GlobalQ_idx: $_currentGlobalQuestionIndex. _isProcessingAnswer SET TO TRUE.");

    if (isCorrect) {
      _totalCorrectAnswers++;
      debugPrint("GroupTestManager: Correct answer. Total correct: $_totalCorrectAnswers.");
      WidgetsBinding.instance.addPostFrameCallback((_) { // ضمان أن البناء قد اكتمل
        if (mounted) {
          _showInternalSuccessDialog().then((_) { // بعد إغلاق الحوار
            debugPrint("GroupTestManager: _showInternalSuccessDialog().then() - Dialog is now closed. Calling _advanceToNextGlobalQuestion.");
            _advanceToNextGlobalQuestion(); // التقدم للسؤال التالي
            // إعادة تعيين isProcessingAnswer هنا بعد اكتمال كل العمليات
            if (mounted) setStateIfMounted(() { _isProcessingAnswer = false; debugPrint("GroupTestManager: _handleAnswer (Success path) - _isProcessingAnswer set to false AFTER dialog and advance."); });
          }).catchError((error){
            debugPrint("GroupTestManager: Error after _showInternalSuccessDialog: $error");
            // تأكد من إعادة التعيين حتى في حالة الخطأ
            if (mounted) { setStateIfMounted(() => _isProcessingAnswer = false); }
          });
        } else {
          // إذا لم تكن mounted، لا تفعل شيئًا ولكن أعد التعيين
          _isProcessingAnswer = false;
        }
      });
    } else {
      // إجابة خاطئة
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("إجابة خاطئة، حاول مرة أخرى!"), backgroundColor: Colors.redAccent, duration: Duration(seconds: 1)));
      // إعادة تعيين isProcessingAnswer فورًا للسماح بالمحاولة مرة أخرى
      if (mounted) setStateIfMounted(() { _isProcessingAnswer = false; debugPrint("GroupTestManager: _handleAnswer (Incorrect path) - _isProcessingAnswer set to false."); });
    }
  }

  void _advanceToNextGlobalQuestion() {
    if (!mounted) return;
    debugPrint("GroupTestManager: _advanceToNextGlobalQuestion - Current Global Q_idx: $_currentGlobalQuestionIndex, Total Qs: ${_allGeneratedQuestions.length}");

    int newGlobalIndex = _currentGlobalQuestionIndex + 1;

    if (newGlobalIndex >= _allGeneratedQuestions.length) {
      debugPrint("  All global questions completed. Preparing to call _completeTestGroup.");
      // تأكد من عدم استدعاء _completeTestGroup عدة مرات
      if (!_isCompletingGroup) {
        // استخدام WidgetsBinding لتأجيل الاستدعاء إلى ما بعد اكتمال الإطار الحالي
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(mounted && !_isCompletingGroup) _completeTestGroup();
        });
      }
    } else {
      debugPrint("  Moved to next global question. New Global Q_idx: $newGlobalIndex");
      setStateIfMounted(() {
        _currentGlobalQuestionIndex = newGlobalIndex;
        // _isProcessingAnswer لا يزال false هنا، سيتم تعيينه true عند _handleAnswer التالية
      });
    }
  }

  Future<void> _completeTestGroup({bool showError = false, String? errorMessage}) async {
    if (!mounted || _isCompletingGroup) return; // منع الاستدعاء المتعدد

    setStateIfMounted(() => _isCompletingGroup = true);
    debugPrint("GroupTestManager: _completeTestGroup called. GroupID: ${widget.testGroupData.groupId}. Total correct: $_totalCorrectAnswers. ShowError: $showError. ErrorMessage: $errorMessage. Marking group as done.");

    bool successMarkingDone = false;
    if (!showError) { // لا تحاول وضع علامة "تم" إذا كان هناك خطأ في تحميل الأسئلة
      successMarkingDone = await ApiService.markTestGroupDone(widget.jwtToken, widget.testGroupData.groupId);
    }

    // --- إزالة إشعار اختبار الـ 3 شهور وإعادة تعيين الفلاج ---
    // يتم هذا سواء نجح الاختبار أو فشل (showError)، طالما أننا في نهاية تدفق الاختبار
    await NotificationManager.removeNotificationByType(notif_model.NotificationType.threeMonthTestAvailable);
    await NotificationManager.setThreeMonthTestNotificationSent(false); // إعادة تعيين الفلاج
    debugPrint("GroupTestManagerScreen: 3-Month test notification removed and flag reset.");
    // --- نهاية إزالة الإشعار ---

    if (mounted) {
      String title = showError ? "خطأ في الاختبار" : (successMarkingDone ? "اختبار مكتمل" : "خطأ في الحفظ");
      String content = errorMessage ?? (showError ? "لم يتم تحميل أسئلة الاختبار بشكل صحيح." : (successMarkingDone ? "أحسنت! لقد أكملت اختبار الـ 3 شهور بنجاح." : "حدث خطأ أثناء حفظ نتيجة الاختبار."));

      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
              title: Text(title, style: const TextStyle(fontFamily: 'Cairo')),
              content: Text(content, style: const TextStyle(fontFamily: 'Cairo')),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(); // إغلاق الحوار
                      // العودة إلى HomeScreen وإزالة جميع الشاشات السابقة
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text("العودة للرئيسية", style: TextStyle(fontFamily: 'Cairo'))
                )
              ]
          )
      );
    }
    // لا حاجة لإعادة تعيين _isCompletingGroup إلى false هنا لأننا نغادر الشاشة
  }


  @override
  Widget build(BuildContext context) {
    _buildCount++;
    debugPrint("GroupTestManager BUILD #$_buildCount: isLoadingScreen: $_isLoadingScreen, GlobalQ_idx: $_currentGlobalQuestionIndex, TotalGenQs: ${_allGeneratedQuestions.length}, isCompletingGroup: $_isCompletingGroup, isProcessingAns: $_isProcessingAnswer");

    if (_isLoadingScreen) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.testGroupData.groupName, style: const TextStyle(fontFamily: 'Cairo'))),
        body: const LoadingIndicator(message: "جاري تجهيز أسئلة اختبار الـ 3 شهور..."),
      );
    }

    // إذا كان isCompletingGroup صحيحًا، أظهر مؤشر تحميل "جاري إنهاء الاختبار"
    // هذا يمنع وميض الشاشة إذا كان هناك تأخير قبل عرض الحوار النهائي.
    if (_isCompletingGroup) {
      return Scaffold(
          appBar: AppBar(title: Text(widget.testGroupData.groupName, style: const TextStyle(fontFamily: 'Cairo'))),
          body: const LoadingIndicator(message: "جاري إنهاء الاختبار...")
      );
    }

    // إذا لم يتم توليد أسئلة، وكان التحميل قد انتهى، ولم نكن في طور الإنهاء
    if (_allGeneratedQuestions.isEmpty) {
      debugPrint("GroupTestManager: Build - _allGeneratedQuestions is EMPTY. This is critical and should have triggered _completeTestGroup earlier.");
      // كإجراء احتياطي، إذا لم يتم استدعاء _completeTestGroup من قبل
      if (!_isCompletingGroup) {
        // استخدام WidgetsBinding لتأجيل الاستدعاء إلى ما بعد اكتمال الإطار الحالي
        // لتجنب استدعاء setState أثناء البناء
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(mounted && !_isCompletingGroup) _completeTestGroup(showError: true, errorMessage: "فشل تحميل أسئلة الاختبار.");
        });
      }
      // أظهر واجهة تحميل مؤقتة بينما يتم التعامل مع الخطأ
      return Scaffold(
        appBar: AppBar(title: Text(widget.testGroupData.groupName, style: const TextStyle(fontFamily: 'Cairo'))),
        body: const LoadingIndicator(message: "خطأ في تحميل الأسئلة..."),
      );
    }

    // إذا تجاوز الفهرس عدد الأسئلة، فهذا يعني أن الاختبار انتهى ويجب أن نكون في _isCompletingGroup
    if (_currentGlobalQuestionIndex >= _allGeneratedQuestions.length) {
      debugPrint("GroupTestManager: Build - Index out of bounds but list is not empty. Test completion path is active or should be.");
      // إذا لم نكن بالفعل في طور الإنهاء، ابدأه
      if (!_isCompletingGroup) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(mounted && !_isCompletingGroup) _completeTestGroup();
        });
      }
      // أظهر واجهة تحميل "جاري الإنهاء"
      return Scaffold(
          appBar: AppBar(title: const Text("إنهاء الاختبار", style: TextStyle(fontFamily: 'Cairo'))),
          body: const LoadingIndicator(message: "جاري إنهاء الاختبار...")
      );
    }

    // عرض السؤال الحالي
    final currentGeneratedQuestion = _allGeneratedQuestions[_currentGlobalQuestionIndex];
    final String appBarTitle = "${currentGeneratedQuestion.sectionTitle} (${_currentGlobalQuestionIndex + 1}/${_allGeneratedQuestions.length})";

    return GroupTestQuestionDisplayScreen(
      // استخدام مفتاح فريد لضمان إعادة بناء الواجهة عند تغيير السؤال
      key: ValueKey('group_q_global_${_currentGlobalQuestionIndex}_${currentGeneratedQuestion.originalDetailId}_build$_buildCount'),
      appBarTitle: appBarTitle,
      question: currentGeneratedQuestion,
      isLoading: _isProcessingAnswer || _isCompletingGroup || _isLoadingScreen, // أي تحميل يجب أن يعطل الواجهة
      onAnswerSelected: _handleAnswer,
    );
  }
}