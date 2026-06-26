import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_tips/widgets/tip_section.dart';
import 'package:flutter/material.dart';

import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../utils/app_colors.dart';

class CommunicationTipsWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    final List<Map<String, dynamic>> communicationTipsList = [
      {
        "title": AppLocalizations.of(context)!.communication_tip1_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.communication_tip1_content,
            "hasLink": true,
            'url' : 'https://www.autism.org.uk/learn/knowledge-hub/professional-practice/communication-pupils'
          },

        ],
        "color": AppColors.mintGreen,
      },
      {
        "title": AppLocalizations.of(context)!.communication_tip2_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.communication_tip2_content,
            "hasLink": true,
            'url' : 'https://www.stanfordchildrens.org/en/topic/default?id=interacting-with-a-child-who-has-autism-spectrum-disorder-160-46'
          },

        ],
        "color": AppColors.lightPastelBlue,
      },
      {
        "title": AppLocalizations.of(context)!.communication_tip3_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.communication_tip3_content,
            "hasLink": true,
            'url' : 'https://www.actionbehavior.com/resource/post/9-tips-for-communicating-with-children-diagnosed-with-autism'
          },

        ],
        "color": AppColors.pastelPink,
      },
      {
        "title": AppLocalizations.of(context)!.communication_tip4_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.communication_tip4_content,
            "hasLink": true,
            'url' : 'https://leafwingcenter.org/autism-communication-strategies/'
          },

        ],
        "color": AppColors.pastelPink,
      },
      {
        "title": AppLocalizations.of(context)!.communication_tip5_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.communication_tip5_content,
            "hasLink": true,
            'url' : 'https://www.youtube.com/watch?v=nH5tn5nJ9ys&t=163'
          },

        ],
        "color": AppColors.mintGreen,
      },
      {
        "title": AppLocalizations.of(context)!.communication_tip6_title,
        "content": [
          {
            "text": AppLocalizations.of(context)!.communication_tip6_content,
            "hasLink": true,
            'url' : 'https://clinikids.thekids.org.au/information-hub/blog/communication-tips-blog/'
          },

        ],
        "color": AppColors.lightPastelBlue,
      },

    ];
    return ListView.separated(
      itemCount: communicationTipsList.length,
      itemBuilder: (context, index) {
        final item = communicationTipsList[index];

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