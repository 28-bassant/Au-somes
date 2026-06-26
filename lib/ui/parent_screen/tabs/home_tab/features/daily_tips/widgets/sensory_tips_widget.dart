import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_tips/widgets/tip_section.dart';
import 'package:flutter/material.dart';
import '../../../../../../../utils/app_colors.dart';

class SensoryTipsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    final List<Map<String, dynamic>> sensoryTipsList = [
      {
        "title": AppLocalizations.of(context)!.sensory_tip1_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.sensory_tip1_content1,
            "hasLink": false,
          },
          {
            "text": AppLocalizations.of(context)!.sensory_tip1_content2,
            "hasLink": false,
          },
          {
            "text": AppLocalizations.of(context)!.sensory_tip1_content3,
            "hasLink": true,
            "url" : 'https://www.youtube.com/watch?v=AGR-2g-jZUU&t=243'
          },
        ],
        "color": AppColors.mintGreen,
      },
      {
        "title": AppLocalizations.of(context)!.sensory_tip2_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.sensory_tip2_content1,
            "hasLink": true,
            'url' : 'https://childwiseaba.com/helping-autistic-kids-with-dressing/'
          },
          {
            "text": AppLocalizations.of(context)!.sensory_tip2_content2,
            "hasLink": true,
            'url' : 'https://www.hopebridge.com/blog/how-to-help-with-sensory-issues-in-kids/'
          },
          {
            "text": AppLocalizations.of(context)!.sensory_tip2_content3,
            "hasLink": true,
            'url' : 'https://theautismvoyage.com/food-texture-sensitivity-7-strategies-to-help/'
          },
        ],
        "color": AppColors.lightPastelBlue,
      },
      {
        "title": AppLocalizations.of(context)!.sensory_tip3_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.sensory_tip3_content1,
            "hasLink": true,
            'url' : 'https://www.firststepschiropractic.com/2025/11/06/sensory-seeking-behaviors/'
          },
          {
            "text": AppLocalizations.of(context)!.sensory_tip3_content2,
            "hasLink": true,
            'url' : 'https://www.abspectrum.org/sensory-integration-therapy-autism-guide/'
          },
          {
            "text": AppLocalizations.of(context)!.sensory_tip3_content3,
            "hasLink": true,
            'url' : 'https://www.choosept.com/health-tips/tips-select-toys-children-with-special-needs'
          },
        ],
        "color": AppColors.pastelPink,
      },
      {
        "title": AppLocalizations.of(context)!.sensory_tip4_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.sensory_tip4_content1,
            "hasLink": false,
          },
          {
            "text": AppLocalizations.of(context)!.sensory_tip4_content2,
            "hasLink": false,
          },
          {
            "text": AppLocalizations.of(context)!.sensory_tip4_content3,
            "hasLink": true,
            'url' : 'https://www.youtube.com/watch?v=3mFTLKdePm4&t=113'
          },
        ],
        "color": AppColors.softBlue,
      },
      {
        "title": AppLocalizations.of(context)!.sensory_tip5_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.sensory_tip5_content1,
            "hasLink": false,
          },
          {
            "text": AppLocalizations.of(context)!.sensory_tip5_content2,
            "hasLink": false,
          },
          {
            "text": AppLocalizations.of(context)!.sensory_tip5_content3,
            "hasLink": true,
            'url' :'https://raisingchildren.net.au/autism/behaviour/understanding-behaviour/sensory-sensitivities-asd'
          },
        ],
        "color": AppColors.mintGreen,
      },
      {
        "title": AppLocalizations.of(context)!.sensory_tip6_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.sensory_tip6_content1,
            "hasLink": false,
          },

        ],
        "color": AppColors.lightPastelBlue,
      },
    ];

    return ListView.separated(
      itemCount: sensoryTipsList.length,
      itemBuilder: (context, index) {
        final item = sensoryTipsList[index];

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