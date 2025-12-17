import 'package:au_somes/custom_widgets/custom_language_widget.dart';
import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/ui/parent_screen/tabs/home_tab/home_tab.dart';
import 'package:au_somes/ui/parent_screen/tabs/notification_tab/notification_tab.dart';
import 'package:au_somes/ui/parent_screen/tabs/profile_tab/profile_tap.dart';
import 'package:au_somes/ui/parent_screen/tabs/search_tab/search_tab.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/material.dart';

import '../../utils/app_assets.dart';

class ParentScreen extends StatefulWidget{
  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  List<Widget> tabs =
  [HomeTab(),
  NotificationTab(),
  SearchTab(),
  ProfileTab()];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title:selectedIndex==0? Text(AppLocalizations.of(context)!.caring_for_my_child,style: AppStyles.bold24SoftBlue,):null,
        centerTitle: true,
        actions: [
          CustomLanguageWidget(),
          SizedBox(width: width * .02,)
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(
          horizontal: width * .02,
          vertical: height * .027,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: AppColors.softBlue,
            width: 3
          )
        ),
        height: height * .066,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavIcon(
                selectedIconName: AppAssets.selected_home_icon,
                unSelectedIconName: AppAssets.unselected_home_icon,
                index: 0),
            buildNavIcon(
                selectedIconName: AppAssets.selected_notification_icon,
                unSelectedIconName: AppAssets.unselected_notification_icon,
                index: 1),
            buildNavIcon(
                selectedIconName: AppAssets.selected_search_icon,
                unSelectedIconName: AppAssets.unselected_search_icon,
                index: 2),
            buildNavIcon(
                selectedIconName: AppAssets.selected_profile_icon,
                unSelectedIconName: AppAssets.unselected_profile_icon,
                index: 3),
          ],
        ),
      ),
      body: tabs[selectedIndex],
    );
  }

  Widget buildNavIcon({
    required String selectedIconName,
    required String unSelectedIconName,
    required int index,
  }) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ImageIcon(
          //   AssetImage(isSelected ? selectedIconName : unSelectedIconName),
          //   size: 24,
          //   color: isSelected ? AppColors.softBlue : AppColors.whiteColor,
          // ),
          Image(image: AssetImage(isSelected ? selectedIconName : unSelectedIconName))
        ],
      ),
    );
  }
}
