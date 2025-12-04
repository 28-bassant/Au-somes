import 'package:au_somes/core/cache/shared_prefs_utils.dart';
import '../../models/register_response.dart';

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
}
