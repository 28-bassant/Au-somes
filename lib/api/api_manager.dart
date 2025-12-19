import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../core/cache/token_utils.dart';
import '../models/login_response.dart';
import '../models/register_response.dart';
import '../utils/app_routes.dart';
import 'api_constants.dart';
import 'api_endpoints.dart';
import 'dart:async';
import 'dart:io';

class ApiManager {
  static Future<RegisterResponse?> register({
    required String childName,
    required String email,
    required String password,
    required String confirmPassword,
    required int age,
  }) async {
    Uri url = Uri.parse(ApiConstants.baseUrl + ApiEndpoints.register);

    var body = jsonEncode({
      "childName": childName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "childAge": age,
    });

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final registerResponse = RegisterResponse.fromJson(data);
      await TokenUtils.saveTokens(registerResponse);
      return registerResponse;
    } else {
      final errorJson = jsonDecode(response.body);

      if (errorJson["errors"] is List) {
        final description = errorJson["errors"][0]["description"];
        throw Exception(description);
      }

      if (errorJson["errors"] is Map) {
        final Map errors = errorJson["errors"];

        List<String> messages = [];

        errors.forEach((key, value) {
          if (value is List) {
            for (var msg in value) {
              messages.add(msg.toString());
            }
          }
        });

        throw Exception(messages.join("\n"));
      }

      throw Exception("Registration failed. Try again.");
    }
  }

  static Future<LoginResponse?> login({
    required String email,
    required String password,
  }) async {
    Uri url = Uri.parse(ApiConstants.baseUrl + ApiEndpoints.login);

    var body = jsonEncode({
      "email": email,
      "password": password,
    });

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      final loginResponse = LoginResponse.fromJson(data);

      await TokenUtils.saveLoginTokens(loginResponse);

      return loginResponse;
    } else {
      final errorJson = jsonDecode(response.body);

      if (errorJson["errors"] is List) {
        final description = errorJson["errors"][0]["description"];
        throw Exception(description);
      }

      if (errorJson["errors"] is Map) {
        final Map errors = errorJson["errors"];
        List<String> messages = [];

        errors.forEach((key, value) {
          if (value is List) {
            for (var msg in value) {
              messages.add(msg.toString());
            }
          }
        });

        throw Exception(messages.join("\n"));
      }

      throw Exception("Login failed. Try again.");
    }
  }

  static Future<void> forgetPassword({required String email}) async {
    Uri url = Uri.parse(ApiConstants.baseUrl + ApiEndpoints.forgetPassword);

    var body = jsonEncode({"email": email});

    try {
      var response = await http
          .post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw Exception('Failed to send verification code');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<String?> verifyCode({
    required String email,
    required String code,
  }) async {
    if (code.isEmpty || code.length != 5) {
      return 'Invalid verification code';
    }

    Uri url = Uri.parse(ApiConstants.baseUrl + ApiEndpoints.verifyCode);

    var body = jsonEncode({
      "email": email,
      "code": code.trim(),
    });

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      } else {
        final data = jsonDecode(response.body);
        if (data['errors'] != null && data['errors'].isNotEmpty) {
          return data['errors'][0]['description'];
        }
        return 'Unknown error';
      }
    } catch (e) {
      return e.toString();
    }
  }


  static Future<String?> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    Uri url = Uri.parse(ApiConstants.baseUrl + ApiEndpoints.resetPassword);

    var body = jsonEncode({
      "email": email,
      "code": code,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    });

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      } else {
        final data = jsonDecode(response.body);
        if (data['errors'] != null && data['errors'].isNotEmpty) {
          return data['errors'][0]['description'];
        }
        return 'Unknown error';
      }
    } catch (e) {
      return e.toString();
    }
  }



}
