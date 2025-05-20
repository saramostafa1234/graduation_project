// lib/models/session_model.dart
import 'dart:math'; // لـ min

// --- كلاس Session ---
class Session {
  final int? sessionId;
  final String? title;
  final String? description; // يستخدم في IntroScreen (الإرشادات)
  final String? goal; // يستخدم في IntroScreen (الأهداف)
  final int? groupId;
  final int typeId; // يستخدم لتحديد الألوان مثلاً
  final int? detailsCount; // عدد التمارين الكلي المتوقع
  final List<SessionDetail> details; // قائمة التمارين الأساسية (1-4 عادة)
  final SessionDetail? newDetail; // الكائن الإضافي المستخدم في التمرين قبل الأخير

  // داخل كلاس Session
  int get id => sessionId ?? 0;

  Session({
    this.sessionId,
    this.title,
    this.description,
    this.goal,
    this.groupId,
    required this.typeId,
    this.detailsCount,
    required this.details, // قائمة التمارين الأساسية
    this.newDetail, // الكائن الإضافي
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    List<SessionDetail> detailsList = [];
    SessionDetail? newDetailParsed;

    // تحليل قائمة details الأساسية
    dynamic detailsData = json['details'];
    if (detailsData != null) {
      dynamic valuesList =
          (detailsData is Map<String, dynamic>) ? detailsData['\$values'] : null;
      List? sourceList = (valuesList != null && valuesList is List)
          ? valuesList
          : (detailsData is List ? detailsData : null);

      if (sourceList != null) {
        for (var v in sourceList) {
          if (v is Map<String, dynamic>) {
            try {
              detailsList.add(SessionDetail.fromJson(v));
            } catch (e) {
              print(
                  "Error parsing SessionDetail from details list: $e\nData: $v");
            }
          }
        }
      } else {
        print(
            "Warning: 'details'/'\$values' key is not a parsable list in Session JSON.");
      }
    } else {
      print("Warning: 'details' key not found in Session JSON.");
    }

    // تحليل newDetail بشكل منفصل
    dynamic newDetailData = json['newDetail'];
    if (newDetailData != null && newDetailData is Map<String, dynamic>) {
      try {
        newDetailParsed = SessionDetail.fromJson(newDetailData);
        // إذا كنت تريد طباعة الـ id الأصلي لـ newDetail:
        // print("Parsed newDetail successfully (ID from source: ${newDetailParsed?.originalDetailId}).");
      } catch (e) {
        print("Error parsing newDetail: $e\nData: $newDetailData");
      }
    } else {
      print("Info: newDetail object not found or invalid in Session JSON.");
    }

    final expectedCount = json['detailsCount'] as int?;
    if (expectedCount != null && detailsList.length != expectedCount) {
      print(
          "Warning: detailsCount ($expectedCount) does not match actual details list length (${detailsList.length}).");
    }

    return Session(
      sessionId: json['sessionId'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      goal: json['goal'] as String?,
      groupId: json['groupId'] as int?,
      typeId: json['typeId'] as int? ?? 1,
      detailsCount: expectedCount,
      details: detailsList,
      newDetail: newDetailParsed,
    );
  }
}

// --- كلاس SessionDetail ---
class SessionDetail {
  final int id; // ID للتمرين (يأخذ قيمة `id` أو `detail_ID` من JSON)
  final int? originalDetailId; // سيخزن قيمة `detail_ID` الأصلية من JSON إذا وجدت
  final String? datatypeOfContent; // "Img" أو "Text" أو "Video" أو null
  final String? text;
  final String? image;
  final String? video; // <--- حقل الفيديو موجود بالفعل، جيد!
  final String? story;
  final String? sound;
  final String? part;
  final String? more;
  final int? itemGroupId;
  final String? itemGroupName;
  final String? desc;

  SessionDetail({
    required this.id,
    this.originalDetailId, // <--- إضافة للكونستركتور
    this.datatypeOfContent,
    this.text,
    this.image,
    this.video,
    this.story,
    this.sound,
    this.part,
    this.more,
    this.itemGroupId,
    this.itemGroupName,
    this.desc,
  });

  factory SessionDetail.fromJson(Map<String, dynamic> json) {
    int parsedId;
    final idValue = json['id'] ?? json['detail_ID']; // الأولوية لـ id ثم detail_ID كمعرف أساسي للكائن
    if (idValue != null && idValue is int) {
      parsedId = idValue;
    } else if (idValue != null && idValue is String) {
      parsedId = int.tryParse(idValue) ?? 0;
    } else {
      print("Warning: Missing or invalid ID (from 'id' or 'detail_ID'). Using 0. Data: $json");
      parsedId = 0;
    }

    // قراءة detail_ID بشكل منفصل لتخزينه إذا كنت تحتاجه كما هو
    int? parsedOriginalDetailId;
    final detailIdSourceValue = json['detail_ID'];
    if (detailIdSourceValue != null && detailIdSourceValue is int) {
      parsedOriginalDetailId = detailIdSourceValue;
    } else if (detailIdSourceValue != null && detailIdSourceValue is String) {
      parsedOriginalDetailId = int.tryParse(detailIdSourceValue);
    }
    // إذا لم يكن detail_ID موجودًا، سيبقى originalDetailId قيمة null


    final textValue = json['text_'] ?? json['text'];
    final imageValue = json['image_'] ?? json['image'];
    String? imagePath = imageValue as String?;
    if (imagePath != null) {
      imagePath = imagePath.replaceAll('\\', '/').trim();
    }

    return SessionDetail(
      id: parsedId,
      originalDetailId: parsedOriginalDetailId, // <--- تمرير القيمة المقروءة
      datatypeOfContent: json['datatypeOfContent'] as String?,
      text: textValue as String?,
      image: imagePath,
      video: json['video'] as String?, // حقل الفيديو يقرأ بالفعل
      story: json['story'] as String?,
      sound: json['sound'] as String?,
      part: json['part'] as String?,
      more: json['more'] as String?,
      itemGroupId: json['groupId'] as int?,
      itemGroupName: json['groupName'] as String?,
      desc: json['desc'] as String?,
    );
  }

  // Getters مساعدة
  bool get hasImage => image != null && image!.isNotEmpty;
  bool get hasText => text != null && text!.isNotEmpty;
  bool get hasDesc => desc != null && desc!.isNotEmpty;
  bool get hasVideo => video != null && video!.isNotEmpty; // <--- إضافة getter للفيديو
}