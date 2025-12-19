
import 'package:au_somes/utils/app_styles.dart';

import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../utils/app_colors.dart';
import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final VoidCallback onSend;

  const ChatInput({super.key, required this.onSend});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width*.02,vertical:height*.003),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 2,color: AppColors.softBlue),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.type_your_question_here,
                hintStyle:AppStyles.bold16SoftBlue,
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: AppColors.softBlue,
            ),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}