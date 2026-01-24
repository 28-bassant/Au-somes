import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class TipHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const TipHeader({
    super.key,
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppStyles.bold14Black
        ),
        GestureDetector(
          onTap: onViewAll,
          child:Text(
            'View all',
            style: AppStyles.medium16SoftBlue
          ),
        ),
      ],
    );
  }
}