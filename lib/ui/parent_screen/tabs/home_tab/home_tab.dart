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
        'image':AppAssets.dailyTipsImage,
        'title': AppLocalizations.of(context)!.daily_tips,
        'route':AppRoutes.dailyRoutineScreenRouteName
      },
      {
        'image': AppAssets.progressImage,
        'title': AppLocalizations.of(context)!.progress_level,
        'route':AppRoutes.progressLevelScreenRouteName
      },
      {
        'image': AppAssets.stories_time_image,
        'title': AppLocalizations.of(context)!.stories_time,
        'route':AppRoutes.storiesTimeScreenRouteName
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
     body: SingleChildScrollView(
    child: Padding(
    padding: EdgeInsets.symmetric(horizontal: width * .04),
    child: Column(
    children: [
    ImageSlideShowWidget(),
    SizedBox(height: height * .02),

    GridView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: items.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 0.8,
    ),
    itemBuilder: (context, index) {
    return InkWell(
    onTap: () {
    Navigator.pushNamed(context, items[index]['route']);
    },
    child: Column(
    children: [
    Expanded(
    child: Image.asset(
    items[index]['image']!,
    fit: BoxFit.contain,
    ),
    ),
    SizedBox(height: height * .002),
    Text(items[index]['title']!,
    style: AppStyles.bold14Black),
    ],
    ),
    );
    },
    ),

    SizedBox(height: height * .02),

    InkWell(
    onTap: () {
    Navigator.pushNamed(
    context, AppRoutes.dailyRoutineScreenRouteName);
    },
    child: Column(
    children: [
    Image.asset(
    AppAssets.dailyRoutineImage,
    fit: BoxFit.contain,
    ),
    Text(AppLocalizations.of(context)!.daily_routine,
    style: AppStyles.bold14Black),
    ],
    ),
    ),
    ],
    ),
    ),
    ),

    );
  }
}

