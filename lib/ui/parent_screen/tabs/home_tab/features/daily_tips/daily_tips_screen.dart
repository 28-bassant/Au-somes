import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_tips/widgets/article_card.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_tips/widgets/behavioural_tips_widget.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_tips/widgets/communication_tips_widget.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_tips/widgets/sensory_tips_widget.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_tips/widgets/tip_header.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_tips/widgets/tip_section.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../../../../utils/app_colors.dart';

class DailyTipsScreen extends StatelessWidget {
  const DailyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          toolbarHeight: height*.07,
          backgroundColor: AppColors.lightPastelBlue,
          shape:RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          title:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  AppLocalizations.of(context)!.daily_tips,
                  style: AppStyles.bold22Black
              ),
              SizedBox(height: 4),
              Text(
                  AppLocalizations.of(context)!.helpful_tips,
                  style:AppStyles.regular14BlackWithOpacity60
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: height*.02,),
            TabBar(
              isScrollable: true,
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.symmetric(horizontal:  width*.05),
              indicatorPadding: EdgeInsets.symmetric(vertical: height*.004),
              indicator: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(18),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.whiteColor,
              unselectedLabelColor: AppColors.softBlue,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs:  [
                Tab(text: AppLocalizations.of(context)!.all_tips),
                Tab(text: AppLocalizations.of(context)!.sensory),
                Tab(text: AppLocalizations.of(context)!.communication),
                Tab(text: AppLocalizations.of(context)!.behavioural),
              ],
            ),
            SizedBox(height: height * .02,),
            Expanded(
              child: Builder(
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(left: width*.04,right:width*.04,bottom: height*.03 ),
                    child: TabBarView(
                      children: [
                        _allTips(context),
                         SensoryTipsWidget(),
                         CommunicationTipsWidget(),
                        BehaviouralTipsWidget()


                      ],
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _allTips(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          Text(AppLocalizations.of(context)!.featured_article,style: AppStyles.bold14Black,),
          ArticleCard(),
          TipHeader(
            title: AppLocalizations.of(context)!.sensory_tips,
            onViewAll: () {
              final tabController = DefaultTabController.of(context);
              tabController?.animateTo(1);
            },
          ),
           SizedBox(height: 8),
           TipSection(
            iconPath: AppAssets.sensoryIcon,
            title: AppLocalizations.of(context)!.general_sensory_tip_title,
            description:AppLocalizations.of(context)!.general_sensory_tip_description,

               content:[
                 {
                   'text' :  '${AppLocalizations.of(context)!.general_sensory_tip_title1}\n'
                       '${AppLocalizations.of(context)!.general_sensory_tip_title2}\n'
                       '${AppLocalizations.of(context)!.general_sensory_tip_title3}\n'
                       '${AppLocalizations.of(context)!.general_sensory_tip_title4}',
                 }
               ],
            backgroundColor:AppColors.mintGreen
          ),
         SizedBox(height: 12),

          TipHeader(
            title: AppLocalizations.of(context)!.communication_tips,
            onViewAll: () {
              final tabController = DefaultTabController.of(context);
              tabController?.animateTo(2);
            },
          ),
          SizedBox(height: 8),
           TipSection(
            iconPath: AppAssets.communicationIcon,
               title: AppLocalizations.of(context)!.general_communication_tip_title,
               description:AppLocalizations.of(context)!.general_communication_tip_description,

               content:[
                 {
                   'text' :  '${AppLocalizations.of(context)!.general_communication_tip_title1}\n'
                       '${AppLocalizations.of(context)!.general_communication_tip_title2}\n'
                       '${AppLocalizations.of(context)!.general_communication_tip_title3}\n'
                       '${AppLocalizations.of(context)!.general_communication_tip_title4}',
                 }
               ],
            backgroundColor: AppColors.softBlue
          ),
          SizedBox(height: 12),
          TipHeader(
            title: AppLocalizations.of(context)!.behavioural_tips,
            onViewAll: () {
              final tabController = DefaultTabController.of(context);
              tabController?.animateTo(3);
            },
          ),
           SizedBox(height: 8),
          TipSection(
            iconPath: AppAssets.behaviorIcon,
              title: AppLocalizations.of(context)!.general_behavioural_tip_title,
              description:AppLocalizations.of(context)!.general_behavioural_tip_description,

              content:[
                {
                  'text' :  '${AppLocalizations.of(context)!.general_behavioural_tip_title1}\n'
                      '${AppLocalizations.of(context)!.general_behavioural_tip_title2}\n'
                      '${AppLocalizations.of(context)!.general_behavioural_tip_title3}\n'
                      '${AppLocalizations.of(context)!.general_behavioural_tip_title4}',
                }
              ],
            backgroundColor:AppColors.lightPastelBlue
          ),



        ],
      ),
    );
  }
}

