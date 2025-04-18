// lib/screens/session_details_screen.dart
// lib/screens/session_details_screen.dart
import 'package:flutter/material.dart';
// استيراد الشاشات التالية
import 'image_session_screen.dart'; // تأكد من المسار الصحيح
import 'story_session_screen.dart'; // تأكد من المسار الصحيح (يجب إنشاؤه)
import 'session_player_screen.dart';

class SessionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> sessionData; // بيانات الجلسة من الباك اند
  final String jwtToken; // التوكن للمصادقة

  // إضافة const للـ constructor واستخدام super.key
  const SessionDetailsScreen({
    super.key,
    required this.sessionData,
    required this.jwtToken,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // --- استخراج البيانات من sessionData بأمان ---
    final String title = sessionData['title'] ?? 'تفاصيل الجلسة';
    // مثال: قراءة مدة الجلسة إذا كانت متوفرة، وإلا استخدام قيمة افتراضية
    final String sessionTime = sessionData['duration']?.toString() ??
        "غير محددة"; // افترض وجود حقل 'duration'
    final String goal = sessionData['goal'] ?? 'لا يوجد هدف محدد لهذه الجلسة.';
    // الإرشادات قد تكون ثابتة أو من الـ API
    const List<String> instructions = [
      "١_ ضرورة الجلوس فى المستوى البصرى للطفل وذلك لجذب إنتباهه.", // <-- اكتبيها حرف بحرف
      "٢_ تنظيم بيئة التدريب، تجنب المشتتات وأن تكون بيئة التدريب بعيدة عن الضوضاء.", // <-- اكتبيها حرف بحرف
      "٣_ استخدام أسلوب التواصل الفعال، والذي يتضمن استخدام لغة سهلة مبسطة مدعومة بالإشارات والتواصل غير اللفظي ولغة العيون وتعابير الوجه واليد.", // <-- اكتبيها حرف بحرف
    ];
    // النص التمهيدي أو الوصف
    final String introductoryText = sessionData['details']?['_text'] ??
        sessionData['description'] ??
        'استعد لبدء الجلسة!';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // --- AppBar ---
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(kToolbarHeight + 20), // ارتفاع مناسب
          child: Padding(
            padding: const EdgeInsets.only(
                top: 30), // زيادة الـ padding العلوي قليلاً
            child: AppBar(
              leading: IconButton(
                // زر الرجوع
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF2C73D9)),
                tooltip: 'رجوع', // نص مساعد
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                title, // <-- استخدام العنوان الديناميكي
                style: const TextStyle(
                  color: Color(0xFF2C73D9),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ), // حجم مناسب
                overflow: TextOverflow.ellipsis,
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent, // خلفية شفافة
              elevation: 0, // بدون ظل
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 5,
                screenWidth * 0.05, 20), // تعديل الـ padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- زمن الجلسة ---
                Padding(
                  padding: const EdgeInsets.only(right: 5.0, bottom: 15.0),
                  child: Row(
                    children: [
                      const Text(
                        "زمن الجلسة:",
                        style: TextStyle(
                          color: Color(0xFF2C73D9),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Text(
                        sessionTime,
                        style: const TextStyle(
                          color: Color(0xFF2C73D9),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- النص التمهيدي (إذا وجد) ---
                if (introductoryText.isNotEmpty &&
                    introductoryText != 'استعد لبدء الجلسة!') ...[
                  const Text(
                    "عن الجلسة:",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF2C73D9),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade100)),
                    child: Text(
                      introductoryText,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 17, height: 1.5),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],

                // --- الأهداف ---
                const Text(
                  "أهداف الجلسة:",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF2C73D9),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(100),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ), // استخدام withAlpha
                  child: Text(
                    goal,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        color: Color(0xFF2C73D9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.5),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // --- الإرشادات ---
                const Text(
                  "إرشادات الجلسة:",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF2C73D9),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(100),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ), // استخدام withAlpha
                    child: Column(
                      // عرض الإرشادات كنقاط
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: instructions
                          .map((instruction) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: RichText(
                                    // استخدام RichText للنقاط
                                    textDirection: TextDirection.rtl,
                                    text: TextSpan(
                                        // استخدام DefaultTextStyle لتجنب تكرار الـ style
                                        style: DefaultTextStyle.of(context)
                                            .style
                                            .copyWith(
                                                color: const Color(0xFF2C73D9),
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                height: 1.5),
                                        children: [
                                          // يمكنك استخدام أيقونة نقطة أو رقم
                                          const WidgetSpan(
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 8.0),
                                                  child: Icon(Icons.circle,
                                                      size: 8,
                                                      color:
                                                          Color(0xFF2C73D9)))),
                                          TextSpan(
                                              text: instruction.startsWith(
                                                      RegExp(r'\d+[_ ]'))
                                                  ? instruction
                                                      .substring(instruction
                                                              .indexOf(' ') +
                                                          1)
                                                      .trim()
                                                  : instruction), // إزالة الترقيم التلقائي إن وجد
                                        ])),
                              ))
                          .toList(),
                    )),
                SizedBox(height: screenHeight * 0.04),

                // --- زر البدء/التالي ---
                ElevatedButton(
                  // داخل onPressed لزر "ابدأ الجلسة" في SessionDetailsScreen
                  onPressed: () {
  // قراءة النوع بأمان من sessionData مباشرة (بدون widget.)
  final String? sessionType = sessionData['details']?['Datatypeofcontent']?.toString().trim().toLowerCase();
  final int sessionId = sessionData['session_ID_'] ?? -1; // <-- بدون widget.

  print("Attempting to start session ID: $sessionId, Type: '$sessionType'");

  // المقارنة والانتقال
  if (sessionType == "image") {
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
        // تمرير sessionData و jwtToken مباشرة (بدون widget.)
        ImageSessionScreen(sessionData: sessionData, jwtToken: jwtToken)
     ));
  } else if (sessionType == "text") {
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
        // تمرير sessionData و jwtToken مباشرة (بدون widget.)
        StorySessionScreen(sessionData: sessionData, jwtToken: jwtToken)
     ));
  } else {
     print("Error: Unknown or missing session type: '$sessionType'");
     ScaffoldMessenger.of(context).showSnackBar(
      // --- SnackBar لعرض رسالة الخطأ ---
      SnackBar(
         content: Text("خطأ: نوع الجلسة '$sessionType' غير معروف أو مفقود."), // رسالة توضيحية
         backgroundColor: Colors.redAccent, // لون مميز للخطأ
         duration: Duration(seconds: 3), // مدة ظهور الرسالة
       )
      // ----------------------------------
   );
  }
}, // نهاية onPressed//
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C73D9),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "ابدأ الجلسة",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04), // مسافة سفلية
              ],
            ),
          ),
        ),
      ),
    );
  }
}
