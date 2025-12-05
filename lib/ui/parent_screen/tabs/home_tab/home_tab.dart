import 'package:au_somes/ui/parent_screen/tabs/home_tab/widgets/image_slide_show_widget.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: width * .04,vertical: 0),
        child: Column(
          children: [
            ImageSlideShowWidget()
          ],
        ),
      ),
    );
  }
}