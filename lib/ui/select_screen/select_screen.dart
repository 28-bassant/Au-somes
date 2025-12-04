
import 'package:flutter/material.dart';

import '../../core/cache/token_utils.dart';
import '../../utils/app_routes.dart';

class SelectScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Screen'),
      ),
      body: ElevatedButton(
        onPressed: () async {
          await TokenUtils.clearTokens();

          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.loginScreenRouteName,
                (route) => false,
          );
        },
        child: Text("Logout"),
      ),
    );
  }
}