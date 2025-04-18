import 'dart:convert';
import 'dart:io'; // لـ File
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:async'; // لاستخدام TimeoutException



class ApiService {
  static const String baseUrl = 'http://aspiq.runasp.net/api';

  // --- loginUser --- (يبقى كما هو)
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      print('[ApiService.loginUser] Sending login request for email: $email');
      print('[ApiService.loginUser] Sending to URL: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
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
        // Keep returning login token
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

  // --- registerUser --- (يبقى كما هو)
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

  // --- addDoctor --- (يبقى كما هو)
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

  // ******** MODIFIED METHOD: Send OTP (Email Only based on API) ********
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
      // Correct payload as per API description: {"Email": "user@example.com"}
      final Map<String, dynamic> payload = {
        'Email': identifier
      }; // <<-- Use "Email" key

      print('[ApiService.sendOtp] Sending OTP request for email: $identifier');
      print('[ApiService.sendOtp] Payload being sent: ${json.encode(payload)}');
      print('[ApiService.sendOtp] Sending to URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain',
          // Accept both JSON and plain text
        },
        body: json.encode(payload),
      );

      print('[ApiService.sendOtp] API Status Code: ${response.statusCode}');
      print('[ApiService.sendOtp] API Raw Response Body: ${response.body}');

      dynamic responseData;
      String message = 'Unknown response';
      String? tempToken; // Variable to hold the temporary token

      try {
        // Check content type before decoding - API might return plain text for errors
        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          responseData = json.decode(response.body);
          print('[ApiService.sendOtp] API Response Decoded as JSON.');

          if (responseData is Map<String, dynamic>) {
            message = responseData['message']?.toString() ??
                responseData['title']?.toString() ??
                'تم فك تشفير الرد بنجاح ولكن لا توجد رسالة.';
            // Extract the token
            if (responseData.containsKey('token')) {
              tempToken = responseData['token'];
              print('[ApiService.sendOtp] Extracted temporary token.');
            } else {
              print(
                  '[ApiService.sendOtp] Warning: Successful JSON response but no "token" key found.');
            }
          } else {
            message = responseData.toString(); // Handle non-map JSON response
          }
        } else {
          // Handle plain text response
          message = response.body.trim();
          responseData = {'rawBody': message}; // Store raw body
          print('[ApiService.sendOtp] API Response is likely plain text.');
          if (message.toLowerCase() == 'user not found.') {
            message = 'المستخدم (البريد الإلكتروني) غير موجود.';
          }
        }
      } catch (e) {
        // This catch is mainly for JSON errors if the content-type was wrongly identified
        print('[ApiService.sendOtp] Error processing response body: $e');
        message = response.body.trim(); // Use raw body as message
        responseData = {'rawErrorBody': message};
      }

      // Success is 200 OK AND receiving a token based on API description
      bool success = response.statusCode == 200 &&
          tempToken != null &&
          tempToken.isNotEmpty;

      // Refine error messages
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
        // Use message from response or formatted error
        'token': success ? tempToken : null,
        // Return the extracted token or null
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

  // --- verifyOtp (Used for phone according to original code - Check Swagger if used) ---
  // Note: API Description provided by user is for verify-email-otp, not this.
  // Keep implementation based on original code unless Swagger for verify-otp (phone) says otherwise.
  static Future<Map<String, dynamic>> verifyOtp(String identifier, String code,
      [String? reference]) async {
    final url =
    Uri.parse('$baseUrl/auth/verify-otp'); // Assumed endpoint for phone
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
      String? loginToken = null; // May return a login/session token
      if (success &&
          responseData is Map<String, dynamic> &&
          responseData.containsKey('token')) {
        loginToken = responseData['token'];
        print('[ApiService.verifyOtp] Received login/session token.');
      }
      return {
        'success': success,
        'data': responseData,
        'token': loginToken, // Return the login/session token if received
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

  // ******** MODIFIED METHOD: Verify Email OTP ********
  // Uses the temporary token from Send-OTP and the OTP code.
  // Payload: { "Token": ..., "OtpCode": ... } based on user description.
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
      // Added length check
      return {
        'success': false,
        'message': 'خطأ: يجب إدخال رمز OTP المكون من 6 أرقام.',
        'statusCode': 400
      };
    }

    final url = Uri.parse('$baseUrl/auth/verify-email-otp');
    try {
      // Payload structure as described by user
      final Map<String, dynamic> payload = {
        'Token': tempToken,
        'OtpCode': otpCode,
      };

      print('[ApiService.verifyEmailOtp] Verifying Email OTP');
      // Avoid printing full token in production logs
      // print('[ApiService.verifyEmailOtp] Sending Token (partial): ${tempToken.substring(0, Math.min(10, tempToken.length))}...');
      print('[ApiService.verifyEmailOtp] Sending OtpCode: $otpCode');
      print(
          '[ApiService.verifyEmailOtp] Payload being sent: ${json.encode(payload)}');
      print('[ApiService.verifyEmailOtp] Sending to URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain',
          // Accept text for potential errors
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
          // Handle known plain text errors if any (e.g., "Invalid token")
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

      // Success is 200 OK for verification based on user description
      bool success = response.statusCode == 200;

      // Refine error messages
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

      // Email verification API description doesn't mention returning a final token,
      // but we check just in case. The token used for reset is the one from sendOtp.
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
        // Usually null here, as reset needs the original tempToken
        'statusCode': response.statusCode,
        'message': success
            ? (isJson &&
            responseData is Map &&
            responseData.containsKey('message')
            ? responseData['message']?.toString() ??
            'تم التحقق من الرمز بنجاح.'
            : 'تم التحقق من الرمز بنجاح.') // Default success message
            : message,
        // Error message
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

  // ******** NEW METHOD: Reset Password ********
  // Uses the token from Send-OTP/Verify-OTP and the new password.
  // Payload: { "Token": ..., "NewPassword": ... } based on user description.
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
    // Add password complexity check here if needed before sending to API

    final url = Uri.parse('$baseUrl/auth/reset-password');
    try {
      final Map<String, dynamic> payload = {
        'Token': token,
        'NewPassword': newPassword,
      };

      print('[ApiService.resetPassword] Sending password reset request.');
      // Avoid printing token/password in production logs
      print('[ApiService.resetPassword] Sending to URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain',
          // Accept text for success/error messages
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
        // Check content type - success might be plain text "Password has been reset successfully."
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
            // Handle specific validation errors if API provides them in JSON
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
          // Handle plain text response
          message = response.body.trim();
          responseData = {'rawBody': message};
          print(
              '[ApiService.resetPassword] API Response is likely plain text.');
          if (message.toLowerCase() ==
              'password has been reset successfully.') {
            // Keep message as is for success check
          } else if (message.toLowerCase() == 'invalid token.') {
            message = 'رمز الجلسة المستخدم غير صالح أو انتهت صلاحيته.';
          } else if (message.toLowerCase() == 'user not found.') {
            message =
            'المستخدم المرتبط بهذا الرمز غير موجود.'; // Should ideally not happen if token is valid
          }
        }
      } catch (e) {
        print('[ApiService.resetPassword] Error processing response body: $e');
        message = response.body.trim(); // Use raw body as fallback
        responseData = {'rawErrorBody': message};
      }

      // Success is 200 OK according to user description
      bool success = response.statusCode == 200;

      // Refine messages based on success status and known responses
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
        'message': message, // Return the processed message
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
  static Future<Map<String, dynamic>> getUserProfile(String? token) async {
    final url = Uri.parse('$baseUrl/user/get-profile'); // <-- تأكدي من المسار الصحيح
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token'; // <-- إضافة التوكن يدويًا
    } else {
      print("[ApiService.getUserProfile] Error: Token is required.");
      return {'success': false, 'message': 'Token is required', 'statusCode': 401};
    }

    try {
      print("[ApiService.getUserProfile] Sending GET request to $url");
      final response = await http.get(url, headers: headers);
      print('[ApiService.getUserProfile] API Status Code: ${response.statusCode}');
      print('[ApiService.getUserProfile] API Response Body: ${response.body}');

      dynamic responseData;
      String message = 'Failed to parse response';
      bool isJson = response.headers['content-type']?.contains('application/json') ?? false;

      try {
        if (isJson && response.body.isNotEmpty) {
          responseData = json.decode(response.body);
          message = "Profile loaded"; // رسالة افتراضية للنجاح
          if (responseData is Map<String, dynamic>) {
            // يمكنك البحث عن رسالة نجاح محددة إذا كان API يرسلها
            // message = responseData['message'] ?? message;
          }
        } else if (response.body.isNotEmpty) {
          responseData = {'rawBody': response.body}; // إذا لم يكن JSON
          message = response.body;
        } else {
          responseData = {}; // جسم فارغ
          message = "Empty response body";
        }
      } catch (e) {
        print('[ApiService.getUserProfile] JSON Decode Error: $e');
        message = 'Error parsing server response.';
        responseData = {'rawErrorBody': response.body};
      }

      bool success = response.statusCode == 200;
      if (!success && isJson && responseData is Map<String, dynamic>) {
        // محاولة استخراج رسالة خطأ من JSON
        message = responseData['message'] ?? responseData['title'] ?? 'Failed to load profile';
      } else if (!success && !isJson) {
        message = response.body.isNotEmpty ? response.body : 'Failed to load profile (Status: ${response.statusCode})';
      }


      return {
        'success': success,
        'data': success ? responseData : null, // أعد البيانات فقط عند النجاح
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

  // --- دالة تحديث الملف الشخصي ---
  static Future<Map<String, dynamic>> updateUserProfile(
      String? token, Map<String, dynamic> profileData) async {
    final url = Uri.parse('$baseUrl/user/update-profile'); // <-- تأكدي من المسار الصحيح
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token'; // <-- إضافة التوكن يدويًا
    } else {
      print("[ApiService.updateUserProfile] Error: Token is required.");
      return {'success': false, 'message': 'Token is required', 'statusCode': 401};
    }

    try {
      print("[ApiService.updateUserProfile] Sending PUT request to $url");
      print("[ApiService.updateUserProfile] Data: ${json.encode(profileData)}");
      // --- استخدام http.put ---
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(profileData), // إرسال البيانات المحدثة
      );
      // -----------------------
      print('[ApiService.updateUserProfile] API Status Code: ${response.statusCode}');
      print('[ApiService.updateUserProfile] API Response Body: ${response.body}');

      dynamic responseData;
      String message = 'Failed to parse response';
      bool isJson = response.headers['content-type']?.contains('application/json') ?? false;

      try {
        if (response.body.isNotEmpty){
          if (isJson) {
            responseData = json.decode(response.body);
            if (responseData is Map<String, dynamic>) {
              message = responseData['message'] ?? responseData['title'] ?? 'Profile updated';
            } else {
              message = responseData.toString();
            }
          } else {
            message = response.body;
            responseData = {'rawBody': message};
          }
        } else {
          responseData = {};
          message = "Profile updated successfully"; // افترض النجاح للجسم الفارغ (200/204)
        }
      } catch (e) {
        print('[ApiService.updateUserProfile] JSON Decode Error: $e');
        message = 'Error parsing server response.';
        responseData = {'rawErrorBody': response.body};
      }

      bool success = response.statusCode == 200 || response.statusCode == 204; // 204 يعني نجاح بدون محتوى
      if (!success && isJson && responseData is Map<String, dynamic>) {
        message = responseData['message'] ?? responseData['title'] ?? 'Failed to update profile';
        if (responseData['errors'] != null) message += " Details: ${json.encode(responseData['errors'])}";
      } else if (!success && !isJson) {
        message = response.body.isNotEmpty ? response.body : 'Failed to update profile (Status: ${response.statusCode})';
      }


      return {
        'success': success,
        'data': responseData, // قد تكون الاستجابة فارغة عند النجاح
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

  // --- دالة رفع صورة الملف الشخصي ---
  static Future<Map<String, dynamic>> uploadProfilePicture(String? token, File imageFile) async {
    final url = Uri.parse('$baseUrl/user/update-profile-picture'); // <-- تأكدي من المسار الصحيح
    final headers = <String, String>{
      // لا نضع Content-Type هنا، http package ستضيفه لـ multipart/form-data
      'Accept': 'application/json', // ماذا نتوقع كاستجابة
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      print("[ApiService.uploadProfilePicture] Error: Token is required.");
      return {'success': false, 'message': 'Token is required', 'statusCode': 401};
    }

    try {
      print("[ApiService.uploadProfilePicture] Sending POST (multipart) request to $url");
      // --- إنشاء طلب multipart ---
      var request = http.MultipartRequest('POST', url); // <-- قد يكون PUT حسب الـ API
      request.headers.addAll(headers);

      // إضافة الملف
      request.files.add(await http.MultipartFile.fromPath(
          'ImageFile', // <-- تأكدي من اسم الحقل الذي يتوقعه الـ API
          imageFile.path,
          contentType: MediaType('image', imageFile.path.split('.').last) // تحديد نوع الصورة
      ));
      // يمكنك إضافة حقول أخرى هنا إذا كان API رفع الصورة يتطلبها
      // request.fields['userId'] = '123';

      // --- إرسال الطلب ---
      var streamedResponse = await request.send();
      // --- قراءة الاستجابة ---
      var response = await http.Response.fromStream(streamedResponse);
      // -----------------------

      print('[ApiService.uploadProfilePicture] API Status Code: ${response.statusCode}');
      print('[ApiService.uploadProfilePicture] API Response Body: ${response.body}');

      dynamic responseData;
      String message = 'Failed to parse response';
      String? newImageUrl;
      bool isJson = response.headers['content-type']?.contains('application/json') ?? false;


      try {
        if (isJson && response.body.isNotEmpty) {
          responseData = json.decode(response.body);
          message = "Picture uploaded";
          if (responseData is Map<String, dynamic>) {
            message = responseData['message'] ?? message;
            // --- استخراج رابط الصورة الجديد ---
            newImageUrl = responseData['imageUrl']; // <-- تأكدي من اسم الحقل الصحيح
            // --------------------------------
          }
        } else if (response.body.isNotEmpty){
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


      bool success = response.statusCode == 200 && newImageUrl != null; // النجاح يتطلب رابط صورة جديد
      if (!success && isJson && responseData is Map<String, dynamic>) {
        message = responseData['message'] ?? responseData['title'] ?? 'Failed to upload picture';
      } else if (!success && !isJson) {
        message = response.body.isNotEmpty ? response.body : 'Failed to upload picture (Status: ${response.statusCode})';
      }


      return {
        'success': success,
        'data': responseData,
        'newImageUrl': newImageUrl, // إرجاع الرابط الجديد
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
  // --- دالة تصنيف الإجابة ---
  // يجب أن تكون هذه الدالة داخل الكلاس ApiService
  // داخل class ApiService

  // ******** دالة تصنيف الإجابة (معدلة للتعامل مع Map) ********
  static Future<String?> classifyAnswerWithModel(String rawText) async {
    const String modelPredictEndpoint = "https://f61c-34-148-145-12.ngrok-free.app/predict";
    final url = Uri.parse(modelPredictEndpoint);
    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}; // اطلب JSON
    final body = jsonEncode({'text': rawText});
    try {
      print('[ApiService.classifyAnswer] Calling Model API: $modelPredictEndpoint');
      final response = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 20));
      print('[ApiService.classifyAnswer] Model API Status: ${response.statusCode}');
      print('[ApiService.classifyAnswer] Model API Response Headers: ${response.headers}'); // طباعة الهيدر للتشخيص
      // print('[ApiService.classifyAnswer] Model API Raw Body Bytes: ${response.bodyBytes}'); // للتشخيص المتقدم

      if (response.statusCode >= 200 && response.statusCode < 300) {

        // --- محاولة فك التشفير باستخدام UTF-8 مباشرة ---
        String decodedBody;
        try {
          // استخدم response.bodyBytes و utf8.decode لمعالجة الترميز يدوياً
          decodedBody = utf8.decode(response.bodyBytes);
          print('[ApiService.classifyAnswer] Body decoded with UTF-8: $decodedBody');
        } catch (e) {
          print('[ApiService.classifyAnswer] Error decoding body with UTF-8, falling back to response.body: $e');
          // في حالة فشل فك التشفير اليدوي، استخدم response.body كاحتياط
          decodedBody = response.body;
        }

        // --- تحليل الـ JSON بعد فك التشفير الصحيح ---
        try {
          final dynamic responseData = jsonDecode(decodedBody);

          if (responseData is Map<String, dynamic>) {
            print('[ApiService.classifyAnswer] Model Response Body (Map): $responseData');

            // --- !! تأكد أن المفتاح هو 'result' !! ---
            final dynamic resultValue = responseData['result']; // اقرأ القيمة

            if (resultValue != null) {
              // حول القيمة إلى نص وقم بتنظيفها
              final String classificationResult = resultValue.toString().trim().replaceAll('"', '');
              const validResults = ["نعم", "لا", "بمساعدة"];

              if (validResults.contains(classificationResult)) { // قارن مع النص الصحيح الآن
                print('[ApiService.classifyAnswer] Model Classified As: $classificationResult');
                return classificationResult;
              } else {
                print('[ApiService.classifyAnswer] Error: Unexpected classification value after UTF-8 decode: "$classificationResult"');
                return null;
              }
            } else {
              print("[ApiService.classifyAnswer] Error: Key 'result' not found in response Map after UTF-8 decode.");
              return null;
            }
          } else {
            print('[ApiService.classifyAnswer] Error: Expected a Map response after UTF-8 decode, but got ${responseData.runtimeType}');
            return null;
          }
        } catch (e) {
          print('[ApiService.classifyAnswer] JSON Decode Error after manual UTF-8 decode: $e');
          print('[ApiService.classifyAnswer] Decoded Body was: $decodedBody');
          return null;
        }

      } else {
        print('[ApiService.classifyAnswer] Error: Failed with status ${response.statusCode}. Body: ${response.body}');
        return null;
      }
    } on TimeoutException catch (e) { print('[ApiService.classifyAnswer] Error: Request timed out - $e'); return null; }
    on SocketException catch (e) { print('[ApiService.classifyAnswer] Error: Network error - $e'); return null; }
    on http.ClientException catch (e) { print('[ApiService.classifyAnswer] Error: Client error - $e'); return null; }
    catch (e) { print('[ApiService.classifyAnswer] Error: An unexpected error occurred - $e'); return null; }
  } // نهاية classifyAnswerWithModel

  // --- دالة إرسال إجابة التقييم ---
  // يجب أن تكون هذه الدالة داخل الكلاس ApiService
  static Future<bool> submitAssessmentAnswer(int questionId, String classifiedAnswer, String jwtToken) async {
    final url = Uri.parse('$baseUrl/sessioncontroller/submit-answers'); // استخدام baseUrl معرف أعلاه
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $jwtToken'};
    final body = jsonEncode({"Answers": [{"SessionId": questionId, "Answer": classifiedAnswer}]});
    try {
      print('[ApiService.submitAnswer] Calling Backend API: ${url.toString()} for Q:$questionId Ans:"$classifiedAnswer"');
      final response = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      print('[ApiService.submitAnswer] Backend API Status: ${response.statusCode}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[ApiService.submitAnswer] Success: Answer submitted.');
        return true; // نجح الإرسال
      } else {
        print('[ApiService.submitAnswer] Error: Failed with status ${response.statusCode}. Body: ${response.body}');
        return false; // فشل الإرسال
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
      print('[ApiService.submitAnswer] Error: An unexpected error occurred - $e');
      return false;
    }
  }
  // داخل class ApiService

// داخل class ApiService في ملف lib/services/api_service.dart

  // ******** دالة جلب خطة التدريب (الجلسة التالية) ********
  // تفترض أن الباك اند يرجع قائمة تحتوي على جلسة واحدة فقط (التالية) أو قائمة فارغة
  static Future<Map<String, dynamic>> getChildSessions(String jwtToken) async {
    // تأكد من أن هذا هو المسار الصحيح لنقطة النهاية في الباك اند
    final url = Uri.parse('$baseUrl/sessioncontroller/get-child-sessions');
    final headers = {
      'Content-Type': 'application/json', // قد لا يكون ضرورياً لـ GET لكنه ممارسة جيدة
      'Authorization': 'Bearer $jwtToken',
      'Accept': 'application/json', // نطلب استجابة JSON
    };

    try {
      print('[ApiService.getChildSessions] Calling GET: ${url.toString()}');
      // استخدام http.get وإضافة مهلة
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 20)); // زيادة المهلة قليلاً

      print('[ApiService.getChildSessions] Status Code: ${response.statusCode}');
      // طباعة الجسم الخام للمساعدة في التشخيص إذا لزم الأمر
      // print('[ApiService.getChildSessions] Raw Response Body: ${response.body}');

      // --- التعامل مع الاستجابات المختلفة ---

      // 1. النجاح (200 OK)
      if (response.statusCode == 200) {
        String decodedBody;
        // محاولة فك التشفير بـ UTF-8 لمعالجة مشاكل الترميز المحتملة
        try {
          decodedBody = utf8.decode(response.bodyBytes);
          print('[ApiService.getChildSessions] Body decoded with UTF-8.');
        } catch(e){
          print('[ApiService.getChildSessions] UTF8 decode failed, using raw response.body.');
          decodedBody = response.body;
        }

        // محاولة تحليل الـ JSON
        try {
          final dynamic responseData = jsonDecode(decodedBody);

          // التحقق من التنسيق المتوقع (كائن يحتوي على $values كقائمة)
          if (responseData is Map<String, dynamic> && responseData.containsKey('\$values') && responseData['\$values'] is List) {
            final List<dynamic> sessionsList = responseData['\$values'];
            print('[ApiService.getChildSessions] Success: Found ${sessionsList.length} session(s).');

            // إرجاع القائمة (قد تحتوي على جلسة واحدة أو تكون فارغة)
            return {'success': true, 'sessions': sessionsList, 'message': 'Sessions loaded successfully.'};
          } else {
            print('[ApiService.getChildSessions] Error: Response format is not as expected (missing \$values or not a List). Body: $decodedBody');
            return {'success': false, 'message': 'تنسيق استجابة الخادم غير متوقع.'};
          }
        } catch (e) {
          print('[ApiService.getChildSessions] JSON Decode Error after manual UTF-8 decode: $e');
          print('[ApiService.getChildSessions] Decoded Body was: $decodedBody');
          return {'success': false, 'message': 'خطأ في تحليل استجابة الخادم.'};
        }

      }
      // 2. لا توجد جلسات (404 Not Found) - نعتبره نجاحاً ولكن بدون بيانات
      else if (response.statusCode == 404) {
        print('[ApiService.getChildSessions] Info: No pending sessions found (404).');
        // إرجاع قائمة فارغة
        return {'success': true, 'sessions': [], 'message': 'لا توجد جلسات تالية متاحة.'};
      }
      // 3. خطأ المصادقة (401 Unauthorized)
      else if (response.statusCode == 401) {
        print('[ApiService.getChildSessions] Error: Unauthorized (401). Check JWT Token.');
        return {'success': false, 'message': 'خطأ في المصادقة. يرجى إعادة تسجيل الدخول.'};
      }
      // 4. أي خطأ آخر من الخادم
      else {
        print('[ApiService.getChildSessions] Error: Failed with status ${response.statusCode}. Body: ${response.body}');
        String errorMsg = 'فشل تحميل الجلسات (خطأ ${response.statusCode})';
        // محاولة قراءة رسالة الخطأ من الـ body إذا كانت JSON
        try {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          if(errorData is Map && errorData.containsKey('message')) { errorMsg = errorData['message']; }
          else if (errorData is Map && errorData.containsKey('title')){ errorMsg = errorData['title']; }
        } catch(_){} // تجاهل أخطاء فك التشفير هنا
        return {'success': false, 'message': errorMsg};
      }
      // --- معالجة أخطاء الاتصال والشبكة ---
    } on TimeoutException catch (e) {
      print('[ApiService.getChildSessions] Error: Request timed out - $e');
      return {'success': false, 'message': 'انتهت مهلة الاتصال بالخادم.'};
    } on SocketException catch (e) {
      print('[ApiService.getChildSessions] Error: Network error - $e');
      return {'success': false, 'message': 'خطأ في الشبكة. يرجى التحقق من اتصالك بالإنترنت.'};
    } on http.ClientException catch (e) { // أخطاء أخرى من مكتبة http
      print('[ApiService.getChildSessions] Error: Client error - $e');
      return {'success': false, 'message': 'حدث خطأ أثناء إعداد الطلب.'};
    } catch (e) { // أي خطأ آخر غير متوقع
      print('[ApiService.getChildSessions] Error: An unexpected error occurred - $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع.'};
    }
  } // نهاية getChildSessions
  // ******** دالة تحديث حالة الجلسة (جديدة) ********
  static Future<bool> updateSessionDone(int sessionId, String jwtToken) async {
    // بناء الـ URL مع تضمين sessionId
    final url = Uri.parse('$baseUrl/sessioncontroller/update-session-done/$sessionId');
    final headers = {
      'Content-Type': 'application/json', // قد لا يكون ضرورياً لـ PUT بدون body
      'Authorization': 'Bearer $jwtToken',
      'Accept': 'application/json, text/plain', // توقع نص أو JSON كاستجابة
    };
    try {
      print('[ApiService.updateSessionDone] Calling PUT: ${url.toString()}');
      // استخدام http.put لأن الـ API يحددها كـ PUT
      final response = await http.put(url, headers: headers).timeout(const Duration(seconds: 15));
      print('[ApiService.updateSessionDone] Status Code: ${response.statusCode}');
      // عادةً PUT أو DELETE الناجح قد يرجع 200 OK أو 204 No Content
      bool success = response.statusCode == 200 || response.statusCode == 204;
      if(success){
        print('[ApiService.updateSessionDone] Success.');
      } else {
        print('[ApiService.updateSessionDone] Error: Failed with status ${response.statusCode}. Body: ${response.body}');
      }
      return success;
    } on TimeoutException catch (e) {
      print('[ApiService.updateSessionDone] Error: Request timed out - $e');
      return false;
    } on SocketException catch (e) {
      print('[ApiService.updateSessionDone] Error: Network error - $e');
      return false;
    } catch (e) {
      print('[ApiService.updateSessionDone] Error: An unexpected error occurred - $e');
      return false;
    }
  } // نهاية updateSessionDone
}