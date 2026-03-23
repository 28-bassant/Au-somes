import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:flutter/material.dart';

import '../core/cache/token_utils.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 820),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 2),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    //todo: check token
    Future.delayed(Duration(seconds: 3), () async {
      final token = TokenUtils.getToken();
      final expiry = TokenUtils.getTokenExpiry();
      final now = DateTime.now().millisecondsSinceEpoch;

      if (token != null && token.isNotEmpty) {
        if (expiry != null && now < expiry) {
          //todo:  valid token => navigate to select screen
          Navigator.pushReplacementNamed(context, AppRoutes.selectScreenRouteName);
        } else {
          //todo: token expired => refresh token
          bool success = await TokenUtils.refreshAccessToken();

          if (success) {
            Navigator.pushReplacementNamed(context, AppRoutes.selectScreenRouteName);
          } else {
            //todo:  refresh failed
            Navigator.pushReplacementNamed(context, AppRoutes.loginScreenRouteName);
          }
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreenRouteName);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage(AppAssets.logoImage)),
            SizedBox(height: height * .01),
            SlideTransition(
              position: _slideAnimation,
              child: Image(image: AssetImage(AppAssets.appNameImage)),
            ),
          ],
        ),
      ),
    );
  }
}
