import 'package:flutter/material.dart';
//import 'package:gp1/screens/test1.dart';
import 'package:myfinalpro/screens/test1.dart'; // شاشة التمرين الأول

class StartTest extends StatelessWidget {
  const StartTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2C73D9),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'حان وقت الاختبار',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2C73D9)),
                  ),
                  //const SizedBox(height: ),

                  // عرض صورة GIF
                  Image.asset(
                    'assets/images/clock.gif',
                    width: 200,
                    height: 150,
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TestScreen1()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff2C73D9),
                          padding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'ابدأ الاختبار',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
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

          // سهم الرجوع
          Positioned(
            top: 32,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.chevron_right,
                  size: 35, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // يرجع إلى الشاشة السابقة
              },
            ),
          ),
        ],
      ),
    );
  }
}
