import 'package:flutter/material.dart';
import '../core/cache/token_utils.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:au_somes/utils/app_styles.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initApp();
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 3));

    final token = await TokenUtils.getToken();
    final expiry = await TokenUtils.getTokenExpiry();
    final now = DateTime.now().millisecondsSinceEpoch;
    print("TOKEN = $token");
    if (!mounted) return;

    // No token → Login
    if (token == null || token.isEmpty) {
      _goTo(AppRoutes.loginScreenRouteName);
      return;
    }

    // Token valid
    if (expiry == null || now < expiry) {
      _goTo(AppRoutes.childScreenRouteName);
      return;
    }

    // Token expired → refresh
    final success = await TokenUtils.refreshAccessToken();

    if (!mounted) return;

    _goTo(
      success
          ? AppRoutes.childScreenRouteName
          : AppRoutes.loginScreenRouteName,
    );
  }

  void _goTo(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

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