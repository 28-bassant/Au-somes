import 'package:au_somes/ui/parent_screen/tabs/home_tab/widgets/image_slide_show_widget.dart';
import 'package:au_somes/utils/app_assets.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';

class HomeTab extends StatefulWidget{
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'image': AppAssets.askChatbotImage,
        'title': AppLocalizations.of(context)!.ask_chatbot,
        'route':AppRoutes.chatbotScreenRouteName
      },
      {
        'image':AppAssets.progressImage,
        'title': AppLocalizations.of(context)!.progress_level,
        'route':AppRoutes.progressLevelScreenRouteName
      },
      {
        'image': AppAssets.dailyTipsImage,
        'title': AppLocalizations.of(context)!.daily_tips,
        'route':AppRoutes.dailyTipsScreenRouteName
      },
      {
        'image': AppAssets.dailyRoutineImage,
        'title': AppLocalizations.of(context)!.daily_routine,
        'route':AppRoutes.dailyRoutineScreenRouteName
      },
    ];
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.lightPastelBlue,
          elevation: 0,
          iconTheme: IconThemeData(
              color: AppColors.blackColor
          ),
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.caring_for_my_child,style: AppStyles.bold22Black,)
      ),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: width * .04,vertical: 0),
        child: Column(
          children: [
            ImageSlideShowWidget(),
            SizedBox(height: height*.02,),
            Expanded(
              child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: (){
                        Navigator.pushNamed(context, items[index]['route']);
                      },
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Image.asset(
                                items[index]['image']!,
                                width: double.infinity,
                                height:  double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: height*.002),
                            Text(
                              items[index]['title']!,
                              style: AppStyles.bold14Black
                            )]),
                    );
                  }
              ),
            )],
        ),
      ),

    );
  }
}