import 'package:flutter/material.dart';
import 'package:myfinalpro/registration/AccountConformation.dart';
import 'package:myfinalpro/widget/custom.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool isYesSelected = false;
  bool isNoSelected = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
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
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                      // النقطة الصغيرة داخل الدائرة
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
                  Container(
                    width: screenWidth * 0.1,
                    height: 2,
                    color: Colors.grey,
                  ),
                  Container(
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: screenWidth * 0.035,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Text(
                "هل يتابع طفلك مع اخصائى نفسي؟",
                style: TextStyle(
                  color: Color(0xFF2C73D9),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // زر "لا"
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isNoSelected = !isNoSelected;
                        isYesSelected = false;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          "لا",
                          style: TextStyle(
                            color: Color(0xFF2C73D9),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Container(
                          width: screenWidth * 0.06,
                          height: screenWidth * 0.06,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isNoSelected ? Colors.blue : Colors.transparent,
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.5),

                  // زر "نعم"
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isYesSelected = !isYesSelected;
                        isNoSelected = false;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          "نعم",
                          style: TextStyle(
                            color: Color(0xFF2C73D9),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Container(
                          width: screenWidth * 0.06,
                          height: screenWidth * 0.06,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isYesSelected
                                ? Colors.blue
                                : Colors.transparent,
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
              Text(
                "معلومات الأخصائي النفسي لطفلك",
                style: TextStyle(
                  color: Color(0xFF2C73D9),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              CustomTextField(
                hintText: "ادخل اسم الاخصائي  بالكامل",
                obscureText: false,
                onChanged: (value) {},
              ),
              SizedBox(height: screenHeight * 0.01),
              CustomTextField(
                hintText: "ادخل  البريد الالكتروني للاخصائي",
                obscureText: false,
                onChanged: (value) {},
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: CustomTextField(
                          hintText: 'رقم الهاتف',
                          obscureText: false,
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {})),
                  SizedBox(
                    width: screenWidth * 0.02,
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        fillColor: Color(0xFFE6E9EA),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06),
                          child: SizedBox(
                            width: screenWidth * 0.18,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "+20",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Image.asset(
                                  'assets/images/emojione-v1_flag-for-egypt.png',
                                  width: screenWidth * 0.06,
                                  height: screenHeight * 0.02,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AccountConformation()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2C73D9),
                  // اللون الأزرق
                  minimumSize: Size(screenWidth * 0.8, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  "إنشاء حساب",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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
