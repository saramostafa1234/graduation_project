import 'package:flutter/material.dart';
import 'package:myfinalpro/screens/test5.dart';

import '../services/sucess_popup.dart'; // استدعاء نافذة النجاح

class TestScreen4 extends StatelessWidget {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // يبدأ من اليسار (أو اليمين بالعربي)
            children: [
              SizedBox(height: 32),

              // السؤال
              Text(
                'هذه الطفلة فازت بالمسابقة، كيف تعتقد أنها تشعر؟',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),

              SizedBox(height: 32),

              // صورة الطفل
              Center(
                // لجعل الصورة في المنتصف
                child: Container(
                  width: 340,
                  height: 360,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/happy (1) 1.png',
                      // استبدل بالمسار الصحيح للصورة
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32),

              // زر الإجابة الصحيحة (سعيد)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showSuccessPopup(context, TestScreen5());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'سعيد',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff2C73D9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // زر الإجابة الخاطئة (حزين)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print("إجابة خاطئة: حزين");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'حزين',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff2C73D9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
