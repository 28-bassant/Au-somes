import 'package:au_somes/ui/parent_screen/tabs/home_tab/features/daily_tips/widgets/article_card.dart';
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
                  'Daily Tips',
                  style: AppStyles.bold22Black
              ),
              SizedBox(height: 4),
              Text(
                  'Helpful tips for today',
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
              tabs: const [
                Tab(text: 'All Tips'),
                Tab(text: 'Sensory'),
                Tab(text: 'Communication'),
                Tab(text: 'Behavioural'),
              ],
            ),

            Expanded(
              child: Builder(
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(left: width*.04,right:width*.04,bottom: height*.03 ),
                    child: TabBarView(
                      children: [
                        _allTips(context),
                        const Center(child: Text('Sensory Tips')),
                        const Center(child: Text('Communication Tips')),
                        const Center(child: Text('Behavioural Tips')),


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
          Text("Featured Article",style: AppStyles.bold14Black,),
          ArticleCard(),
          TipHeader(
            title: 'Sensory Tips',
            onViewAll: () {
              final tabController = DefaultTabController.of(context);
              tabController?.animateTo(1);
            },
          ),
           SizedBox(height: 8),
           TipSection(
            iconPath: AppAssets.sensoryIcon,
            title: 'Supporting Sensory Needs',
            description:
            'Many children with autism are sensitive to sound, light, touch, or textures.',
            content:
            '• Create a quiet, safe space at home.\n'
                '• Allow headphones if noise is stressful.\n'
                '• Respect food texture preferences.\n'
                '• Introduce new sensations slowly.',
            backgroundColor:AppColors.mintGreen
          ),
         SizedBox(height: 12),

          TipHeader(
            title: 'Communication Tips',
            onViewAll: () {
              final tabController = DefaultTabController.of(context);
              tabController?.animateTo(2);
            },
          ),
          SizedBox(height: 8),
           TipSection(
            iconPath: AppAssets.communicationIcon,
            title: 'Supporting Communication',
            description:
            'Children with autism may communicate in different ways including words or gestures.',
            content:
            '• Get your child’s attention before speaking.\n'
                '• Speak slowly and clearly.\n'
                '• Use consistent words.\n'
                '• Allow extra time to respond.',
            backgroundColor: AppColors.softBlue
          ),
          SizedBox(height: 12),
          TipHeader(
            title: 'Behavioral Tips',
            onViewAll: () {
              final tabController = DefaultTabController.of(context);
              tabController?.animateTo(3);
            },
          ),
           SizedBox(height: 8),
          TipSection(
            iconPath: AppAssets.behaviorIcon,
            title: 'Understanding Behaviour',
            description:
            'Behaviour is a form of communication for children with autism. Challenging behaviour often means the child is feeling overwhelmed, confused, or unable to express needs.',
            content:
            '• Observe behaviour patterns carefully.\n'
                '• Look for reasons behind the behaviour.\n'
                '•Remember that behaviour is not intentional misbehaviour.\n'
                '• Focus on understanding, not punishment.',
            backgroundColor:AppColors.lightPastelBlue
          ),



        ],
      ),
    );
  }
}

