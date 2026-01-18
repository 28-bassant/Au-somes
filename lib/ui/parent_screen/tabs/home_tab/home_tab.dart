import 'package:au_somes/ui/parent_screen/tabs/home_tab/widgets/image_slide_show_widget.dart';
import 'package:au_somes/utils/app_routes.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';

class HomeTab extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
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
            TextButton(onPressed: (){
              Navigator.pushNamed(context, AppRoutes.chatbotScreenRouteName);
            }, child:Text("chatbot")),
            TextButton(onPressed: (){
              Navigator.pushNamed(context, AppRoutes.progressLevelScreenRouteName);
            }, child:Text("progress level"))
          ],
        ),
      ),
    );
  }
}