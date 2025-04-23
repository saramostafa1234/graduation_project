// lib/services/api_service.dart
import 'dart:developer';
import 'dart:convert';
import 'dart:io'; // لـ File
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // لـ MediaType
import 'dart:async'; // لاستخدام TimeoutException
import 'package:myfinalpro/session/models/session_model.dart'; // <-- تأكد من استيراد ملف المودلز
import 'package:myfinalpro/test/models/quiz_model.dart';
import 'package:flutter/foundation.dart';
import 'package:myfinalpro/models/test_dto.dart';
import 'package:myfinalpro/core/errors/failures.dart'; // تأكد من المسار الصحيح
import 'package:myfinalpro/core/serveses/shared_preferance_servace.dart';
import 'package:myfinalpro/core/network/dio_client.dart';

import '../monthly_test/monthly_test_response.dart';


class ApiService {
  // --- استخدم الـ Base URL المعرف لديك ---
  final Dio _dio;
  static const String baseUrl = 'http://aspiq.runasp.net/api';

   ApiService() : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    // يمكنك إضافة Interceptors هنا إذا لزم الأمر (مثل LogInterceptor)
    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (object) => log(object.toString()), // توجيه مخرجات dio إلى log
    ));
    // يمكنك إضافة interceptors أخرى للتعامل مع التوكن تلقائيًا، إلخ.
  }

  // --- loginUser --- (كما هو)
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      print('[ApiService.loginUser] Sending login request for email: $email');
      print('[ApiService.loginUser] Sending to URL: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // تأكد أن الـ API يتوقع Email و Password بالحروف الكبيرة/الصغيرة الصحيحة
        body: json.encode({'Email': email, 'Password': password}),
      );
      print('[ApiService.loginUser] API Status Code: ${response.statusCode}');
      print('[ApiService.loginUser] API Response Body: ${response.body}');
      dynamic responseData;
      String message = 'Unknown response';
      try {
        responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          message = responseData['message']?.toString() ??
              responseData['title']?.toString() ??
              message;
        } else {
          message = responseData.toString();
        }
      } catch (e) {
        print('[ApiService.loginUser] JSON Decode Error: $e');
        print(
            '[ApiService.loginUser] RAW RESPONSE BODY (on JSON decode error): ${response.body}');
        message =
            'API returned non-JSON response (Status ${response.statusCode})';
        responseData = {'rawErrorBody': response.body};
      }
      bool success = response.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData.containsKey('token');
      return {
        'success': success,
        'token': success ? responseData['token'] : null,
        'data': responseData,
        'statusCode': response.statusCode,
        'message': success ? 'Login successful' : message,
      };
    } catch (e) {
      print('[ApiService.loginUser] Network or other error during login: $e');
      return {
        'success': false,
        'message': 'Network error or request setup failed: $e',
        'error': e.toString(),
        'data': null,
        'statusCode': null,
        'token': null,
      };
    }
  }

  // --- registerUser --- (كما هو)
  static Future<Map<String, dynamic>> registerUser(
      Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/auth/register');
    try {
      print('[ApiService.registerUser] Sending Data: ${json.encode(userData)}');
      print('[ApiService.registerUser] Sending to URL: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );
      print(
          '[ApiService.registerUser] API Status Code: ${response.statusCode}');
      print('[ApiService.registerUser] API Response Body: ${response.body}');
      dynamic responseData;
      String message = 'Unknown response';
      try {
        responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          message = responseData['title']?.toString() ??
              responseData['message']?.toString() ??
              (responseData['errors'] != null
                  ? json.encode(responseData['errors'])
                  : null) ??
              message;
          if (message
                  .toLowerCase()
                  .contains("one or more validation errors occurred") ||
              responseData['errors'] != null) {
            if (responseData['errors']?['\$.birthDate'] != null) {
              message = 'خطأ في صيغة تاريخ الميلاد.';
            } else {
              message = 'خطأ في بيانات التسجيل.';
            }
            if (responseData['errors'] != null)
              print(
                  '[ApiService.registerUser] Validation Errors: ${json.encode(responseData['errors'])}');
          }
        } else {
          message = responseData.toString();
        }
      } catch (e) {
        print('[ApiService.registerUser] JSON Decode Error: $e');
        print(
            '[ApiService.registerUser] RAW RESPONSE BODY (on JSON decode error): ${response.body}');
        message =
            'API returned non-JSON response (Status ${response.statusCode})';
        responseData = {'rawErrorBody': response.body};
      }
      bool success = response.statusCode == 200 || response.statusCode == 201;
      return {
        'success': success,
        'data': responseData,
        'statusCode': response.statusCode,
        'message': success
            ? (responseData is Map && responseData.containsKey('message')
                ? responseData['message']?.toString() ??
                    'Registration successful'
                : 'Registration successful')
            : message,
      };
    } catch (e) {
      print(
          '[ApiService.registerUser] Network or other error during registration: $e');
      return {
        'success': false,
        'message': 'Network error or request setup failed: $e',
        'error': e.toString(),
        'data': null,
        'statusCode': null,
      };
    }
  }

  // --- addDoctor --- (كما هو)
  static Future<Map<String, dynamic>> addDoctor(String name,
      {String degree = "Therapist",
      String about = "Child's Therapist",
      String? email,
      String? phone}) async {
    try {
      final url = Uri.parse('$baseUrl/doctor/add-doctor');
      final Map<String, dynamic> payload = {
        'doc_Name': name,
        'degree': degree,
        'about': about
      };
      if (email != null && email.trim().isNotEmpty) payload['email'] = email;
      if (phone != null && phone.trim().isNotEmpty) payload['phone'] = phone;
      print('[ApiService.addDoctor] Sending Data: ${json.encode(payload)}');
      print('[ApiService.addDoctor] Sending to URL: $url');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload));
      print('[ApiService.addDoctor] API Status Code: ${response.statusCode}');
      print('[ApiService.addDoctor] API Response Body: ${response.body}');
      dynamic responseData;
      String message = 'Unknown response';
      try {
        responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          message = responseData['message']?.toString() ??
              responseData['title']?.toString() ??
              message;
        } else {
          message = responseData.toString();
        }
      } catch (e) {
        print('[ApiService.addDoctor] JSON Decode Error: $e');
        print(
            '[ApiService.addDoctor] RAW RESPONSE BODY (on JSON decode error): ${response.body}');
        message =
            'API returned non-JSON response (Status ${response.statusCode})';
        responseData = {'rawErrorBody': response.body};
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('doctor') &&
            responseData['doctor'] is Map &&
            responseData['doctor'].containsKey('doctor_ID')) {
          return {
            'success': true,
            'doctorId': responseData['doctor']['doctor_ID'],
            'data': responseData,
            'message': responseData['message']?.toString() ??
                'Doctor added successfully'
          };
        } else {
          print(
              '[ApiService.addDoctor] Success status code, but failed to parse Doctor ID from response.');
          return {
            'success': false,
            'message':
                'Doctor added (status ${response.statusCode}), but failed to parse Doctor ID from response.',
            'data': responseData,
            'statusCode': response.statusCode
          };
        }
      } else {
        if (response.statusCode == 400 &&
            responseData is Map<String, dynamic> &&
            responseData['title']
                    ?.toString()
                    .toLowerCase()
                    .contains('validation errors') ==
                true) {
          message = 'خطأ في بيانات الطبيب المدخلة.';
          if (responseData['errors'] != null)
            print(
                '[ApiService.addDoctor] Validation Errors: ${json.encode(responseData['errors'])}');
        }
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': message,
          'data': responseData
        };
      }
    } catch (e) {
      print('[ApiService.addDoctor] Network or other error: $e');
      return {
        'success': false,
        'message': 'Network error or request setup failed: $e',
        'error': e.toString(),
        'data': null,
        'statusCode': null
      };
    }
  }

  // --- sendOtp --- (كما هو)
  static Future<Map<String, dynamic>> sendOtp(
      String identifier, String type) async {
    if (type.toLowerCase() != 'email') {
      print(
          '[ApiService.sendOtp] Error: This function currently only supports type "email". Received: $type');
      return {
        'success': false,
        'message': 'نوع التأكيد غير مدعوم حاليًا (يجب أن يكون بريد إلكتروني).',
        'statusCode': 400,
        'data': null,
        'token': null,
      };
    }

    final url = Uri.parse('$baseUrl/auth/Send-OTP'); // Correct URL casing
    try {
      final Map<String, dynamic> payload = {'Email': identifier};

      print('[ApiService.sendOtp] Sending OTP request for email: $identifier');
      print('[ApiService.sendOtp] Payload being sent: ${json.encode(payload)}');
      print('[ApiService.sendOtp] Sending to URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain',
        },
        body: json.encode(payload),
      );

      print('[ApiService.sendOtp] API Status Code: ${response.statusCode}');
      print('[ApiService.sendOtp] API Raw Response Body: ${response.body}');

      dynamic responseData;
      String message = 'Unknown response';
      String? tempToken;

      try {
        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          responseData = json.decode(response.body);
          print('[ApiService.sendOtp] API Response Decoded as JSON.');

          if (responseData is Map<String, dynamic>) {
            message = responseData['message']?.toString() ??
                responseData['title']?.toString() ??
                'تم فك تشفير الرد بنجاح ولكن لا توجد رسالة.';
            if (responseData.containsKey('token')) {
              tempToken = responseData['token'];
              print('[ApiService.sendOtp] Extracted temporary token.');
            } else {
              print(
                  '[ApiService.sendOtp] Warning: Successful JSON response but no "token" key found.');
            }
          } else {
            message = responseData.toString();
          }
        } else {
          message = response.body.trim();
          responseData = {'rawBody': message};
          print('[ApiService.sendOtp] API Response is likely plain text.');
          if (message.toLowerCase() == 'user not found.') {
            message = 'المستخدم (البريد الإلكتروني) غير موجود.';
          }
        }
      } catch (e) {
        print('[ApiService.sendOtp] Error processing response body: $e');
        message = response.body.trim();
        responseData = {'rawErrorBody': message};
      }

      bool success = response.statusCode == 200 &&
          tempToken != null &&
          tempToken.isNotEmpty;

      if (!success && message.isEmpty) {
        message = 'حدث خطأ غير معروف (Status: ${response.statusCode})';
      } else if (!success &&
          (message == 'Unknown response' || message.trim().isEmpty) &&
          response.statusCode == 500) {
        message =
            'حدث خطأ داخلي في الخادم (500). يرجى المحاولة لاحقاً أو الاتصال بالدعم.';
      } else if (!success &&
          response.statusCode == 400 &&
          message.toLowerCase().contains('user not found')) {
        message = 'المستخدم (البريد الإلكتروني) غير موجود.';
      }

      return {
        'success': success,
        'data': responseData,
        'statusCode': response.statusCode,
        'message': message,
        'token': success ? tempToken : null,
      };
    } catch (e) {
      print('[ApiService.sendOtp] Network or setup error: $e');
      return {
        'success': false,
        'message': 'خطأ في الشبكة أو في إعداد الطلب: $e',
        'error': e.toString(),
        'data': null,
        'statusCode': null,
        'token': null,
      };
    }
  }

  // --- verifyOtp --- (كما هو)
  static Future<Map<String, dynamic>> verifyOtp(String identifier, String code,
      [String? reference]) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');
    try {
      final Map<String, dynamic> payload = {
        'identifier': identifier,
        'code': code
      };
      if (reference != null && reference.isNotEmpty) {
        payload['reference'] = reference;
      }
      print('[ApiService.verifyOtp] Sending data: ${json.encode(payload)}');
      print('[ApiService.verifyOtp] Sending to URL: $url');
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: json.encode(payload));
      print('[ApiService.verifyOtp] API Status Code: ${response.statusCode}');
      print('[ApiService.verifyOtp] API Response Body: ${response.body}');

      dynamic responseData;
      String message = 'Unknown response';
      try {
        responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          message = responseData['title']?.toString() ??
              responseData['message']?.toString() ??
              (responseData['errors'] != null
                  ? json.encode(responseData['errors'])
                  : null) ??
              message;
          if (message
              .toLowerCase()
              .contains("one or more validation errors occurred")) {
            message = 'رمز التحقق غير صحيح أو انتهت صلاحيته.';
          }
        } else {
          message = responseData.toString();
        }
      } catch (e) {
        print('[ApiService.verifyOtp] JSON Decode Error: $e');
        print(
            '[ApiService.verifyOtp] RAW RESPONSE BODY (on JSON decode error): ${response.body}');
        message =
            'API returned non-JSON response (Status ${response.statusCode})';
        responseData = {'rawErrorBody': response.body};
      }

      bool success = response.statusCode == 200 || response.statusCode == 201;
      String? loginToken = null;
      if (success &&
          responseData is Map<String, dynamic> &&
          responseData.containsKey('token')) {
        loginToken = responseData['token'];
        print('[ApiService.verifyOtp] Received login/session token.');
      }
      return {
        'success': success,
        'data': responseData,
        'token': loginToken,
        'statusCode': response.statusCode,
        'message': success
            ? (responseData is Map && responseData.containsKey('message')
                ? responseData['message']?.toString() ??
                    'OTP verified successfully'
                : 'OTP verified successfully')
            : message,
      };
    } catch (e) {
      print('[ApiService.verifyOtp] Network or other error: $e');
      return {
        'success': false,
        'message': 'Network error or request setup failed: $e',
        'error': e.toString(),
        'data': null,
        'statusCode': null,
        'token': null,
      };
    }
  }

  // --- verifyEmailOtp --- (كما هو)
  static Future<Map<String, dynamic>> verifyEmailOtp(
      String? tempToken, String otpCode) async {
    if (tempToken == null || tempToken.isEmpty) {
      return {
        'success': false,
        'message': 'خطأ: رمز التحقق المؤقت مفقود.',
        'statusCode': 400
      };
    }
    if (otpCode.isEmpty || otpCode.length != 6) {
      return {
        'success': false,
        'message': 'خطأ: يجب إدخال رمز OTP المكون من 6 أرقام.',
        'statusCode': 400
      };
    }

    final url = Uri.parse('$baseUrl/auth/verify-email-otp');
    try {
      final Map<String, dynamic> payload = {
        'Token': tempToken,
        'OtpCode': otpCode,
      };

      print('[ApiService.verifyEmailOtp] Verifying Email OTP');
      print('[ApiService.verifyEmailOtp] Sending OtpCode: $otpCode');
      print(
          '[ApiService.verifyEmailOtp] Payload being sent: ${json.encode(payload)}');
      print('[ApiService.verifyEmailOtp] Sending to URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain',
        },
        body: json.encode(payload),
      );

      print(
          '[ApiService.verifyEmailOtp] API Status Code: ${response.statusCode}');
      print(
          '[ApiService.verifyEmailOtp] API Raw Response Body: ${response.body}');

      dynamic responseData;
      String message = 'Unknown response';
      bool isJson = false;

      try {
        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          responseData = json.decode(response.body);
          isJson = true;
          print('[ApiService.verifyEmailOtp] API Response Decoded as JSON.');
          if (responseData is Map<String, dynamic>) {
            message = responseData['message']?.toString() ??
                responseData['title']?.toString() ??
                (responseData['errors'] != null
                    ? json.encode(responseData['errors'])
                    : null) ??
                'Unknown error structure';
            if (message
                    .toLowerCase()
                    .contains("one or more validation errors occurred") ||
                (responseData['errors']?.containsKey('OtpCode') ?? false)) {
              message = 'رمز التحقق غير صحيح أو انتهت صلاحيته.';
            } else if (responseData['errors']?.containsKey('Token') ?? false) {
              message = 'رمز الجلسة غير صالح أو انتهت صلاحيته.';
            }
          } else {
            message = responseData.toString();
          }
        } else {
          message = response.body.trim();
          responseData = {'rawBody': message};
          print(
              '[ApiService.verifyEmailOtp] API Response is likely plain text.');
          if (message.toLowerCase().contains('invalid token')) {
            message = 'رمز الجلسة غير صالح أو انتهت صلاحيته.';
          } else if (message.toLowerCase().contains('invalid or expired otp')) {
            message = 'رمز التحقق غير صحيح أو انتهت صلاحيته.';
          }
        }
      } catch (e) {
        print('[ApiService.verifyEmailOtp] Error processing response body: $e');
        message = response.body.trim();
        responseData = {'rawErrorBody': message};
      }

      bool success = response.statusCode == 200;

      if (!success && message.isEmpty) {
        message =
            'حدث خطأ غير معروف أثناء التحقق (Status: ${response.statusCode})';
      } else if (!success &&
          (message == 'Unknown response' || message.trim().isEmpty) &&
          response.statusCode == 400) {
        message = 'طلب غير صالح. تأكد من إرسال البيانات الصحيحة.';
      } else if (!success &&
          (message == 'Unknown response' || message.trim().isEmpty) &&
          response.statusCode == 404) {
        message = 'نقطة النهاية غير موجودة (404).';
      }

      String? finalLoginToken = null;
      if (success &&
          isJson &&
          responseData is Map<String, dynamic> &&
          responseData.containsKey('token')) {
        finalLoginToken = responseData['token'];
        print(
            '[ApiService.verifyEmailOtp] Received an unexpected final token.');
      }

      return {
        'success': success,
        'data': responseData,
        'token': finalLoginToken,
        'statusCode': response.statusCode,
        'message': success
            ? (isJson &&
                    responseData is Map &&
                    responseData.containsKey('message')
                ? responseData['message']?.toString() ??
                    'تم التحقق من الرمز بنجاح.'
                : 'تم التحقق من الرمز بنجاح.')
            : message,
      };
    } catch (e) {
      print('[ApiService.verifyEmailOtp] Network or setup error: $e');
      return {
        'success': false,
        'message': 'Network error or request setup failed: $e',
        'error': e.toString(),
        'data': null,
        'statusCode': null,
        'token': null,
      };
    }
  }

  // --- resetPassword --- (كما هو)
  static Future<Map<String, dynamic>> resetPassword(
      String token, String newPassword) async {
    if (token.isEmpty) {
      return {
        'success': false,
        'message': 'خطأ: رمز الجلسة مفقود.',
        'statusCode': 400
      };
    }
    if (newPassword.isEmpty) {
      return {
        'success': false,
        'message': 'خطأ: كلمة المرور الجديدة مطلوبة.',
        'statusCode': 400
      };
    }

    final url = Uri.parse('$baseUrl/auth/reset-password');
    try {
      final Map<String, dynamic> payload = {
        'Token': token,
        'NewPassword': newPassword,
      };

      print('[ApiService.resetPassword] Sending password reset request.');
      print('[ApiService.resetPassword] Sending to URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain',
        },
        body: json.encode(payload),
      );

      print(
          '[ApiService.resetPassword] API Status Code: ${response.statusCode}');
      print(
          '[ApiService.resetPassword] API Raw Response Body: ${response.body}');

      dynamic responseData;
      String message = 'Unknown response';
      bool isJson = false;

      try {
        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          responseData = json.decode(response.body);
          isJson = true;
          print('[ApiService.resetPassword] API Response Decoded as JSON.');
          if (responseData is Map<String, dynamic>) {
            message = responseData['message']?.toString() ??
                responseData['title']?.toString() ??
                (responseData['errors'] != null
                    ? json.encode(responseData['errors'])
                    : null) ??
                'Unknown error structure';
            if (message
                .toLowerCase()
                .contains("one or more validation errors occurred")) {
              if (responseData['errors']?['NewPassword'] != null) {
                message = 'كلمة المرور الجديدة غير صالحة أو لا تطابق الشروط.';
              } else if (responseData['errors']?['Token'] != null) {
                message = 'رمز الجلسة غير صالح أو انتهت صلاحيته.';
              } else {
                message = 'خطأ في البيانات المرسلة.';
              }
            }
          } else {
            message = responseData.toString();
          }
        } else {
          message = response.body.trim();
          responseData = {'rawBody': message};
          print(
              '[ApiService.resetPassword] API Response is likely plain text.');
          if (message.toLowerCase() ==
              'password has been reset successfully.') {
          } else if (message.toLowerCase() == 'invalid token.') {
            message = 'رمز الجلسة المستخدم غير صالح أو انتهت صلاحيته.';
          } else if (message.toLowerCase() == 'user not found.') {
            message = 'المستخدم المرتبط بهذا الرمز غير موجود.';
          }
        }
      } catch (e) {
        print('[ApiService.resetPassword] Error processing response body: $e');
        message = response.body.trim();
        responseData = {'rawErrorBody': message};
      }

      bool success = response.statusCode == 200;

      if (success &&
          message.toLowerCase() == 'password has been reset successfully.') {
        message = "تم إعادة تعيين كلمة المرور بنجاح.";
      } else if (!success && message.isEmpty) {
        message =
            'فشل إعادة تعيين كلمة المرور (Status: ${response.statusCode})';
      } else if (!success &&
          (message == 'Unknown response' || message.trim().isEmpty) &&
          response.statusCode == 400) {
        message = 'طلب غير صالح. تأكد من صحة الرمز وكلمة المرور.';
      }

      return {
        'success': success,
        'data': responseData,
        'statusCode': response.statusCode,
        'message': message,
      };
    } catch (e) {
      print('[ApiService.resetPassword] Network or setup error: $e');
      return {
        'success': false,
        'message': 'Network error or request setup failed: $e',
        'error': e.toString(),
        'data': null,
        'statusCode': null,
      };
    }
  }

  // --- getUserProfile --- (كما هو)
  static Future<Map<String, dynamic>> getUserProfile(String? token) async {
    final url = Uri.parse('$baseUrl/user/get-profile');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      print("[ApiService.getUserProfile] Error: Token is required.");
      return {
        'success': false,
        'message': 'Token is required',
        'statusCode': 401
      };
    }

    try {
      print("[ApiService.getUserProfile] Sending GET request to $url");
      final response = await http.get(url, headers: headers);
      print(
          '[ApiService.getUserProfile] API Status Code: ${response.statusCode}');
      print('[ApiService.getUserProfile] API Response Body: ${response.body}');

      dynamic responseData;
      String message = 'Failed to parse response';
      bool isJson =
          response.headers['content-type']?.contains('application/json') ??
              false;

      try {
        if (isJson && response.body.isNotEmpty) {
          responseData = json.decode(response.body);
          message = "Profile loaded";
          if (responseData is Map<String, dynamic>) {
            // message = responseData['message'] ?? message;
          }
        } else if (response.body.isNotEmpty) {
          responseData = {'rawBody': response.body};
          message = response.body;
        } else {
          responseData = {};
          message = "Empty response body";
        }
      } catch (e) {
        print('[ApiService.getUserProfile] JSON Decode Error: $e');
        message = 'Error parsing server response.';
        responseData = {'rawErrorBody': response.body};
      }

      bool success = response.statusCode == 200;
      if (!success && isJson && responseData is Map<String, dynamic>) {
        message = responseData['message'] ??
            responseData['title'] ??
            'Failed to load profile';
      } else if (!success && !isJson) {
        message = response.body.isNotEmpty
            ? response.body
            : 'Failed to load profile (Status: ${response.statusCode})';
      }

      return {
        'success': success,
        'data': success ? responseData : null,
        'statusCode': response.statusCode,
        'message': message,
      };
    } catch (e) {
      print('[ApiService.getUserProfile] Network or other error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': e.toString(),
        'data': null,
        'statusCode': null,
      };
    }
  }

  // --- updateUserProfile --- (كما هو)
  static Future<Map<String, dynamic>> updateUserProfile(
      String? token, Map<String, dynamic> profileData) async {
    final url = Uri.parse('$baseUrl/user/update-profile');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      print("[ApiService.updateUserProfile] Error: Token is required.");
      return {
        'success': false,
        'message': 'Token is required',
        'statusCode': 401
      };
    }

    try {
      print("[ApiService.updateUserProfile] Sending PUT request to $url");
      print("[ApiService.updateUserProfile] Data: ${json.encode(profileData)}");
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(profileData),
      );
      print(
          '[ApiService.updateUserProfile] API Status Code: ${response.statusCode}');
      print(
          '[ApiService.updateUserProfile] API Response Body: ${response.body}');

      dynamic responseData;
      String message = 'Failed to parse response';
      bool isJson =
          response.headers['content-type']?.contains('application/json') ??
              false;

      try {
        if (response.body.isNotEmpty) {
          if (isJson) {
            responseData = json.decode(response.body);
            if (responseData is Map<String, dynamic>) {
              message = responseData['message'] ??
                  responseData['title'] ??
                  'Profile updated';
            } else {
              message = responseData.toString();
            }
          } else {
            message = response.body;
            responseData = {'rawBody': message};
          }
        } else {
          responseData = {};
          message = "Profile updated successfully";
        }
      } catch (e) {
        print('[ApiService.updateUserProfile] JSON Decode Error: $e');
        message = 'Error parsing server response.';
        responseData = {'rawErrorBody': response.body};
      }

      bool success = response.statusCode == 200 || response.statusCode == 204;
      if (!success && isJson && responseData is Map<String, dynamic>) {
        message = responseData['message'] ??
            responseData['title'] ??
            'Failed to update profile';
        if (responseData['errors'] != null)
          message += " Details: ${json.encode(responseData['errors'])}";
      } else if (!success && !isJson) {
        message = response.body.isNotEmpty
            ? response.body
            : 'Failed to update profile (Status: ${response.statusCode})';
      }

      return {
        'success': success,
        'data': responseData,
        'statusCode': response.statusCode,
        'message': message,
      };
    } catch (e) {
      print('[ApiService.updateUserProfile] Network or other error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': e.toString(),
        'data': null,
        'statusCode': null,
      };
    }
  }

  // --- uploadProfilePicture --- (كما هو)
  static Future<Map<String, dynamic>> uploadProfilePicture(
      String? token, File imageFile) async {
    final url = Uri.parse('$baseUrl/user/update-profile-picture');
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      print("[ApiService.uploadProfilePicture] Error: Token is required.");
      return {
        'success': false,
        'message': 'Token is required',
        'statusCode': 401
      };
    }

    try {
      print(
          "[ApiService.uploadProfilePicture] Sending POST (multipart) request to $url");
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath(
          'ImageFile', // تأكد من اسم الحقل
          imageFile.path,
          contentType: MediaType('image', imageFile.path.split('.').last)));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(
          '[ApiService.uploadProfilePicture] API Status Code: ${response.statusCode}');
      print(
          '[ApiService.uploadProfilePicture] API Response Body: ${response.body}');

      dynamic responseData;
      String message = 'Failed to parse response';
      String? newImageUrl;
      bool isJson =
          response.headers['content-type']?.contains('application/json') ??
              false;

      try {
        if (isJson && response.body.isNotEmpty) {
          responseData = json.decode(response.body);
          message = "Picture uploaded";
          if (responseData is Map<String, dynamic>) {
            message = responseData['message'] ?? message;
            newImageUrl = responseData['imageUrl']; // تأكد من اسم الحقل
          }
        } else if (response.body.isNotEmpty) {
          responseData = {'rawBody': response.body};
          message = response.body;
        } else {
          responseData = {};
          message = 'Empty response body';
        }
      } catch (e) {
        print('[ApiService.uploadProfilePicture] JSON Decode Error: $e');
        message = 'Error parsing server response.';
        responseData = {'rawErrorBody': response.body};
      }

      bool success = response.statusCode == 200 && newImageUrl != null;
      if (!success && isJson && responseData is Map<String, dynamic>) {
        message = responseData['message'] ??
            responseData['title'] ??
            'Failed to upload picture';
      } else if (!success && !isJson) {
        message = response.body.isNotEmpty
            ? response.body
            : 'Failed to upload picture (Status: ${response.statusCode})';
      }

      return {
        'success': success,
        'data': responseData,
        'newImageUrl': newImageUrl,
        'statusCode': response.statusCode,
        'message': message,
      };
    } catch (e) {
      print('[ApiService.uploadProfilePicture] Network or other error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': e.toString(),
        'data': null,
        'statusCode': null,
      };
    }
  }

  // --- classifyAnswerWithModel --- (كما هو)
  static Future<String?> classifyAnswerWithModel(String rawText) async {
    const String modelPredictEndpoint =
        "https://arabic-response-api-869138074073.us-central1.run.app/predict";
    final url = Uri.parse(modelPredictEndpoint);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    final body = jsonEncode({'text': rawText});
    try {
      print(
          '[ApiService.classifyAnswer] Calling Model API: $modelPredictEndpoint');
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 20));
      print(
          '[ApiService.classifyAnswer] Model API Status: ${response.statusCode}');
      print(
          '[ApiService.classifyAnswer] Model API Response Headers: ${response.headers}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String decodedBody;
        try {
          decodedBody = utf8.decode(response.bodyBytes);
          print(
              '[ApiService.classifyAnswer] Body decoded with UTF-8: $decodedBody');
        } catch (e) {
          print(
              '[ApiService.classifyAnswer] Error decoding body with UTF-8, falling back to response.body: $e');
          decodedBody = response.body;
        }
        try {
          final dynamic responseData = jsonDecode(decodedBody);
          if (responseData is Map<String, dynamic>) {
            print(
                '[ApiService.classifyAnswer] Model Response Body (Map): $responseData');
            final dynamic resultValue =
                responseData['prediction']; // <--- تأكد من المفتاح
            if (resultValue != null) {
              final String classificationResult =
                  resultValue.toString().trim().replaceAll('"', '');
              const validResults = ["نعم", "لا", "بمساعدة"];
              if (validResults.contains(classificationResult)) {
                print(
                    '[ApiService.classifyAnswer] Model Classified As: $classificationResult');
                return classificationResult;
              } else {
                print(
                    '[ApiService.classifyAnswer] Error: Unexpected classification value after UTF-8 decode: "$classificationResult"');
                return null;
              }
            } else {
              print(
                  "[ApiService.classifyAnswer] Error: Key 'prediction' not found in response Map after UTF-8 decode.");
              return null;
            }
          } else {
            print(
                '[ApiService.classifyAnswer] Error: Expected a Map response after UTF-8 decode, but got ${responseData.runtimeType}');
            return null;
          }
        } catch (e) {
          print(
              '[ApiService.classifyAnswer] JSON Decode Error after manual UTF-8 decode: $e');
          print('[ApiService.classifyAnswer] Decoded Body was: $decodedBody');
          return null;
        }
      } else {
        print(
            '[ApiService.classifyAnswer] Error: Failed with status ${response.statusCode}. Body: ${response.body}');
        return null;
      }
    } on TimeoutException catch (e) {
      print('[ApiService.classifyAnswer] Error: Request timed out - $e');
      return null;
    } on SocketException catch (e) {
      print('[ApiService.classifyAnswer] Error: Network error - $e');
      return null;
    } on http.ClientException catch (e) {
      print('[ApiService.classifyAnswer] Error: Client error - $e');
      return null;
    } catch (e) {
      print(
          '[ApiService.classifyAnswer] Error: An unexpected error occurred - $e');
      return null;
    }
  }

  // --- submitAssessmentAnswer --- (كما هو)
  static Future<bool> submitAssessmentAnswer(
      int questionId, String classifiedAnswer, String jwtToken) async {
    final url = Uri.parse('$baseUrl/sessioncontroller/submit-answers');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken'
    };
    // تأكد من أن البنية تتطابق تمامًا مع ما يتوقعه الـ API
    final body = jsonEncode({
      "Answers": [
        {"SessionId": questionId, "Answer": classifiedAnswer}
      ]
    });
    try {
      print(
          '[ApiService.submitAnswer] Calling Backend API: ${url.toString()} for Q:$questionId Ans:"$classifiedAnswer"');
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      print(
          '[ApiService.submitAnswer] Backend API Status: ${response.statusCode}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[ApiService.submitAnswer] Success: Answer submitted.');
        return true;
      } else {
        print(
            '[ApiService.submitAnswer] Error: Failed with status ${response.statusCode}. Body: ${response.body}');
        return false;
      }
    } on TimeoutException catch (e) {
      print('[ApiService.submitAnswer] Error: Request timed out - $e');
      return false;
    } on SocketException catch (e) {
      print('[ApiService.submitAnswer] Error: Network error - $e');
      return false;
    } on http.ClientException catch (e) {
      print('[ApiService.submitAnswer] Error: Client error - $e');
      return false;
    } catch (e) {
      print(
          '[ApiService.submitAnswer] Error: An unexpected error occurred - $e');
      return false;
    }
  }
// ******************************************************
  // ********           الدوال الجديدة المضافة           ********
  // ******************************************************

  // --- دالة جلب الجلسة التالية المعلقة (ترجع Session?) ---
  static Future<Session?> getNextPendingSession(String token) async {
    final url = Uri.parse('$baseUrl/SessionController/next-pending');
    print('[ApiService.getNextPendingSession] Calling: GET $url');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      ).timeout(const Duration(seconds: 20));

      print(
          '[ApiService.getNextPendingSession] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final decodedBody = utf8.decode(response.bodyBytes);
          final data = jsonDecode(decodedBody);
          if (data != null && data is Map<String, dynamic>) {
            print(
                '[ApiService.getNextPendingSession] Successfully fetched session data.');
            return Session.fromJson(data); // <-- التحويل لـ Session
          } else {
            /* ... خطأ بيانات غير متوقعة ... */ return null;
          }
        } catch (e) {
          /* ... خطأ تحليل JSON ... */ return null;
        }
      } else if (response.statusCode == 404) {
        /* ... لا توجد جلسات ... */ return null;
      } else if (response.statusCode == 401) {
        /* ... خطأ توثيق ... */ throw Exception('Unauthorized');
      } else {
        /* ... أخطاء أخرى ... */ return null;
      }
    } on TimeoutException catch (e) {
      print('[ApiService.getNextPendingSession] Timeout: $e');
      throw Exception('Request timed out');
    } on SocketException catch (e) {
      print('[ApiService.getNextPendingSession] Network Error: $e');
      throw Exception('Network error');
    } on http.ClientException catch (e) {
      print('[ApiService.getNextPendingSession] Client Error: $e');
      throw Exception('Client error');
    } catch (e) {
      print('[ApiService.getNextPendingSession] Unexpected Error: $e');
      throw Exception('Unexpected error');
    }
  }

  // --- دالة إكمال خطوة تفاصيل الجلسة (ترجع bool) ---
  static Future<bool> completeDetail(String token, int detailId) async {
    final url =
        Uri.parse('$baseUrl/SessionController/detail/$detailId/complete');
    print('[ApiService.completeDetail] Calling: POST $url');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': '*/*'
            },
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 15));
      print(
          '[ApiService.completeDetail] Status Code for ID $detailId: ${response.statusCode}');
      return response.statusCode == 200; // النجاح هو 200
    } on TimeoutException catch (e) {
      print('[ApiService.completeDetail] Timeout for ID $detailId: $e');
      return false;
    } on SocketException catch (e) {
      print('[ApiService.completeDetail] Network Error for ID $detailId: $e');
      return false;
    } on http.ClientException catch (e) {
      print('[ApiService.completeDetail] Client Error for ID $detailId: $e');
      return false;
    } catch (e) {
      print(
          '[ApiService.completeDetail] Unexpected Error for ID $detailId: $e');
      return false;
    }
  }
  // ========================================================================
  // دوال الاختبار (الكويز) الجديدة / المحدثة
  // ========================================================================

  /// Fetches the next quiz data session from the TestController.
  static Future<QuizSession?> fetchNextTestDetail(String token) async {
    // *** تأكد 100% من صحة هذا المسار مع الـ Backend ***
    final url = Uri.parse('$baseUrl/TestController/next-test-detail-Session');
    debugPrint('[ApiService.fetchNextTestDetail] Calling: GET $url');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      ).timeout(
          const Duration(seconds: 20)); // زيادة المهلة قليلاً إذا لزم الأمر

      debugPrint(
          '[ApiService.fetchNextTestDetail] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          // استخدام utf8 لضمان قراءة الأحرف العربية بشكل صحيح
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          if (data is Map<String, dynamic>) {
            debugPrint(
                '[ApiService.fetchNextTestDetail] Success. Parsing JSON...');
            return QuizSession.fromJson(data); // <-- استخدام نموذج الكويز
          } else {
            debugPrint(
                '[ApiService.fetchNextTestDetail] Error: Unexpected JSON structure.');
            return null;
          }
        } catch (e) {
          debugPrint('[ApiService.fetchNextTestDetail] JSON Parsing Error: $e');
          debugPrint(
              '[ApiService.fetchNextTestDetail] Raw Body: ${response.body}');
          return null;
        }
      } else if (response.statusCode == 404) {
        debugPrint(
            '[ApiService.fetchNextTestDetail] No pending test found (404).');
        return null; // لا يوجد اختبار تالي
      } else {
        debugPrint(
            '[ApiService.fetchNextTestDetail] Server Error ${response.statusCode}. Body: ${response.body}');
        // رمي Exception يمكن التقاطه في QuizManagerScreen لعرض رسالة خطأ أفضل
        throw Exception(
            'Failed to load quiz details (Status: ${response.statusCode})');
      }
    } on TimeoutException catch (e) {
      debugPrint('[ApiService.fetchNextTestDetail] Timeout Error: $e');
      throw Exception('Request timed out while fetching quiz details.');
    } on SocketException catch (e) {
      debugPrint('[ApiService.fetchNextTestDetail] Network Error: $e');
      throw Exception('Network error while fetching quiz details.');
    } catch (e) {
      debugPrint('[ApiService.fetchNextTestDetail] Unexpected Error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Marks a specific quiz detail step as complete using its detailId (the small ID).
  static Future<bool> markTestDetailComplete(
      String token, int testDetailId) async {
    // التحقق من أن الـ ID صالح قبل الإرسال
    if (testDetailId <= 0) {
      debugPrint(
          "[ApiService.markTestDetailComplete] Error: Invalid testDetailId ($testDetailId). Aborting.");
      return false;
    }
    // *** تأكد 100% من صحة هذا المسار مع الـ Backend ***
    final url =
        Uri.parse('$baseUrl/TestController/test-detail/$testDetailId/complete');
    debugPrint('[ApiService.markTestDetailComplete] Calling: POST $url');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json', // حتى لو كان الجسم فارغًا
              'Accept': '*/*' // قبول أي نوع رد
            },
            body: jsonEncode({}), // إرسال جسم فارغ
          )
          .timeout(const Duration(seconds: 15));

      debugPrint(
          '[ApiService.markTestDetailComplete] Status for ID $testDetailId: ${response.statusCode}');
      // التحقق من 200 OK أو 204 No Content للنجاح
      bool success = response.statusCode == 200 || response.statusCode == 204;
      if (!success) {
        // طباعة الجسم فقط في حالة الفشل للمساعدة في التصحيح
        debugPrint(
            '[ApiService.markTestDetailComplete] Failed. Status: ${response.statusCode}, Body: ${response.body}');
      }
      return success;
    } on TimeoutException catch (e) {
      debugPrint(
          '[ApiService.markTestDetailComplete] Timeout Error for ID $testDetailId: $e');
      return false;
    } on SocketException catch (e) {
      debugPrint(
          '[ApiService.markTestDetailComplete] Network Error for ID $testDetailId: $e');
      return false;
    } catch (e) {
      debugPrint(
          '[ApiService.markTestDetailComplete] Unexpected Error for ID $testDetailId: $e');
      return false;
    }
  }

  //SARA CODE//////////
  static Future<bool> updateSessionDone(int sessionId, String jwtToken) async {
    /* ... الكود كما هو ... */ return false;
  }

  static Future<Map<String, dynamic>> getTestsByType(
      String token, int typeId) async {
    final url = Uri.parse('$baseUrl/Test/GetTestByType/$typeId');
    log("ApiService: Fetching tests for typeId: $typeId");
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      log("ApiService: GetTestsByType/$typeId Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        try {
          final List<TestDto> tests = testDtoListFromJson(response.body);
          log("ApiService: Successfully fetched ${tests.length} tests for typeId: $typeId");
          return {'success': true, 'tests': tests};
        } catch (e) {
          log("ApiService: Error parsing GetTestsByType/$typeId response as List<TestDto>: $e");
          try {
            final decodedBody = utf8.decode(response.bodyBytes);
            final responseData = jsonDecode(decodedBody);
            if (responseData is Map<String, dynamic> &&
                responseData.containsKey('\$values') &&
                responseData['\$values'] is List) {
              final List<dynamic> rawList = responseData['\$values'];
              final List<TestDto> tests =
                  rawList.map((item) => TestDto.fromJson(item)).toList();
              log("ApiService: Successfully parsed ${tests.length} tests from '\$values' for typeId: $typeId");
              return {'success': true, 'tests': tests};
            } else {
              log("ApiService: Response format is neither List<TestDto> nor contains '\$values'. Body: $decodedBody");
              return {
                'success': false,
                'message': 'خطأ في تنسيق بيانات الاختبارات المستلمة.'
              };
            }
          } catch (e2) {
            log("ApiService: Further error parsing GetTestsByType/$typeId response: $e2");
            return {
              'success': false,
              'message': 'خطأ في تحليل بيانات الاختبارات المستلمة.'
            };
          }
        }
      } else if (response.statusCode == 401) {
        log("ApiService: GetTestsByType/$typeId Unauthorized (401).");
        return {
          'success': false,
          'unauthorized': true,
          'message': 'غير مصرح لك بالوصول.'
        };
      } else if (response.statusCode == 404) {
        log("ApiService: GetTestsByType/$typeId Not Found (404). Assuming no tests available for this type.");
        return {'success': true, 'tests': <TestDto>[]};
      } else {
        log("ApiService: GetTestsByType/$typeId failed with status: ${response.statusCode}");
        String errorMessage =
            'فشل تحميل الاختبارات (رمز: ${response.statusCode})';
        try {
          final decodedBody = utf8.decode(response.bodyBytes);
          final errorData = jsonDecode(decodedBody);
          if (errorData is Map) {
            errorMessage = (errorData['message'] as String?) ??
                (errorData['title'] as String?) ??
                errorMessage;
          } // Cast Applied
          else if (errorData is String && errorData.isNotEmpty) {
            errorMessage = errorData;
          } // Assign if string
        } catch (_) {}
        return {'success': false, 'message': errorMessage};
      }
    } on TimeoutException catch (_) {
      log("ApiService: GetTestsByType/$typeId request timed out.");
      return {'success': false, 'message': 'انتهت مهلة طلب تحميل الاختبارات.'};
    } on SocketException catch (e) {
      log("ApiService: GetTestsByType/$typeId network error: $e");
      return {
        'success': false,
        'message': 'خطأ في الشبكة. تأكد من اتصالك بالإنترنت.'
      };
    } catch (e, s) {
      log("ApiService: Exception during GetTestsByType/$typeId: $e\n$s");
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع أثناء تحميل الاختبارات.'
      };
    }
  }

  // ! --- الدوال غير الـ static (المعدلة) ---

  Future<Either<Failure, MonthlyTestResponse>> getMonthlyTestDetails() async {
    String? token;
    try {
      token = await SharedPreferenceServices.getToken("auth_token") as String?;
      if (token == null || token.isEmpty) {
        return Left(ServerFailure("Token not found"));
      }
    } catch (e) {
      return Left(ServerFailure("Error fetching token: ${e.toString()}"));
    }
    const String endpoint = '/TestController/next-test-detail-month';
    log("ApiService (instance): GET $baseUrl$endpoint");
    try {
      final response = await _dio.get(endpoint,
          options: Options(headers: {"Authorization": "Bearer $token"}));
      log("ApiService getMonthlyTestDetails response status: ${response.statusCode}");
      if (response.statusCode == 200 && response.data != null) {
        try {
          final testData = MonthlyTestResponse.fromJson(response.data);
          log("ApiService: Successfully parsed monthly test details.");
          return Right(testData);
        } catch (e, s) {
          log("Error parsing monthly test JSON: $e\n$s\nReceived Data: ${response.data}");
          return Left(ServerFailure("خطأ في تنسيق بيانات الاختبار المستلمة."));
        }
      } else {
        String errorMessage = "فشل تحميل بيانات الاختبار";
        if (response.data is Map) {
          errorMessage = (response.data?['message'] as String?) ??
              'فشل تحميل بيانات الاختبار (رمز: ${response.statusCode})';
        } else if (response.data is String && response.data.isNotEmpty) {
          errorMessage = response.data;
        } else {
          errorMessage =
              'فشل تحميل بيانات الاختبار (رمز: ${response.statusCode})';
        }
        log("ApiService: Failed to fetch monthly test. Status: ${response.statusCode}, Message: $errorMessage");
        return Left(ServerFailure(errorMessage));
      }
    } on DioException catch (e) {
      log("ApiService DioException for monthly test: ${e.message}");
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e, s) {
      log("ApiService Unknown Exception for monthly test: $e\n$s");
      return Left(ServerFailure("حدث خطأ غير متوقع أثناء جلب الاختبار."));
    }
  }

  Future<Either<Failure, bool>> markSessionDone(int sessionId) async {
    String? token;
    try {
      token = await SharedPreferenceServices.getToken("auth_token") as String?;
      if (token == null || token.isEmpty) {
        return Left(ServerFailure("Token not found"));
      }
    } catch (e) {
      return Left(ServerFailure("Error fetching token: ${e.toString()}"));
    }
    final String endpoint = '/SessionController/update-session-done/$sessionId';
    log("ApiService (instance): PUT $baseUrl$endpoint");
    try {
      final response = await _dio.put(endpoint,
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));
      log("ApiService markSessionDone response status: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 204) {
        log("ApiService: Successfully marked session $sessionId as done.");
        return Right(true);
      } else {
        String errorMessage = "فشل تحديث حالة الجلسة";
        if (response.data is Map) {
          errorMessage = (response.data?['message'] as String?) ??
              'فشل تحديث حالة الجلسة (رمز: ${response.statusCode})';
        } else if (response.data is String && response.data.isNotEmpty) {
          errorMessage = response.data;
        } else {
          errorMessage = 'فشل تحديث حالة الجلسة (رمز: ${response.statusCode})';
        }
        log("ApiService: Failed to mark session $sessionId as done. Status: ${response.statusCode}, Message: $errorMessage");
        return Left(ServerFailure(errorMessage));
      }
    } on DioException catch (e) {
      log("ApiService DioException for markSessionDone $sessionId: ${e.message}");
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e, s) {
      log("ApiService Unknown Exception for markSessionDone $sessionId: $e\n$s");
      return Left(ServerFailure("حدث خطأ غير متوقع أثناء تحديث حالة الجلسة."));
    }
  }

  String _handleDioError(DioException e) {
    String errorMessage = "حدث خطأ في الشبكة أو الاتصال.";
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = "انتهت مهلة الاتصال بالخادم، يرجى المحاولة مرة أخرى.";
        break;
      case DioExceptionType.badResponse:
        var responseData = e.response?.data;
        if (responseData is Map) {
          errorMessage = (responseData['message'] as String?) ??
              (responseData['title'] as String?) ??
              'استجابة غير صالحة من الخادم (رمز: ${e.response?.statusCode})';
        } else if (responseData is String && responseData.isNotEmpty) {
          errorMessage = responseData;
        } else {
          errorMessage =
              'استجابة غير صالحة من الخادم (رمز: ${e.response?.statusCode})';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = "تم إلغاء طلب الاتصال.";
        break;
      case DioExceptionType.connectionError:
        errorMessage = "فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.";
        break;
      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          errorMessage = "خطأ في الشبكة، تحقق من اتصالك بالإنترنت.";
        } else {
          // --- Cast الإضافي هنا ---
          String? dioMsg = e.message as String?;
          String? errorStr = e.error?.toString();
          errorMessage =
              "حدث خطأ غير معروف في الشبكة: ${dioMsg ?? errorStr ?? ''}";
        }
        break;
    }
    return errorMessage;
  }
} // نهاية الكلاس ApiService

// نهاية الكلاس ApiService
