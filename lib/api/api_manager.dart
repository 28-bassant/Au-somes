import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/cache/shared_prefs_utils.dart';
import '../core/cache/token_utils.dart';
import '../models/activities/activity_response.dart';
import '../models/login_response.dart';
import '../models/progress/log_attempt_response.dart';
import '../models/progress/progress_summary_response.dart';
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
    print("🔵 LOGIN RAW RESPONSE = ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(data);
      print("🟡 TOKEN PARSED = ${loginResponse.token}");
      print("🟠 TOKEN BEFORE SAVE = ${loginResponse.token}");
      await TokenUtils.saveLoginTokens(loginResponse);
      print("TOKEN AFTER LOGIN = ${await TokenUtils.getToken()}"); // 👈 هنا
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

  static Future<String> askChatbot(String prompt) async {
    Uri url = Uri.parse(
      "http://au-somes.runasp.net/api/Chat/ask",
    );

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"Prompt": prompt}),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["response"]?["result"]?.toString() ??
            "Empty response from server";
      }

      if (response.statusCode == 400) {
        throw Exception("Invalid request");
      }

      if (response.statusCode == 401) {
        throw Exception("Unauthorized");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      if (response.statusCode == 404) {
        throw Exception("Chat service not found");
      }

      if (response.statusCode == 429) {
        throw Exception("QuotaExceeded");
      }

      if (response.statusCode >= 500) {
        throw Exception("Server error");
      }

      throw Exception(
        "Status ${response.statusCode}: ${response.body}",
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<ActivityResponse> getActivity(
      String activityId, int param1, int param2) async {

    final url =
        "${ApiConstants.baseUrl}${ApiEndpoints.getActivity}/$activityId/$param1/$param2";
    Uri uri = Uri.parse(url);

    print("Request URL: $uri");

    final response = await http.get(uri);

    print("Raw response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Decoded JSON: $data");

      return ActivityResponse.fromJson(data);
    } else {
      throw Exception(
          "Failed to fetch activity: ${response.statusCode} - ${response.body}");
    }
  }


  static Future<void> updateProfile({
    required String email,
    required String childName,
    required int childAge,
  }) async {
    Uri url = Uri.parse(
      ApiConstants.baseUrl + ApiEndpoints.updateProfile,
    );

    String? token = await TokenUtils.getToken();

    final body = {
      "email": email,
      "childName": childName,
      "childAge": childAge,
    };

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer ${token?.trim()}",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {

      // تحديث البيانات المحلية
      await TokenUtils.saveChildInfo(
        childName,
        childAge,
      );

      await SharedPrefsUtils.saveData(
        key: "email",
        value: email,
      );

      return;
    }

    throw Exception(
      "Failed to update profile: ${response.statusCode}",
    );
  }
  static Future<LogAttemptResponse?> logAttemptStatus({
    required String phaseId,
    required bool userHint,
  }) async {
    Uri url = Uri.parse(ApiConstants.baseUrl + ApiEndpoints.logAttemptStatus);

    final token = await TokenUtils.getToken();

    print(" TOKEN INSIDE API: $token");

    if (token == null || token.isEmpty) {
      print(" No token found");
      return null;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "PhaseId": phaseId,
          "UserHint": userHint,
        }),
      );

      print("🔵 status: ${response.statusCode}");
      print("🔵 body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;

        return LogAttemptResponse.fromJson(jsonDecode(response.body));
      }

      print("API ERROR: ${response.statusCode} - ${response.body}");

      return null;
    } catch (e) {
      print("Exception in logAttemptStatus: $e");
      return null;
    }
  }
  static Future<ProgressSummaryResponse?> getProgressSummary() async {
    final token = await TokenUtils.getToken();

    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiEndpoints.progressSummary),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 401) {
      print(" Token expired");

      final refreshed = await TokenUtils.refreshAccessToken();

      if (refreshed) {
        return getProgressSummary();
      } else {
        await TokenUtils.clearTokens();
        return null;
      }
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProgressSummaryResponse.fromJson(data);
    }

    return null;
  }

}
