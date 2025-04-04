import 'package:flutter/material.dart';
import 'package:myfinalpro/session/Recognizing_feel.dart';

class SessionView extends StatefulWidget {
  const SessionView({super.key});

  @override
  State<SessionView> createState() => _SessionViewState();
}

class _SessionViewState extends State<SessionView> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      // لضمان عرض النصوص من اليمين لليسار
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // AppBar شفاف مع مساحة من الأعلى
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                "الجلسة الأولى",
                style: TextStyle(
                  color: Color(0xFF2C73D9),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            // تباعد عام للشاشة من الجوانب والأعلى والأسفل
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // السطر الأول: زمن الجلسة
                Row(
                  children: [
                    Text(
                      "زمن الجلسة:",
                      style: TextStyle(
                        color: Color(0xFF2C73D9),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Text(
                      "٤٥ دقيقة",
                      style: TextStyle(
                        color: Color(0xFF2C73D9),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.015),

                // عنوان الأهداف
                Text(
                  "أهداف الجلسة:",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF2C73D9),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Container الأهداف
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  // تباعد داخلي للكونتينر
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "١_ أن يتمكن الأطفال من التعرف على انفعال الفرح والسعادة من خلال الصور.",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xFF2C73D9),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "٢_ أن يكون الطفل قادراً على فهم وإدراك إنفعال الخوف لذاته أو للآخرين من خلال موقف معين.",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xFF2C73D9),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "٣_ أن يتمكن الطفل من إدارة وتنظيم إنفعال الغضب سواء لذاته أو للآخر من خلال مواقف حياتية.",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xFF2C73D9),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // عنوان الإرشادات
                Text(
                  "إرشادات الجلسة:",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF2C73D9),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Container الإرشادات
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "١_ ضرورة الجلوس فى المستوى البصرى للطفل وذلك لجذب إنتباهه.",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xFF2C73D9),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "٢_ تنظيم بيئة التدريب، تجنب المشتتات وأن تكون بيئة التدريب بعيدة عن الضوضاء.",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xFF2C73D9),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "٣_ استخدام أسلوب التواصل الفعال، والذي يتضمن استخدام لغة سهلة مبسطة مدعومة بالإشارات والتواصل غير اللفظي ولغة العيون وتعابير الوجه واليد.",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xFF2C73D9),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // زر متابعة أو أي إجراء آخر
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FeelingScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C73D9),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "التالي",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
