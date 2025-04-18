import 'package:equatable/equatable.dart'; // لاستخدام Equatable لتبسيط مقارنة الكائنات

//--------------------------------------------------
// الكلاس المجرد الأساسي لجميع أنواع الفشل (Failures)
// الـ UI Layer ستتعامل مع هذا النوع أو الأنواع المشتقة منه.
//--------------------------------------------------
abstract class Failure extends Equatable {
  // رسالة الخطأ التي يمكن عرضها للمستخدم أو تسجيلها
  final String message;

  // Constructor يتطلب رسالة الخطأ
  const Failure(this.message);

  // --- استخدام Equatable ---
  // نضع الخصائص التي نريد المقارنة على أساسها هنا
  // في هذه الحالة، رسالة الخطأ هي الخاصية المميزة
  @override
  List<Object> get props => [message];

  // يمكنك إضافة خصائص أخرى مشتركة بين أنواع الفشل هنا إذا أردت
  // مثلاً: final int? statusCode;
}

//--------------------------------------------------
// أنواع الفشل المحددة (Specific Failure Types)
// يمكنك إنشاء كلاسات مشتقة لتمييز أنواع الأخطاء المختلفة
// مما يسمح للـ UI بعرض رسائل أو سلوكيات مختلفة لكل نوع.
//--------------------------------------------------

/// يُستخدم عندما يحدث خطأ أثناء التواصل مع الخادم (API).
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
  // يمكنك إضافة تفاصيل أخرى خاصة بأخطاء الخادم هنا
  // final int? statusCode;
  // const ServerFailure(String message, {this.statusCode}) : super(message);
  // @override List<Object> get props => [message, statusCode ?? 0];
}

/// يُستخدم عندما يحدث خطأ أثناء التعامل مع التخزين المؤقت المحلي (Cache).
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// يُستخدم عندما لا يكون هناك اتصال بالشبكة.
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// يُستخدم عندما تكون البيانات المدخلة من المستخدم غير صالحة.
class InvalidInputFailure extends Failure {
  const InvalidInputFailure(String message) : super(message);
}

