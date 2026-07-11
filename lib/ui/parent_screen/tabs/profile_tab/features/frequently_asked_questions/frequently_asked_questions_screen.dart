import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/parent_screen/tabs/profile_tab/features/frequently_asked_questions/widgets/faq_item.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

class FrequentlyAskedQuestions extends StatelessWidget {
  FrequentlyAskedQuestions({super.key});



  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        "question": AppLocalizations.of(context)!.ques1,
        "answer":AppLocalizations.of(context)!.ans1
      },
      {
        "question": AppLocalizations.of(context)!.ques2,
        "answer":AppLocalizations.of(context)!.ans2
      },
      {
        "question": AppLocalizations.of(context)!.ques3,
        "answer":AppLocalizations.of(context)!.ans3
      },
      {
        "question": AppLocalizations.of(context)!.ques4,
        "answer":AppLocalizations.of(context)!.ans4
      },
      {
        "question": AppLocalizations.of(context)!.ques5,
        "answer":AppLocalizations.of(context)!.ans5
      },
      {
        "question": AppLocalizations.of(context)!.ques6,
        "answer":AppLocalizations.of(context)!.ans6
      },
      {
        "question": AppLocalizations.of(context)!.ques7,
        "answer":AppLocalizations.of(context)!.ans7
      },
      {
        "question": AppLocalizations.of(context)!.ques8,
        "answer":AppLocalizations.of(context)!.ans8
      },
      {
        "question": AppLocalizations.of(context)!.ques9,
        "answer":AppLocalizations.of(context)!.ans9
      },
      {
        "question": AppLocalizations.of(context)!.ques10,
        "answer":AppLocalizations.of(context)!.ans10
      },
      {
        "question": AppLocalizations.of(context)!.ques11,
        "answer":AppLocalizations.of(context)!.ans11
      },
      {
        "question": AppLocalizations.of(context)!.ques12,
        "answer":AppLocalizations.of(context)!.ans12
      },
      {
        "question": AppLocalizations.of(context)!.ques13,
        "answer":AppLocalizations.of(context)!.ans13
      },
      {
        "question": AppLocalizations.of(context)!.ques14,
        "answer":AppLocalizations.of(context)!.ans14
      },
      {
        "question": AppLocalizations.of(context)!.ques15,
        "answer":AppLocalizations.of(context)!.ans15
      },
      {
        "question": AppLocalizations.of(context)!.ques16,
        "answer":AppLocalizations.of(context)!.ans16
      },

    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.help,
          style: AppStyles.bold22Black
        ),
        iconTheme:  IconThemeData(color: AppColors.blackColor),
      ),
      body: ListView.builder(
        padding:  EdgeInsets.all(20),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding:  EdgeInsets.only(bottom: 15),
            child: FAQItem(
              question: faqs[index]["question"]!,
              answer: faqs[index]["answer"]!,
            ),
          );
        },
      ),
    );
  }
}

