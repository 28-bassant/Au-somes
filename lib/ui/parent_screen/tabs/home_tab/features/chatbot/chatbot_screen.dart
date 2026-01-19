import 'dart:convert';

import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/bot_message.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/chat_constants.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/chat_input.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/chat_message.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/quick_question_card.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/chatbot/widgets/user_message.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../api/api_manager.dart';
import '../../../../../../core/cache/shared_prefs_utils.dart';
import '../../../../../../providers/app_language_provider.dart';
import '../../../../../../utils/app_assets.dart';
import '../../../../../../utils/app_colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  bool hasStartedChat = false;
  List<ChatMessage> messages = [];
  TextEditingController controller = TextEditingController();
  bool isLoading = false;
  bool isTyping = false;
  ScrollController scrollController=ScrollController();

  @override
  void initState() {
    super.initState();
    loadChat();
  }

  void loadChat() {
    final storedMessages =
    SharedPrefsUtils.getData(key: ChatConstants.chatMessagesKey) as List<String>?;

    final started =
    SharedPrefsUtils.getData(key: ChatConstants.chatStartedKey) as bool?;

    if (storedMessages != null) {
      messages = storedMessages
          .map((e) => ChatMessage.fromJson(jsonDecode(e)))
          .toList();
    }

    hasStartedChat = started ?? false;
    setState(() {});
  }

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
                  controller: scrollController,
                  children: [
                    if (hasStartedChat)
                      ...messages.map((msg) {
                        return msg.isUser
                            ? UserMessage(text: msg.text)
                            : BotMessage(text: msg.text);
                      }).toList()
                    else
                      ...[
                        BotMessage(
                          text: AppLocalizations.of(context)!.welcome,
                        ),
                        SizedBox(height: height * .016),

                        Container(
                          padding: EdgeInsets.all(width * .03),
                          margin: EdgeInsets.symmetric(horizontal: width * .08),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  sendMessage(
                                    AppLocalizations.of(context)!
                                        .what_is_visual_spatial_perception,
                                  );
                                },
                                child: QuickQuestionCard(
                                  text: AppLocalizations.of(context)!
                                      .what_is_visual_spatial_perception,
                                  borderColor: AppColors.mintGreen,
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  sendMessage(
                                    AppLocalizations.of(context)!
                                        .how_is_visual_spatial_perception_related_to_autism,
                                  );
                                },
                                child: QuickQuestionCard(
                                  text: AppLocalizations.of(context)!
                                      .how_is_visual_spatial_perception_related_to_autism,
                                  borderColor: AppColors.lightPastelBlue,
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  sendMessage(
                                    AppLocalizations.of(context)!.game_improve,
                                  );
                                },
                                child: QuickQuestionCard(
                                  text: AppLocalizations.of(context)!.game_improve,
                                  borderColor: AppColors.pastelPink,
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  sendMessage(
                                    AppLocalizations.of(context)!.confusion,
                                  );
                                },
                                child: QuickQuestionCard(
                                  text: AppLocalizations.of(context)!.confusion,
                                  borderColor: AppColors.mintGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * .016),
                      ],
                    if (isTyping)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.softBlue,
                              child: Image.asset(AppAssets.chatbotImage, width: 30),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),   SizedBox(width: 8),
                                  Text(AppLocalizations.of(context)!.thinking,
                                    style: AppStyles.medium14BlackWithOpacity60,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              ChatInput(
                controller: controller,
                onSend: () {
                  sendMessage(controller.text);
                },
              ),
            ],
          ),
        ),

    );
  }
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      if (!hasStartedChat) {
        messages.clear();
        hasStartedChat = true;
      }
      messages.add(ChatMessage(text: text, isUser: true));
      isTyping = true;
    });
    controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      final answer = await ApiManager.askChatbot(text);

      setState(() {
        isTyping = false;
        messages.add(ChatMessage(text: answer, isUser: false));
      });

    } catch (e, s) {
      print("Error from API: $e");
      print("Stacktrace: $s");

      String errorMessage =AppLocalizations.of(context)!.error_try_again ;

      if (e.toString().toLowerCase().contains("quota") ||
          e.toString().toLowerCase().contains("quotafailure")) {
        errorMessage =
        AppLocalizations.of(context)!.exceeded_api;
      }

      setState(() {
        isTyping = false;
        messages.add(ChatMessage(
          text: errorMessage,
          isUser: false,
        ));
      });
    }

    await saveChat();
  }

  Future<void> saveChat() async {
    List<String> encodedMessages =
    messages.map((m) => jsonEncode(m.toJson())).toList();

    await SharedPrefsUtils.saveData(
      key: ChatConstants.chatMessagesKey,
      value: encodedMessages,
    );
    await SharedPrefsUtils.saveData(
      key: ChatConstants.chatStartedKey,
      value: hasStartedChat,
    );
  }




}