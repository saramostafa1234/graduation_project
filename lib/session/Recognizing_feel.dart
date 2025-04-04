import 'package:flutter/material.dart';

import '../services/break.dart';
import 'Perception of feeling  For self.dart';

class FeelingScreen extends StatelessWidget {
  const FeelingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2C73D9), // خلفية زرقاء
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // مسافة علوية
                SizedBox(height: screenHeight * 0.04),

                // السهم في أعلى اليمين
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.01),
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
                ),

                // مسافة بين السهم والنص
                SizedBox(height: screenHeight * 0.001),

                // النص في منتصف الشاشة أفقيًا
                const Text(
                  "التعرف على شعور الفرح",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                // مسافة تحت النص
                SizedBox(height: screenHeight * 0.03),

                // صورة كبيرة في المنتصف
                Center(
                  child: Container(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      // خلفية شبه شفافة (اختياري)
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      "assets/images/happy1 (18) 2.png",
                      // عدّلي المسار حسب مشروعك
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // مسافة تحت الصورة
                SizedBox(height: screenHeight * 0.04),

                // نص في المنتصف "هذا الطفل سعيد"
                const Text(
                  "هذا الطفل سعيد",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                // مسافة تحت النص
                SizedBox(height: screenHeight * 0.04),

                // زر "التالي"
                Center(
                  child: SizedBox(
                    width: screenWidth * 0.8, // عرض أكبر
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AnimatedWaveScreen(
                                    nextScreen: Feeling2Screen())));
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
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
