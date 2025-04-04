import 'package:flutter/material.dart';

//import 'package:myfinalpro/session/manage%20feeling.dart';
import 'package:myfinalpro/session/recogonizefeeling.dart';

class CameraSession extends StatelessWidget {
  const CameraSession({Key? key}) : super(key: key);

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
                SizedBox(height: screenHeight * 0.04),
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
                  "قلّد هذا الطفل!",
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
                    child: Image.asset(
                      "assets/images/happy (2) 1.png",
                      // عدّلي المسار حسب مشروعك
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // مسافة تحت الـ Container
                SizedBox(height: screenHeight * 0.04),

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
                                builder: (context) => RecognizeFelling()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              screenWidth * 0.03), // ريديوس أكبر
                        ),
                      ),
                      child: const Text(
                        "افتح الكاميرا وابدأ التقليد",
                        style: TextStyle(
                          color: Color(0xFF2C73D9),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                //SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
