import 'package:flutter/material.dart';
import 'package:myfinalpro/screens/test3.dart';

import '../services/sucess_popup.dart';

class TestScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2C73D9),
      appBar: AppBar(
        backgroundColor: Color(0xff2C73D9),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16),
            child: IconButton(
              icon: Icon(Icons.chevron_right, color: Colors.white, size: 32),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  'اختر صورة الطفل السعيد',
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),

                // الصورة الأولى (الطفل السعيد - الإجابة الصحيحة)
                InkWell(
                  onTap: () {
                    showSuccessPopup(context,
                        ExerciseThreeScreen()); // ✅ عرض نافذة النجاح ثم الانتقال للتمرين الثالث
                  },
                  borderRadius: BorderRadius.circular(10),
                  splashColor: Color(0xff2C73D9).withOpacity(0.3),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 300,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/happy (1) 1.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // الصورة الثانية (الطفل الحزين - إجابة خاطئة)
                InkWell(
                  onTap: () {
                    print("تم اختيار: حزين");
                    // لا يحدث شيء لأن الإجابة خاطئة
                  },
                  borderRadius: BorderRadius.circular(10),
                  splashColor: Colors.redAccent.withOpacity(0.3),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 300,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/image 7.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
