import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../api/api_constants.dart';
import '../../api/api_endpoints.dart';
import '../../models/login_response.dart';
import '../../models/register_response.dart';
import 'shared_prefs_utils.dart';

class TokenUtils {

  // ---------------- SAVE REGISTER ----------------
  static Future<void> saveTokens(RegisterResponse res) async {
    await _saveCommonTokens(
      token: res.token,
      refreshToken: res.refreshToken,
      expiresIn: res.expiresIn,
      childName: res.childName,
      childAge: res.childAge,
      email: res.email,
      userId: res.id,
    );
  }

  // ---------------- SAVE LOGIN ----------------
  static Future<void> saveLoginTokens(LoginResponse res) async {
    print("🔥 SAVING TOKEN: ${res.token}");

    await _saveCommonTokens(
      token: res.token,
      refreshToken: res.refreshToken,
      expiresIn: res.expiresIn,
      childName: res.childName,
      childAge: res.childAge,
      email: res.email,
      userId: res.id,
    );
  }

  // ---------------- COMMON SAVE ----------------
  static Future<void> _saveCommonTokens({
    required String? token,
    required String? refreshToken,
    required int? expiresIn,
    required String? childName,
    required int? childAge,
    required String? email,
    required String? userId,
  }) async {
    if (token != null && token.isNotEmpty) {
      await SharedPrefsUtils.saveData(key: "token", value: token);
    }
    await SharedPrefsUtils.saveData(key: "refreshToken", value: refreshToken ?? "");

    final expiry = getExpiryFromToken(token) ??
        DateTime.now()
            .add(Duration(seconds: expiresIn ?? 1800))
            .millisecondsSinceEpoch;

    await SharedPrefsUtils.saveData(key: "tokenExpiry", value: expiry);

    await saveChildInfo(childName, childAge);

    if (email != null) {
      await SharedPrefsUtils.saveData(key: "email", value: email);
    }
    if (userId != null) {
      await SharedPrefsUtils.saveData(
        key: "userId",
        value: userId,
      );
    }
  }

  // ---------------- GET TOKEN (FIXED) ----------------
  static Future<String?> getToken() async {
    final value = await SharedPrefsUtils.getData(key: "token");

    print("🔥 READ TOKEN: $value");

    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static Future<String?> getRefreshToken() async {
    final value = SharedPrefsUtils.getData(key: "refreshToken");
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static Future<int?> getTokenExpiry() async {
    final value = SharedPrefsUtils.getData(key: "tokenExpiry");
    if (value is int) return value;
    return null;
  }

  // ---------------- JWT EXP ----------------
  static int? getExpiryFromToken(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      final Map<String, dynamic> data = jsonDecode(decoded);

      if (data['exp'] == null) return null;

      return (data['exp'] as int) * 1000;
    } catch (_) {
      return null;
    }
  }


  // 👇 child data
  static String? getChildName() {
    final value = SharedPrefsUtils.getData(key: "childName");
    if (value is String) return value;
    return null;
  }

  static int? getChildAge() {
    final value = SharedPrefsUtils.getData(key: "childAge");
    if (value is int) return value;
    return null;
  }

  static String? getEmail() {
    final value = SharedPrefsUtils.getData(key: "email");
    if (value is String) return value;
    return null;
  }
  static String? getUserId() {
    final value = SharedPrefsUtils.getData(key: "userId");
    if (value is String) return value;
    return null;
  }

  // ---------------- CLEAR ----------------
  static Future<void> clearTokens() async {
    await SharedPrefsUtils.removeData(key: "token");
    await SharedPrefsUtils.removeData(key: "refreshToken");
    await SharedPrefsUtils.removeData(key: "tokenExpiry");
    await SharedPrefsUtils.removeData(key: "childName");
    await SharedPrefsUtils.removeData(key: "childAge");
    await SharedPrefsUtils.removeData(key: "email");
    await SharedPrefsUtils.removeData(key: "userId");
  }

  // ---------------- REFRESH TOKEN ----------------
  static Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiEndpoints.refreshToken),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveLoginTokens(LoginResponse.fromJson(data));
      return true;
    }

    return false;
  }


  // ---------------- CHILD INFO ----------------
  static Future<void> saveChildInfo(String? name, int? age) async {
    if (name != null) {
      await SharedPrefsUtils.saveData(key: "childName", value: name);
    }
    if (age != null) {
      await SharedPrefsUtils.saveData(key: "childAge", value: age);
    }
  }
}
