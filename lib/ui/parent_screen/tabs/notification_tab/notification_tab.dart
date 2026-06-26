import 'package:au_somes/ui/parent_screen/tabs/notification_tab/notification_item.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class NotificationTab extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications,style: AppStyles.bold22Black,),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal:width*.04,vertical: height*.02),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.today,style: AppStyles.regular16BlackWithOpacity60,),
              SizedBox(height: height*.02,),
              NotificationItem(image: AppAssets.timeIcon, text1:AppLocalizations.of(context)!.reminder, text2:AppLocalizations.of(context)!.minutes_ago, text3:AppLocalizations.of(context)!.reminder_message),
              SizedBox(height: height*.02,),
              NotificationItem(image: AppAssets.reminderIcon, text1: AppLocalizations.of(context)!.reminder, text2:AppLocalizations.of(context)!.minutes_ago, text3:AppLocalizations.of(context)!.new_activity_message),
              SizedBox(height: height*.02,),
              NotificationItem(image: AppAssets.tipsIcon, text1: AppLocalizations.of(context)!.daily_tips, text2:AppLocalizations.of(context)!.minutes_ago, text3:AppLocalizations.of(context)!.daily_tips_message),
              SizedBox(height: height*.02,),
              Text(AppLocalizations.of(context)!.yesterday,style: AppStyles.regular16BlackWithOpacity60,),
              SizedBox(height: height*.02,),
              NotificationItem(image: AppAssets.chatbotIcon, text1: AppLocalizations.of(context)!.ask_chatbot_now, text2:AppLocalizations.of(context)!.days_ago, text3:AppLocalizations.of(context)!.ask_chatbot_message)
              ,          SizedBox(height: height*.02,),
              NotificationItem(image: AppAssets.reminderIcon, text1:AppLocalizations.of(context)!.reminder, text2:AppLocalizations.of(context)!.days_ago, text3:AppLocalizations.of(context)!.support_message),

            ],
          ),
        ),
      ),
    );
  }
}