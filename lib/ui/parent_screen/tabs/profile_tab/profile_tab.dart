import 'package:au_somes/custom_widgets/custom_elevated_button.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Tab'),
      ),
      body: Column(
        children: [
          CustomElevatedButton(text: 'Reset Password',
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.forgetPasswordScreen1RouteName);
          },
          )
        ],
      ),
    );
  }
}