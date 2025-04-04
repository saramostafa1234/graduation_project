import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myfinalpro/registration/confirmphonenumber.dart';

class AccountConformation extends StatefulWidget {
  const AccountConformation({super.key});

  @override
  State<AccountConformation> createState() => _AccountConformationState();
}

class _AccountConformationState extends State<AccountConformation> {
  bool isYesSelected = false;
  bool isNoSelected = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Text(
            "تأكيد الحساب",
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
                )),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.05),
            Center(
              child: Image.asset(
                "assets/images/Group 1171275992.png",
                width: screenWidth * 0.8,
                height: screenHeight * 0.29,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.07,
            ),
            Text(
              "كيف تفضل تأكيد الحساب؟ ",
              style: TextStyle(
                color: Color(0xFF2C73D9),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.06,
                  height: screenWidth * 0.06,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFF2C73D9), width: 2),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "عبر البريد الإلكتروني",
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
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
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
            SizedBox(
              height: screenHeight * 0.02,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isNoSelected = !isNoSelected;
                  isYesSelected = false;
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ConfirmCode()));
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isNoSelected ? Colors.blue : Colors.transparent,
                      border: Border.all(color: Color(0xFF2C73D9), width: 2),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          " عبر رقم الهاتف",
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
                  SizedBox(
                      width: screenWidth *
                          0.04), // تقليل المسافة بين العمود والدائرة اليمينية
                  // الدائرة على اليمين مع الأيقونة
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
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
            )
          ],
        ),
      ),
    );
  }
}
