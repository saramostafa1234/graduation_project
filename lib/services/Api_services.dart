import 'dart:convert';

import 'package:http/http.dart' as http;

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
}