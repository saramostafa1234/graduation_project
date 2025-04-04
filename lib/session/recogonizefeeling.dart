import 'package:flutter/material.dart';
import 'package:myfinalpro/session/managefeeling.dart';

class RecognizeFelling extends StatelessWidget {
  const RecognizeFelling({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2C73D9), // خلفية زرقاء
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // مسافة علوية
                SizedBox(height: screenHeight * 0.04),

                // السهم في أعلى اليمين
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_right_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      Navigator.pop(context); // يرجع للصفحة السابقة
                    },
                  ),
                ),

                // مسافة تحت السهم
                SizedBox(height: screenHeight * 0.01),

                // النص العلوي في المنتصف
                const Text(
                  " إدراك الفرح للاخر",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                // مسافة تحت النص العلوي
                SizedBox(height: screenHeight * 0.04),

                // Container أبيض في المنتصف يحتوي على نصين
                Center(
                  child: Container(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.5, // يمكنك تعديل الارتفاع
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          screenWidth * 0.01), // ريديوس أكبر
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // مسافة بسيطة فوق النص الأول
                          SizedBox(height: screenHeight * 0.02),

                          // النص الأول في الأعلى وبالمنتصف
                          const Text(
                            "الموقف الأول",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF2C73D9),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // مسافة قبل النص الثاني
                          SizedBox(height: screenHeight * 0.1),

                          // النص الثاني أقرب لمنتصف الـ Container
                          const Text(
                            " لقد حصل  أخيك على درجات عالية في الامتحان وهو سعيد جدًا. هل ترى ابتسامته؟ نحن جميعًا سعداء له",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Color(0xFF2C73D9),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // مسافة تحت الـ Container
                SizedBox(height: screenHeight * 0.07),

                // زر "التالي" بعرض أكبر وزوايا أكثر استدارة
                Center(
                  child: SizedBox(
                    width: screenWidth * 0.8, // عرض أكبر
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ManageFelling()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              screenWidth * 0.03), // ريديوس أكبر
                        ),
                      ),
                      child: const Text(
                        "التالي",
                        style: TextStyle(
                          color: Color(0xFF2C73D9),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                // مسافة أخيرة أسفل الزر
                //SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
