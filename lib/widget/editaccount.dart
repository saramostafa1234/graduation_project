import 'package:flutter/material.dart';
import 'package:myfinalpro/widget/textfield.dart';

import 'changePassword.dart';
//import 'custom_text_field.dart'; // تأكدي من صحة مسار الملف

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              "تعديل الملف الشخصي",
              style: TextStyle(
                color: Color(0xFF2C73D9),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_right_outlined,
                  size: 40,
                  color: Color(0xFF2C73D9),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.02),
              // صورة الملف الشخصي مع أيقونة الكاميرا وعلامة زائد
              Center(
                child: Stack(
                  children: [
                    // الصورة البيضاوية
                    ClipOval(
                      child: Container(
                        width: screenWidth * 0.3,
                        height: screenWidth * 0.39,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Image.asset(
                          "assets/images/Ellipse 39.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // أيقونة الكاميرا مع علامة زائد في الركن السفلي الأيمن
                    Positioned(
                      bottom: 4,
                      right: 8,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: screenWidth * 0.09,
                            color: Colors.blue,
                          ),
                          Positioned(
                            bottom: 2,
                            right: 3,
                            child: Container(
                              width: screenWidth * 0.03,
                              height: screenWidth * 0.03,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                              child: Icon(
                                Icons.add,
                                size: screenWidth * 0.03,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              // حقول الإدخال باستخدام CustomProfileTextField:
              const CustomProfileTextField(
                label: "اسم الطفل ",
                hint: "أدخل اسم طفلك",
              ),
              const CustomProfileTextField(
                label: " تاريخ ميلاد الطفل ",
                hint: "أدخل تاريخ ميلاد طفلك",
              ),
              const CustomProfileTextField(
                label: "اسم المستخدم",
                hint: "ادخل اسمك",
              ),
              const CustomProfileTextField(
                label: "رقم الهاتف او البريد الالكتروني",
                hint: "أدخل رقمك او بريدك الالكتروني",
              ),
              CustomProfileTextField(
                label: "كلمة السر",
                hint: "أدخل كلمة السر",
                obscureText: _obscurePassword,
                suffixIcon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF2C73D9),
                ),
                onSuffixIconPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              SizedBox(height: screenHeight * 0.001),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    //التنقل إلى صفحة تغيير كلمة المرور
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChangePassword()),
                    );
                  },
                  child: const Text(
                    "تغير كلمة المرور",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const CustomProfileTextField(
                label: "اسم الاخصائى ",
                hint: "أدخل  اسم الأخصائي",
              ),
              const CustomProfileTextField(
                label: "البريد الالكتروني للاخصائي",
                hint: "أدخل البريد الألكتروني للأخصائي",
              ),
              const CustomProfileTextField(
                label: "رقم الاخصائي",
                hint: "ادخل رقم تليفون الأخصائي",
              ),
              SizedBox(height: screenHeight * 0.04),
              ElevatedButton(
                onPressed: () {
                  // حفظ التغييرات هنا
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C73D9),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "حفظ ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: EditProfileScreen(),
  ));
}
