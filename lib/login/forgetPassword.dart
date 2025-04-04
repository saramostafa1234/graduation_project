import 'package:flutter/material.dart';
import 'package:myfinalpro/login/resetpasswordbyemail.dart';
import 'package:myfinalpro/login/resetpasswordbyphone.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  // متغير لتخزين الطريقة المختارة: "email" أو "phone"
  String? selectedMethod;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double boxSize = screenWidth * 0.06; // حجم الدائرة على اليسار
    double iconBoxSize =
        screenWidth * 0.12; // حجم الدائرة على اليمين (التي تحتوي على الأيقونة)

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Text(
            "نسيت كلمة المرور؟",
            style: TextStyle(
              color: Color(0xFF2C73D9),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.keyboard_arrow_right_outlined,
                size: 40,
                color: Color(0xFF2C73D9),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),
              Center(
                child: Image.asset(
                  "assets/images/amico.png",
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.29,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * 0.07),
              Text(
                "كيف تفضل استعادة حسابك؟",
                style: TextStyle(
                  color: Color(0xFF2C73D9),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // صف المتابعة عبر البريد الإلكتروني
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMethod = "email";
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // الدائرة على اليسار (للبريد الإلكتروني)
                    Container(
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFF2C73D9), width: 2),
                        color: selectedMethod == "email"
                            ? Colors.blue
                            : Colors.transparent,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    // العمود الذي يحتوي على النصوص
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "المتابعة عبر البريد الإلكتروني",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.002),
                          Text(
                            "البريد الإلكتروني المرتبط بحسابك",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    // الدائرة على اليمين مع أيقونة @
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: iconBoxSize,
                          height: iconBoxSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2C73D9),
                          ),
                        ),
                        Icon(
                          Icons.alternate_email,
                          color: Colors.white,
                          size: screenWidth * 0.06,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // صف المتابعة عبر رقم الهاتف
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMethod = "phone";
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // الدائرة على اليسار (لرقم الهاتف)
                    Container(
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFF2C73D9), width: 2),
                        color: selectedMethod == "phone"
                            ? Colors.blue
                            : Colors.transparent,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "المتابعة عبر رقم الهاتف",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.002),
                          Text(
                            "رقم الهاتف المرتبط بحسابك",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: iconBoxSize,
                          height: iconBoxSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2C73D9),
                          ),
                        ),
                        Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: screenWidth * 0.06,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.08),
              ElevatedButton(
                onPressed: () {
                  if (selectedMethod == "email") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ResetPassword()),
                    );
                  } else if (selectedMethod == "phone") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Resetpasswordbyphone()),
                    );
                  } else {
                    print("لم يتم اختيار طريقة");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2C73D9),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: const Text(
                  "متابعة",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
