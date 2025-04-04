import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

class NotificationIcon extends StatefulWidget {
  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  final GlobalKey _iconKey = GlobalKey(); // مفتاح لتحديد موقع الأيقونة
  bool _isNotificationOpen =
      false; // متغير لتتبع حالة فتح أو إغلاق قائمة الإشعارات

  // قائمة تحتوي على الإشعارات مع العناوين والأوقات
  List<Map<String, String>> notifications = [
    {"title": "الجلسة تبدأ بعد ساعتين.", "time": "5 س"},
    {"title": "انتهت الجلسة.", "time": "1 س"},
    {"title": "لا تنسَ إتمام التقييم الشهري", "time": "30 د"},
  ];

  // دالة لفتح أو إغلاق قائمة الإشعارات
  void _toggleNotifications(BuildContext context) {
    setState(() {
      _isNotificationOpen = !_isNotificationOpen;
    });

    if (_isNotificationOpen) {
      // الحصول على موقع أيقونة الإشعارات على الشاشة
      final RenderBox renderBox =
          _iconKey.currentContext!.findRenderObject() as RenderBox;
      final Offset position = renderBox.localToGlobal(Offset.zero);

      // إظهار النافذة المنبثقة عند النقر على أيقونة الإشعارات
      showDialog(
        context: context,
        barrierColor: Colors.transparent, // جعل الخلفية شفافة
        builder: (context) => GestureDetector(
          onTap: () {
            // إغلاق القائمة عند النقر خارجها
            setState(() {
              _isNotificationOpen = false;
            });
            Navigator.of(context).pop();
          },
          child: Stack(
            children: [
              // تأثير التمويه للخلفية مع لون شفاف
              Positioned.fill(
                child: Container(
                  color: Colors.black
                      .withOpacity(0.3), // شفافية للخلفية لتمييز الإشعارات
                ),
              ),
              // تحديد موقع صندوق الإشعارات أسفل أيقونة الجرس
              Positioned(
                top: position.dy + renderBox.size.height + 5,
                // تحديد موقع القائمة أسفل الجرس
                right: 16,
                // ضبطها ناحية اليمين
                left: 16,
                // تمديدها للعرض المناسب
                child: Material(
                  color: Colors.transparent, // جعل المادة شفافة
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    // جعل القائمة تستوعب 90% من عرض الشاشة
                    padding: EdgeInsets.all(16),
                    // إضافة مسافة داخلية
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // لون الخلفية أبيض
                      borderRadius: BorderRadius.circular(20),
                      // تدوير الحواف
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10)
                      ], // إضافة ظل خفيف
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      // محاذاة المحتوى لليمين
                      children: [
                        // عنوان قسم الإشعارات
                        Text(
                          "الإشعارات",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 10), // مسافة فاصلة
                        // عرض قائمة الإشعارات
                        ...notifications.map((notification) => Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              // مسافة بين كل إشعار
                              padding: EdgeInsets.all(12),
                              // مسافة داخلية
                              decoration: BoxDecoration(
                                color: Colors.white,
                                // لون الخلفية أبيض
                                borderRadius: BorderRadius.circular(15),
                                // تدوير الحواف
                                border: Border.all(
                                    color:
                                        Colors.grey.shade300), // تحديد الإطار
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                // محاذاة العناصر لليمين
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .end, // محاذاة النص لليمين
                                      children: [
                                        // نص عنوان الإشعار
                                        Text(
                                          notification["title"]!,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.right,
                                        ),
                                        SizedBox(height: 5),
                                        // مسافة بين النصوص
                                        // نص وقت الإشعار
                                        Text(
                                          notification["time"]!,
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  // مسافة بين النص والأيقونة
                                  // أيقونة الجرس داخل دائرة
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    child: Icon(Icons.notifications,
                                        color: Colors.blue),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).then((_) {
        // إغلاق الإشعارات عند إغلاق النافذة المنبثقة
        setState(() {
          _isNotificationOpen = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 16),
      // إضافة مسافة من الأعلى واليمين
      child: GestureDetector(
        key: _iconKey,
        // تحديد موقع الأيقونة
        onTap: () => _toggleNotifications(context),
        // استدعاء دالة فتح/إغلاق الإشعارات عند النقر
        child: badges.Badge(
          position: badges.BadgePosition.topEnd(top: -5, end: -5),
          // تحديد موقع الشارة الحمراء
          showBadge: notifications.isNotEmpty,
          // إظهار الشارة فقط إذا كان هناك إشعارات
          badgeContent: Text(
            notifications.length.toString(), // عدد الإشعارات غير المقروءة
            style: TextStyle(
                color: Colors.white, fontSize: 12), // تصميم النص داخل الشارة
          ),
          child: Icon(Icons.notifications,
              color: Color(0xff2C73D9), size: 28), // أيقونة الجرس
        ),
      ),
    );
  }
}
