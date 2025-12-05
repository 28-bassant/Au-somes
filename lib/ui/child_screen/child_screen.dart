import 'package:au_somes/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ChildScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('child screen'),
        iconTheme: IconThemeData(
          color: AppColors.softBlue
        ),
      ),
    );
  }
}