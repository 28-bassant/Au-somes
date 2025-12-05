import 'dart:convert';

import 'package:au_somes/core/cache/shared_prefs_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../api/api_constants.dart';
import '../../api/api_endpoints.dart';
import '../../models/login_response.dart';
import '../../models/register_response.dart';
import '../../utils/app_routes.dart';

class TokenUtils {
  static Future<void> saveTokens(RegisterResponse registerResponse) async {
    await SharedPrefsUtils.saveData(key: "token", value: registerResponse.token ?? "");
    await SharedPrefsUtils.saveData(key: "refreshToken", value: registerResponse.refreshToken ?? "");
  }

  static String? getToken() {
    return SharedPrefsUtils.getData(key: "token") as String?;
  }

  static String? getRefreshToken() {
    return SharedPrefsUtils.getData(key: "refreshToken") as String?;
  }

  static Future<void> saveLoginTokens(LoginResponse loginResponse) async {
    await SharedPrefsUtils.saveData(
        key: "token", value: loginResponse.token ?? "");

    await SharedPrefsUtils.saveData(
        key: "refreshToken", value: loginResponse.refreshToken ?? "");
  }

  static int? getTokenExpiry() {
    return SharedPrefsUtils.getData(key: "tokenExpiry") as int?;
  }


  static Future<void> clearTokens() async {
    await SharedPrefsUtils.removeData(key: "token");
    await SharedPrefsUtils.removeData(key: "refreshToken");
    await SharedPrefsUtils.removeData(key: "tokenExpiry");
  }


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
    } else {
      return false;
    }
  }

  }




