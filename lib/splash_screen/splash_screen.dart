import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:flutter/material.dart';

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

    Future.delayed(Duration(seconds: 4), () {
      //todo: Navigate to login screen
      Navigator.pushReplacementNamed(context, AppRoutes.registerScreenRouteName);
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
