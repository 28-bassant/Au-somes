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
    await SharedPrefsUtils.saveData(key: "token", value: res.token ?? "");
    await SharedPrefsUtils.saveData(key: "refreshToken", value: res.refreshToken ?? "");

    final expiry = getExpiryFromToken(res.token) ??
        DateTime.now()
            .add(Duration(seconds: res.expiresIn ?? 1800))
            .millisecondsSinceEpoch;

    await SharedPrefsUtils.saveData(key: "tokenExpiry", value: expiry);

    await saveChildInfo(res.childName, res.childAge);

    if (res.email != null) {
      await SharedPrefsUtils.saveData(key: "email", value: res.email!);
    }
  }

  // ---------------- SAVE LOGIN ----------------
  static Future<void> saveLoginTokens(LoginResponse res) async {
    await SharedPrefsUtils.saveData(key: "token", value: res.token ?? "");
    await SharedPrefsUtils.saveData(key: "refreshToken", value: res.refreshToken ?? "");

    final expiry = getExpiryFromToken(res.token) ??
        DateTime.now()
            .add(Duration(seconds: res.expiresIn ?? 1800))
            .millisecondsSinceEpoch;

    await SharedPrefsUtils.saveData(key: "tokenExpiry", value: expiry);

    await saveChildInfo(res.childName, res.childAge);

    if (res.email != null) {
      await SharedPrefsUtils.saveData(key: "email", value: res.email!);
    }
  }

  // ---------------- GET TOKENS ----------------
  static String? getToken() =>
      SharedPrefsUtils.getData(key: "token") as String?;

  static String? getRefreshToken() =>
      SharedPrefsUtils.getData(key: "refreshToken") as String?;

  static int? getTokenExpiry() =>
      SharedPrefsUtils.getData(key: "tokenExpiry") as int?;

  // ---------------- JWT EXP EXTRA (NEW FIX) ----------------
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

      return (data['exp'] as int) * 1000; // seconds → milliseconds
    } catch (e) {
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

  // ---------------- CLEAR ----------------
  static Future<void> clearTokens() async {
    await SharedPrefsUtils.removeData(key: "token");
    await SharedPrefsUtils.removeData(key: "refreshToken");
    await SharedPrefsUtils.removeData(key: "tokenExpiry");
    await SharedPrefsUtils.removeData(key: "childName");
    await SharedPrefsUtils.removeData(key: "childAge");
    await SharedPrefsUtils.removeData(key: "email");
  }

  // ---------------- REFRESH TOKEN ----------------
  static Future<bool> refreshAccessToken() async {
    final refreshToken = getRefreshToken();
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
