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

    final token = TokenUtils.getToken();
    final expiry = TokenUtils.getTokenExpiry();
    final now = DateTime.now().millisecondsSinceEpoch;

    if (!mounted) return;

    // No token → Login
    if (token == null || token.isEmpty) {
      _goTo(AppRoutes.loginScreenRouteName);
      return;
    }

    // Token exists but expiry missing or valid
    if (expiry == null || now < expiry) {
      _goTo(AppRoutes.childScreenRouteName);
      return;
    }

    // Token expired → try refresh
    bool success = await TokenUtils.refreshAccessToken();

    if (!mounted) return;

    if (success) {
      _goTo(AppRoutes.childScreenRouteName);
    } else {
      _goTo(AppRoutes.loginScreenRouteName);
    }
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

            SizedBox(height: height * .02),

            Text(
              'تطبيق إلكتروني لتنمية مهارة التصور البصري المكاني',
              textAlign: TextAlign.center,
              style: AppStyles.bold16MintGreen,
            ),

            SizedBox(height: height * .008),

            Text(
              'للأطفال ذوي اضطراب التوحد البسيط وذوي متلازمة أسبرجر',
              textAlign: TextAlign.center,
              style: AppStyles.bold16MintGreen,
            ),
          ],
        ),
      ),
    );
  }
}