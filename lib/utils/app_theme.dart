import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme{
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundColor,
        iconTheme: IconThemeData(
          color: AppColors.softBlue,

        )

    )
  );

}