// lib/screens/quiz/quiz_type2_screen.dart
import 'package:flutter/material.dart';
import 'package:myfinalpro/test/models/quiz_model.dart';
import 'package:myfinalpro/test/sucess_popup.dart';



class QuizType2Screen extends StatelessWidget {
  final String rootQuestion;
  final QuizDetail option1Detail;
  final QuizDetail option2Detail;
  final String rootAnswer;
  final Function(QuizDetail correctChoiceDetail) onCorrect;
  final bool isCompleting;

  const QuizType2Screen({
    super.key,
    required this.rootQuestion,
    required this.option1Detail,
    required this.option2Detail,
    required this.rootAnswer,
    required this.onCorrect,
    this.isCompleting = false,
  });

  // --- تعديل دالة _checkAnswer ---
  Future<void> _checkAnswer(BuildContext context, QuizDetail selectedOption) async {
    if (isCompleting) return;

    debugPrint("Selected Option (Detail ID: ${selectedOption.detailId}) has rightAnswer: ${selectedOption.rightAnswer}");
    debugPrint("Required rootAnswer for comparison: $rootAnswer");

    if (selectedOption.rightAnswer == rootAnswer) {
      try {
        // --- التعديل هنا: تمرير VoidCallback ---
        await showSuccessPopup(context, () {
          // هذه الدالة تُستدعى بعد إغلاق البوب أب
          debugPrint("Success popup closed for Step 2.");
        });
        // --- نهاية التعديل ---

        // استدعاء onCorrect *بعد* إغلاق البوب أب
        if (context.mounted) {
          onCorrect(selectedOption); // تمرير الخيار الصحيح
        }
      } catch (e) {
        debugPrint("Error showing/closing success popup: $e");
        if (context.mounted) {
          onCorrect(selectedOption); // حاول المتابعة
        }
      }
    } else {
      if(context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('إجابة خاطئة، حاول مرة أخرى!'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          ),
        );
      }
      debugPrint("Wrong choice selected (Detail ID: ${selectedOption.detailId}).");
    }
  }
  // --- نهاية تعديل دالة _checkAnswer ---


  // --- دالة بناء ودجت خطأ الصورة (مع إزالة const غير الضروري) ---
  Widget _buildImageErrorWidget(BuildContext context, Object error, StackTrace? stackTrace, String? attemptedPath) {
     debugPrint("Error loading asset: $attemptedPath\n$error");
     return Container(
       padding: const EdgeInsets.all(10), alignment: Alignment.center,
       decoration: BoxDecoration( color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
       child: Column( mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
           Icon(Icons.broken_image_outlined, color: Colors.red.shade400, size: 40),
           const SizedBox(height: 8),
           // إزالة const
           Text('خطأ تحميل الصورة', textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
           if (attemptedPath != null) Padding( padding: const EdgeInsets.only(top: 4.0), child: Text( '(المسار: $attemptedPath)', textDirection: TextDirection.ltr, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 10),),),
         ],),);
   }

  // بناء واجهة الخيار الواحد (صورة أو نص)
  Widget _buildOptionWidget(BuildContext context, QuizDetail detail) {
    final assetPath = detail.localAssetPath;

    return InkWell(
      onTap: isCompleting ? null : () => _checkAnswer(context, detail),
      borderRadius: BorderRadius.circular(10),
      // --- تعديل: استخدام withAlpha ---
      splashColor: const Color(0xff2C73D9).withAlpha((255 * 0.3).round()),
      child: Opacity(
        opacity: isCompleting ? 0.6 : 1.0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75, height: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - AppBar().preferredSize.height - 150) / 2.1, constraints: const BoxConstraints(maxWidth: 300, maxHeight: 280),
          // --- تعديل: استخدام withAlpha في الظل ---
          decoration: BoxDecoration( borderRadius: BorderRadius.circular(10), color: Colors.white, boxShadow: [ BoxShadow( color: Colors.black.withAlpha((255 * 0.15).round()), spreadRadius: 1, blurRadius: 6, offset: const Offset(0, 4),), ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: (detail.hasImage && assetPath != null)
                ? Image.asset( assetPath, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => _buildImageErrorWidget(ctx, err, st, assetPath),)
                : (detail.hasText)
                    // --- استخدام textContent ---
                    ? Center( child: Padding( padding: const EdgeInsets.all(8.0), child: Text( detail.textContent!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black87),),))
                    : const Center(child: Icon(Icons.question_mark, color: Colors.grey)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2C73D9),
      appBar: AppBar(
         backgroundColor: Colors.transparent, elevation: 0, automaticallyImplyLeading: false,
         actions: [ Padding( padding: const EdgeInsets.only(top: 8.0, right: 8.0), child: IconButton( icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 32), onPressed: () => Navigator.pop(context), tooltip: 'العودة',),),],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 Flexible( flex: 1, child: Text( rootQuestion, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),),),
                 Flexible( flex: 3, child: _buildOptionWidget(context, option1Detail),),
                 Flexible( flex: 3, child: _buildOptionWidget(context, option2Detail),),
                 if (isCompleting) const Padding( padding: EdgeInsets.only(top: 15.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
                 const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}