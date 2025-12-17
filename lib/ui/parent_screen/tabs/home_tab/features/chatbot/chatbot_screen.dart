import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/bot_message.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/chat_input.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/quick_question_card.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/user_message.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../../../../utils/app_colors.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,

        centerTitle: true,
        title: Text(
          'Ask Chatbot',
          style:AppStyles.bold20SoftBlue
        ),
      ),
      body: Padding(
          padding: EdgeInsets.only(top: height*.02,bottom:height*.03,left: width*.04,right:  width*.04),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                    children: [BotMessage(text:
                  AppLocalizations.of(context)!.welcome,
                ),
                SizedBox(height: height*.016),
                Container(
                  padding: EdgeInsets.all(width*.03),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.only(topLeft:Radius.circular(16),bottomLeft:Radius.circular(1),
                        topRight: Radius.circular(16),bottomRight: Radius.circular(16) ),
                  ),
                  child: Column(
                    children: [
                      QuickQuestionCard(text: AppLocalizations.of(context)!.what_is_visual_spatial_perception),
                      QuickQuestionCard(text:
                      AppLocalizations.of(context)!.how_is_visual_spatial_perception_related_to_autism),
                      QuickQuestionCard(text:
                      AppLocalizations.of(context)!.game_improve),
                      QuickQuestionCard(text:
                      AppLocalizations.of(context)!.confusion),
                      QuickQuestionCard(text: AppLocalizations.of(context)!.another_question),
                    ],
                  ),
                ), SizedBox(height: height*.016),
                UserMessage(text:  AppLocalizations.of(context)!.what_is_visual_spatial_perception),
                      SizedBox(height: height*.016),
                BotMessage(text:
                AppLocalizations.of(context)!.visual_spatial_perception_meaning,
                ), ]),
              ),
              ChatInput(onSend:(){})
            ],
          ),
        ),

    );
  }


}