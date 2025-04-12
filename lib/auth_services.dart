import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://aspiq.runasp.net/api';

  // Save token to local storage
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Get token from local storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Clear token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Register a new user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String surname,
    required String email,
    required String phone,
    String? doctorId,
    String? image,
    String? birthDate,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Name_': name,
        'Surname': surname,
        'Email': email,
        'Phone': phone,
        'Doctor_ID': doctorId,
        'Image_': image,
        'BirthDate': birthDate,
        'Password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  // Send OTP code
  static Future<Map<String, dynamic>> sendOTP(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/Send-OTP'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Email': email,
      }),
    );

    return jsonDecode(response.body);
  }

  // Verify email with OTP
  static Future<Map<String, dynamic>> verifyEmailOTP(
      String token, String otpCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-email-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Token': token,
        'OtpCode': otpCode,
      }),
    );

    return jsonDecode(response.body);
  }

  // Login
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Email': email,
        'Password': password,
      }),
    );

    final data = jsonDecode(response.body);

    // Save token if login successful
    if (response.statusCode == 200 && data.containsKey('token')) {
      await saveToken(data['token']);
    }

    return data;
  }

  // Verify OTP for password reset
  static Future<Map<String, dynamic>> verifyOTP(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Email': email,
      }),
    );

    return jsonDecode(response.body);
  }

  // Reset password
  static Future<Map<String, dynamic>> resetPassword(
      String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Token': token,
        'NewPassword': newPassword,
      }),
    );

    return jsonDecode(response.body);
  }
}
