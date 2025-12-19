import 'dart:ui';

import 'package:fluttertoast/fluttertoast.dart';


class ToastUtils {
  static Future<bool?> ShowToast({
    required String msg,
    required Color bgColor,
    required Color textColor,
  }) {
    return Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: bgColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}