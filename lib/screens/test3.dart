import 'package:flutter/material.dart';
import 'package:myfinalpro/screens/test4.dart';

import '../services/sucess_popup.dart'; // استدعاء نافذة النجاح

class ExerciseThreeScreen extends StatelessWidget {
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
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  'تخيَّل أن والدك أحضر لك لعبة جديدة \nكيف ستكون؟',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),

                // زر الإجابة الصحيحة (سعيد) - عند الضغط، يظهر بوب-أب النجاح
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showSuccessPopup(
                          context, TestScreen4()); // ✅ الانتقال للتمرين الرابع
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'سعيد',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xff2C73D9),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // زر الإجابة الخاطئة (حزين) - لا يحدث شيء عند الضغط
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print("إجابة خاطئة: حزين");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'حزين',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xff2C73D9),
                          fontWeight: FontWeight.bold),
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
