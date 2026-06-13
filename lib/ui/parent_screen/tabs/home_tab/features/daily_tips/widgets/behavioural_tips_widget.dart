import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_tips/widgets/tip_section.dart';
import 'package:flutter/material.dart';

import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../utils/app_colors.dart';

class BehaviouralTipsWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    final List<Map<String, dynamic>> behaviouralTipsList = [
      {
        "title": AppLocalizations.of(context)!.behavioural_tip1_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.behavioural_tip1_content1,
            "hasLink": true,
            'url' : 'https://www.autismspecialtygroup.com/blog/7-essential-autism-behavior-management-strategies'
          },
          {
            "text": AppLocalizations.of(context)!.behavioural_tip1_content2,
            "hasLink": true,
            'url' : 'https://www.helpguide.org/mental-health/autism/autism-behavior-problems'
          },
        ],
        "color": AppColors.mintGreen,
      },
      {
        "title": AppLocalizations.of(context)!.behavioural_tip2_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.behavioural_tip2_content1,
            "hasLink": false,
          },
          {
            "text": AppLocalizations.of(context)!.behavioural_tip2_content2,
            "hasLink": false,
          },
          {
            "text": AppLocalizations.of(context)!.behavioural_tip2_content3,
            "hasLink": true,
            'url' : 'https://www.autismspeaks.org/blog/five-tips-helped-improve-my-childs-behavior'
          },
        ],
        "color": AppColors.lightPastelBlue,
      },
      {
        "title": AppLocalizations.of(context)!.behavioural_tip3_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.behavioural_tip3_content1,
            "hasLink": false,
          },
          {
            "text": AppLocalizations.of(context)!.behavioural_tip3_content2,
            "hasLink": true,
            'url' : 'https://spectrumofhope.com/blog/create-routine-for-kids-with-autism/'
          },

        ],
        "color": AppColors.pastelPink,
      },
      {
        "title": AppLocalizations.of(context)!.behavioural_tip4_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.behavioural_tip4_content1,
            "hasLink": false,
          },
          {
            "text": AppLocalizations.of(context)!.behavioural_tip4_content2,
            "hasLink": true,
            'url' : 'https://www.helpguide.org/mental-health/autism/autism-behavior-problems'
          },

        ],
        "color": AppColors.softBlue,
      },

    ];

    return ListView.separated(
      itemCount: behaviouralTipsList.length,
      itemBuilder: (context, index) {
        final item = behaviouralTipsList[index];

        return TipSection(
          title: item["title"],
          content: item["content"],
          backgroundColor: item["color"],
        );
      },
      separatorBuilder: (context, index) =>
          SizedBox(height: height * .02),
    );
  }
}