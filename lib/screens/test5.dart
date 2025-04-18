import 'package:flutter/material.dart';
import 'package:myfinalpro/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestScreen5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2C73D9),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // 🔹 زيادة ارتفاع الـ AppBar
        child: AppBar(
          backgroundColor: Color(0xff2C73D9),
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.end, // 🔹 دفع النص للأسفل
            children: [
              SizedBox(
                height: 32,
              ),
              Text(
                'حصل الطفل على هدية جديدة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8), // 🔹 مسافة تحت العنوان
            ],
          ),
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),

              // الفقرة النصية
              Text(
                '"عندما تلقى الطفل هدية جديدة، شعر بالسعادة. قرر أن يشكر الشخص الذي قدمها له وقال: "شكرًا لك، أحب هذه الهدية.',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),

              SizedBox(height: 80),

              // السؤال
              Center(
                child: Text(
                  'اختر ماذا يجب أن يفعل؟',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 32),

              // زر الإجابة الصحيحة
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85, // عرض مناسب
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'يشكر الشخص بهدوء',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xff2C73D9),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32),

              // زر الإجابة الخاطئة
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85, // عرض مناسب
                  child: ElevatedButton(
                    onPressed: () {
                      print("إجابة خاطئة: يركض حول الغرفة ويصرخ");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'يركض حول الغرفة ويصرخ',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xff2C73D9),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  // final prefs = await SharedPreferences.getInstance();
                  // await prefs.setInt(
                  //     'lastSessionTime', DateTime.now().millisecondsSinceEpoch);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen())); // الانتقال إلى HomeScreen
                },
                child: Text("back to home"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
