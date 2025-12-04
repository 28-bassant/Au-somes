import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/cache/token_utils.dart';
import '../models/register_response.dart';
import 'api_constants.dart';
import 'api_endpoints.dart';

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


}
