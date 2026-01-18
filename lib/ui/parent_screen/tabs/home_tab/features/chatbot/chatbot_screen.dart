import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/bot_message.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/chat_input.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/quick_question_card.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/user_message.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../providers/app_language_provider.dart';
import '../../../../../../utils/app_colors.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var languageProvider = Provider.of<AppLanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.lightPastelBlue,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.blackColor
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(AppLocalizations.of(context)!.ask_chatbot,style: AppStyles.bold22Black,),
            Text(AppLocalizations.of(context)!.get_instant_answers,style: AppStyles.regular14BlackWithOpacity60,),
          ],
        )
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
                  margin: EdgeInsets.only(right: width*.08,left: width*.08),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.only(topLeft:Radius.circular(16),bottomLeft:languageProvider.isArabic()?Radius.circular(16):Radius.circular(0),
                        topRight: Radius.circular(16),bottomRight:languageProvider.isArabic()? Radius.circular(0):Radius.circular(16) ),
                  ),
                  child: Column(
                    children: [
                      QuickQuestionCard(text: AppLocalizations.of(context)!.what_is_visual_spatial_perception,borderColor: AppColors.mintGreen,),
                      QuickQuestionCard(text:
                      AppLocalizations.of(context)!.how_is_visual_spatial_perception_related_to_autism,borderColor: AppColors.lightPastelBlue,),
                      QuickQuestionCard(text:
                      AppLocalizations.of(context)!.game_improve,borderColor: AppColors.pastelPink,),
                      QuickQuestionCard(text:
                      AppLocalizations.of(context)!.confusion,borderColor: AppColors.mintGreen,),
                      QuickQuestionCard(text: AppLocalizations.of(context)!.another_question,borderColor: AppColors.lightPastelBlue,),
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