import 'package:flutter/material.dart';

class About_App extends StatefulWidget {
  const About_App({super.key});

  @override
  State<About_App> createState() => _About_AppState();
}

class _About_AppState extends State<About_App> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 28),
          child: Text(
            "حول التطبيق ",
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
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الصف الأول
            InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Color(0xFF2C73D9),
                      size: 30,
                    ),
                    SizedBox(width: 20),
                    Text(
                      " ما هو AspIQ ؟",
                      style: TextStyle(
                        color: Color(0xFF2C73D9),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // مسافة بين الصف والمربع
            if (isExpanded) SizedBox(height: screenHeight * 0.02),
            // المربع الذي يحتوي على النص
            if (isExpanded)
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFF2C73D9), width: 1),
                ),
                child: Text(
                  "تطبيق AspIQ يهدف إلى دعم الأطفال المصابين بمتلازمة أسبرجر وأقرانهم في تطوير مهارات الذكاء الوجداني والاجتماعي. من خلال التدريب الموجه والأنشطة التفاعلية، يساعد التطبيق الأطفال على فهم مشاعرهم والتحكم فيها، وكذلك فهم مشاعر الآخرين والتفاعل معها بشكل إيجابي. إلى جانب ذلك، يركز التطبيق أيضًا على تنمية المهارات الاجتماعية والعاطفية التي تساهم في تعزيز قدرة الطفل على التفاعل بشكل إيجابي في مختلف المواقف الاجتماعية، وتحسين مهارات التواصل والتعاون وحل المشكلات. من خلال الأنشطة المتنوعة، يمكن للأطفال تعلم كيفية بناء علاقات اجتماعية صحية، إدارة الانفعالات بشكل مناسب، والتفاعل مع الآخرين بطرق تساعدهم على التكيف بنجاح في بيئاتهم الاجتماعية.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0XFF2C73D9),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            SizedBox(height: screenHeight * 0.02),
            // الصف الثاني
            InkWell(
              onTap: () {
                // أضف الكود المناسب هنا
                print("تم الضغط على: عن التطبيق");
              },
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF2C73D9),
                      size: 30,
                    ),
                    SizedBox(width: 20),
                    Text(
                      "الفئه المستهدفه",
                      style: TextStyle(
                        color: Color(0xFF2C73D9),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // الصف الثالث
            InkWell(
              onTap: () {
                // أضف الكود المناسب هنا
                print("تم الضغط على: الإصدارات");
              },
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF2C73D9),
                      size: 30,
                    ),
                    SizedBox(width: 20),
                    Text(
                      "المستويات",
                      style: TextStyle(
                        color: Color(0xFF2C73D9),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // الصف الرابع
            InkWell(
              onTap: () {
                // أضف الكود المناسب هنا
                print("تم الضغط على: الشروط والأحكام");
              },
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF2C73D9),
                      size: 30,
                    ),
                    SizedBox(width: 20),
                    Text(
                      "كيف يعمل AspIQ ؟",
                      style: TextStyle(
                        color: Color(0xFF2C73D9),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
