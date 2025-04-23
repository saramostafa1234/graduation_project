// lib/screens/exercise_flow_screen.dart
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
 // تأكد من المسار
import 'package:myfinalpro/services/Api_services.dart';
import 'package:myfinalpro/services/sucess_popup.dart';

import 'exercise_flow_cubit.dart';
import 'exercise_flow_state.dart'; // تأكد من المسار الصحيح لهذا الملف

class ExerciseFlowScreen extends StatefulWidget {
  const ExerciseFlowScreen({super.key});

  @override
  State<ExerciseFlowScreen> createState() => _ExerciseFlowScreenState();
}

class _ExerciseFlowScreenState extends State<ExerciseFlowScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    print("--- ExerciseFlowScreen initState ---");
  }

  @override
  void dispose() {
    print("--- ExerciseFlowScreen dispose ---");
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExerciseFlowCubit>(
      create: (context) {
        try {
          final apiService = context.read<ApiService>();
          return ExerciseFlowCubit(apiService)..fetchMonthlyTest();
        } catch (e) {
          print("!!!!!!!! FATAL ERROR: ApiService not found in context! Check main.dart Provider setup. !!!!!!!!");
          return ExerciseFlowCubit(ApiService())..emit(ExerciseFlowError("خطأ في إعداد التطبيق: لم يتم العثور على خدمة API."));
        }
      },
      child: BlocConsumer<ExerciseFlowCubit, ExerciseFlowState>(
        listener: (context, state) {
          print("Listener received state: ${state.runtimeType}");
          if (state is ExerciseCorrectAnswer) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              print("State is ExerciseCorrectAnswer, calling showSuccessPopup...");
              showSuccessPopup(
                  context,
                  _confettiController,
                      () {
                    if (mounted) {
                      print("Popup closed, proceeding to next exercise...");
                      context.read<ExerciseFlowCubit>().proceedToNextExercise();
                    }
                  }
              );
            });
          } else if (state is ExerciseIncorrectAnswer) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              print("State is ExerciseIncorrectAnswer, showing SnackBar...");
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("إجابة غير صحيحة، حاول مرة أخرى!", style: TextStyle(color: Colors.white, fontSize: 16)),
                backgroundColor: Colors.orange.shade700,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.fromLTRB(15, 5, 15, 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 6,
              ));
              // لا يوجد انتقال تلقائي
            });
          } else if (state is ExerciseFlowError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              print("State is ExerciseFlowError, showing error SnackBar: ${state.message}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("خطأ: ${state.message}"),
                    backgroundColor: Colors.red.shade800,
                    duration: Duration(seconds: 4)),
              );
              Future.delayed(const Duration(seconds: 4), () {
                if (mounted && Navigator.canPop(context)) {
                  print("Popping screen due to error state.");
                  Navigator.pop(context);
                }
              });
            });

          } else if (state is ExerciseFlowFinished) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print("Listener: Exercise Flow Finished state detected. Attempting to pop.");
              if (mounted && Navigator.canPop(context)) {
                print("Popping context.");
                Navigator.pop(context, true);
              } else {
                print("Cannot pop context after finishing or widget unmounted.");
              }
            });
          }
        },
        builder: (context, state) {
          print("Builder received state: ${state.runtimeType}");
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Scaffold(
                backgroundColor: Color(0xff2C73D9),
                appBar: _buildAppBar(context, state),
                body: SafeArea(child: _buildBody(context, state)),
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [ Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple ],
                emissionFrequency: 0.04,
                numberOfParticles: 20,
                gravity: 0.1,
                maxBlastForce: 10,
                minBlastForce: 5,
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, ExerciseFlowState state) {
    String title = "الاختبار الشهري";
    int current = 0;
    int total = 4;

    ExerciseStepLoaded? loadedState;
    if (state is ExerciseStepLoaded) {
      loadedState = state;
    } else if (state is ExerciseCorrectAnswer) {
      loadedState = state.previousState;
    } else if (state is ExerciseIncorrectAnswer) {
      loadedState = state.previousState;
    }

    if (loadedState != null) {
      current = loadedState.currentStepIndex + 1;
      if (current > total) current = total;
      title = 'الاختبار ($current / $total)';
    } else if (state is ExerciseFlowLoading || state is ExerciseFlowInitial) {
      title = "جاري تحميل الاختبار...";
    } else if (state is ExerciseFlowLoadingDistractor) {
      title = "جاري تحميل البيانات...";
    } else if (state is ExerciseFlowUpdatingSession) {
      title = "جاري حفظ النتائج...";
    } else if (state is ExerciseFlowFinished) {
      return null;
    } else if (state is ExerciseFlowError) {
      title = "حدث خطأ";
    }

    bool enableExitButton = state is! ExerciseFlowUpdatingSession && state is! ExerciseFlowFinished;

    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: Colors.white, size: 30),
        tooltip: 'إنهاء الاختبار',
        onPressed: enableExitButton ? () => _showExitConfirmationDialog(context) : null,
      ),
      title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19)),
      centerTitle: true,
    );
  }


  Widget _buildBody(BuildContext context, ExerciseFlowState state) {
    if (state is ExerciseFlowLoading || state is ExerciseFlowInitial || state is ExerciseFlowLoadingDistractor) {
      return _buildLoadingUI(
          state is ExerciseFlowLoadingDistractor ? "جاري تحميل الصورة..." : "جاري تحميل الاختبار...");
    } else if (state is ExerciseStepLoaded || state is ExerciseCorrectAnswer || state is ExerciseIncorrectAnswer) {
      final loadedState = (state is ExerciseStepLoaded) ? state :
      (state is ExerciseCorrectAnswer) ? state.previousState :
      (state as ExerciseIncorrectAnswer).previousState;

      final bool enableInteraction = state is ExerciseStepLoaded || state is ExerciseIncorrectAnswer;
      final keySuffix = enableInteraction ? 'enabled' : 'disabled';

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey('step_${loadedState.currentStepIndex}_$keySuffix'),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: _buildExerciseStepUI(context, state, loadedState),
          ),
        ),
      );
    } else if (state is ExerciseFlowError) {
      return Center(child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(state.message, style: TextStyle(color: Colors.yellow.shade300, fontSize: 18), textAlign: TextAlign.center)
      ));
    } else if (state is ExerciseFlowFinished || state is ExerciseFlowUpdatingSession) {
      return _buildFinishedUI(context, state is ExerciseFlowUpdatingSession);
    }
    return _buildErrorUI(context, "حالة غير متوقعة: ${state.runtimeType}");
  }

  Widget _buildExerciseStepUI(BuildContext context, ExerciseFlowState currentState, ExerciseStepLoaded loadedState) {
    final bool enableInteraction = currentState is ExerciseStepLoaded || currentState is ExerciseIncorrectAnswer;
    print("Building Step UI for step ${loadedState.currentStepIndex}. enableInteraction: $enableInteraction (Current state: ${currentState.runtimeType})");

    switch (loadedState.stepType) {
      case ExerciseStepType.singleBackendImage:
        return _buildSingleImageWithOptionsContent(context, loadedState, enableInteraction);
      case ExerciseStepType.doubleBackendImage:
      case ExerciseStepType.backendAndAssetImage:
        return _buildStackedImagesContent(context, loadedState, enableInteraction);
      default:
        return Center(child: Text('نوع الخطوة ${loadedState.stepType} غير مدعوم.', style: TextStyle(color: Colors.yellow)));
    }
  }


  Widget _buildLoadingUI(String message) {
    // ... (الكود كما هو) ...
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 20),
        Text(message, style: TextStyle(color: Colors.white70, fontSize: 16))
      ],
    ));
  }

  Widget _buildErrorUI(BuildContext context, String message) {
    // ... (الكود كما هو) ...
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.yellow.shade600, size: 60),
              SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 17, height: 1.5),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ExerciseFlowCubit>().fetchMonthlyTest();
                },
                icon: Icon(Icons.refresh),
                label: Text("إعادة المحاولة"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Color(0xff2C73D9)),
              )
            ],
          )),
    );
  }

  Widget _buildSingleImageWithOptionsContent(BuildContext context, ExerciseStepLoaded state, bool enableButtons) {
    // ... (الكود كما هو، مع التأكد من استخدام imageAssetPath) ...
    double contentHeight = MediaQuery.of(context).size.height * 0.42;
    double contentWidth = 330;

    final imageAssetPath = state.image1Path;
    if (imageAssetPath == null) {
      return Center(child: Text("خطأ: مسار الصورة المحلي مفقود.", style: TextStyle(color: Colors.yellow)));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          state.question ?? 'ما هو شعور هذا الشخص؟',
          style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: contentWidth, minHeight: contentHeight * 0.7, maxHeight: contentHeight),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImageWidget(imageAssetPath, width: contentWidth, height: contentHeight),
          ),
        ),
        SizedBox(height: 35),
        if (state.answerOptions.isNotEmpty)
          ...state.answerOptions.map((optionText) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: SizedBox(
                width: 310, height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: enableButtons ? Colors.white : Colors.grey.shade300,
                    foregroundColor: enableButtons ? Color(0xff2C73D9) : Colors.grey.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Color(0xff2C73D9).withOpacity(enableButtons ? 0.4 : 0.1), width: 1.5)),
                    elevation: enableButtons ? 4 : 0,
                  ),
                  onPressed: enableButtons
                      ? () {
                    print("Button '$optionText' pressed. Submitting...");
                    context.read<ExerciseFlowCubit>().submitAnswer(optionText);
                  }
                      : null,
                  child: Text(optionText, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }).toList()
        else
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text("لا توجد خيارات متاحة لهذه الخطوة.", style: TextStyle(color: Colors.yellow)),
          ),

        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildStackedImagesContent(BuildContext context, ExerciseStepLoaded state, bool enableInteraction) {
    // ... (الكود كما هو، مع التأكد من استخدام image1AssetPath و image2Path) ...
    final image1AssetPath = state.image1Path;
    final image2Path = state.image2Path;
    if (image1AssetPath == null || image2Path == null) {
      return Center(child: Text("خطأ: مسارات الصور مفقودة.", style: TextStyle(color: Colors.yellow)));
    }

    bool showFirstImageTop = Random().nextBool();
    String topImageSource = showFirstImageTop ? image1AssetPath : image2Path;
    String bottomImageSource = showFirstImageTop ? image2Path : image1AssetPath;

    return Column(
      children: [
        Text(
          state.question ?? 'اختر الصورة الصحيحة:',
          style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        _buildSelectableImageContainer(context, topImageSource, enableInteraction),
        SizedBox(height: 24),
        _buildSelectableImageContainer(context, bottomImageSource, enableInteraction),
        SizedBox(height: 20),
      ],
    );
  }


  Widget _buildSelectableImageContainer(BuildContext context, String imagePath, bool enableInteraction) {
    // ... (الكود كما هو، مع التأكد من استدعاء submitAnswer بـ imagePath) ...
    double imgWidth = MediaQuery.of(context).size.width * 0.8;
    double imgHeight = MediaQuery.of(context).size.height * 0.29;
    imgWidth = imgWidth.clamp(280, 340);
    imgHeight = imgHeight.clamp(220, 300);

    return InkWell(
      onTap: enableInteraction
          ? () {
        print("Image container tapped. Source: '$imagePath'. Submitting...");
        context.read<ExerciseFlowCubit>().submitAnswer(imagePath); // نرسل مسار الـ Asset
      }
          : null,
      borderRadius: BorderRadius.circular(14),
      splashColor: enableInteraction ? Color(0xff2C73D9).withOpacity(0.4) : Colors.transparent,
      highlightColor: enableInteraction ? Color(0xff2C73D9).withOpacity(0.2) : Colors.transparent,
      child: Opacity(
        opacity: enableInteraction ? 1.0 : 0.6,
        child: Container(
          width: imgWidth,
          height: imgHeight,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14), color: Colors.white,
              boxShadow: [
                if (enableInteraction)
                  BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _buildImageWidget(imagePath, width: imgWidth, height: imgHeight),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishedUI(BuildContext context, bool isUpdating) {
    // ... (الكود كما هو) ...
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUpdating) ...[
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 25),
                Text("جاري حفظ النتائج...", style: TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
              ] else ...[
                Icon(Icons.check_circle_outline_rounded, color: Colors.lightGreenAccent, size: 90),
                SizedBox(height: 25),
                Text("لقد أكملت الاختبار بنجاح!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                SizedBox(height: 40),
                Text("سيتم العودة للشاشة الرئيسية...", style: TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
              ]
            ],
          ),
        ));
  }

  void _showExitConfirmationDialog(BuildContext context) {
    // ... (الكود كما هو) ...
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('تأكيد الإنهاء', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('هل أنت متأكد من رغبتك في إنهاء الاختبار الآن؟ لن يتم حفظ تقدمك الحالي.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actionsPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('إنهاء الاختبار', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageWidget(String assetPath, {double? width, double? height}) {
    // --- *** تم التبسيط ليعتمد فقط على Image.asset *** ---
    print("Attempting to load ASSET image: $assetPath");

    Widget errorWidget = Container(
      width: width, height: height, color: Colors.grey[200],
      child: Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: (width ?? 60) * 0.4)),
    );

    // التأكد من أن المسار يبدأ بـ 'assets/' (احتياطي)
    final String finalAssetPath = assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';

    return Image.asset(
      finalAssetPath,
      key: ValueKey(finalAssetPath),
      width: width, height: height, fit: BoxFit.contain,
      errorBuilder: (ctx, error, stackTrace) {
        print("--- ERROR Loading Asset Image ---");
        print("Path Attempted: $finalAssetPath (Original from state: $assetPath)");
        print("Error: $error");
        print("---------------------------------");
        return errorWidget;
      },
    );
    // --- *** نهاية التبسيط *** ---
  }
} // نهاية State