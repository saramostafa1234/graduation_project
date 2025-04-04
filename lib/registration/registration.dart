import 'package:flutter/material.dart';
//import 'package:myfinalpro/create%20Account.dart';
import 'package:myfinalpro/login/login_view.dart';

import '../widget/custom.dart';
import 'create Account.dart';

class RegistrationView extends StatefulWidget {
  RegistrationView({super.key});

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    //IconButton(onPressed: (){}, icon:Icon(Icons.arrow_back_ios_new_rounded) )
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.06),
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenWidth * 0.1,
                  ),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        "assets/images/image-removebg-preview (5) 2.png",
                        width: screenWidth * 0.4,
                        height: screenHeight * 0.2,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.keyboard_arrow_right_outlined,
                        size: 40,
                        color: Color(0xFF2C73D9),
                      ))
                ],
              ),

              Text(
                "إنشاء حساب",
                style: TextStyle(
                  color: Color(0xFF2C73D9),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     CircleAvatar(
              //       radius: screenWidth * 0.03,
              //       backgroundColor: Colors.blue,
              //     ),
              //     Container(
              //       width: screenWidth * 0.2,
              //       height: 3,
              //       color: Color(0xFFC7C0C0),
              //     ),
              //     CircleAvatar(
              //       radius: screenWidth * 0.03,
              //       backgroundColor: Color(0xFFC7C0C0),
              //     ),
              //   ],
              // ),
              // 🎨 شكل الدوائر المتصلة بخط
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.1,
                    height: 2,
                    color: Colors.grey,
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.06,
                        height: screenWidth * 0.06,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.023,
                        height: screenWidth * 0.023,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.03),
              CustomTextField(
                hintText: "ادخل اسم الطفل بالكامل",
                obscureText: false,
                onChanged: (value) {},
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomTextField(
                hintText: "ادخل تاريخ ميلاد الطفل ",
                obscureText: false,
                onChanged: (value) {},
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomTextField(
                hintText: "ادخل  اسم المستخدم ",
                obscureText: false,
                onChanged: (value) {},
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomTextField(
                hintText: "ادخل  بريد الالكتروني او رقم هاتف ",
                obscureText: false,
                onChanged: (value) {},
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomTextField(
                  hintText: "أدخل كلمة المرور",
                  obscureText: _obscureText,
                  onChanged: (value) {},
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  }),
              SizedBox(height: screenHeight * 0.05),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateAccount()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2C73D9),
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginView()),
                      );
                    },
                    child: Text(
                      " قم بتسجيل الدخول",
                      style: TextStyle(
                        color: Color(0xFF2C73D9),
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // النص الأزرق
                  const Text(
                    " هل لديك حساب بالفعل ؟ ",
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: 19,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
