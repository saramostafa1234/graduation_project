import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ChatBotScreen(),
  ));
}

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // AppBar بشفافية بسيطة (يمكنك جعله شفاف تمامًا بتعديل الألوان)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 0,
        // إخفاء المساحة الافتراضية للزر
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "شات بوت",
          style: TextStyle(
            color: Color(0xFF2C73D9),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.keyboard_arrow_right_outlined,
              color: Color(0xFF2C73D9),
              size: 35,
            ),
          ),
        ],
      ),

      // خلفية بيضاء
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // مساحة بسيطة تحت الـ AppBar
              SizedBox(height: screenHeight * 0.02),

              // قائمة الرسائل
              Expanded(
                child: ListView(
                  // لجعل الرسائل من الأسفل للأعلى يمكن استخدام reverse: true
                  children: [
                    // رسالة من الشات بوت
                    ChatBubbleBot(
                      text: "كيف يمكنني مساعدتك؟",
                      screenWidth: screenWidth,
                    ),
                    // رسالة من المستخدم
                    ChatBubbleUser(
                      text: "ما عدد الجلسات في الأسبوع؟",
                      screenWidth: screenWidth,
                    ),
                    // رسالة من الشات بوت
                    ChatBubbleBot(
                      text:
                          "  تُفتح جلسة جديدة بعد 48 ساعة من انتهاء الجلسة السابقة، بمعدل 3 مرات في الأسبوع.",
                      screenWidth: screenWidth,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// فقاعات رسائل الشات بوت (يسار الشاشة + أيقونة روبوت)
class ChatBubbleBot extends StatelessWidget {
  final String text;
  final double screenWidth;

  const ChatBubbleBot({
    Key? key,
    required this.text,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لأن الواجهة عربية
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة الروبوت على يمين الفقاعة
          Container(
            margin: EdgeInsets.only(top: 8, right: 4),
            width: screenWidth * 0.08,
            height: screenWidth * 0.08,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2C73D9),
            ),
            child: const Icon(
              Icons.smart_toy, // أيقونة الروبوت
              color: Colors.white,
              size: 20,
            ),
          ),

          // الفقاعة نفسها
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.transparent, // لون فاتح للروبوت
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// فقاعات رسائل المستخدم (يمين الشاشة)
class ChatBubbleUser extends StatelessWidget {
  final String text;
  final double screenWidth;

  const ChatBubbleUser({
    Key? key,
    required this.text,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لأن الواجهة عربية
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الفقاعة نفسها
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2C73D9), // لون أزرق للمستخدم
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
