import 'package:au_somes/utils/app_colors.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:flutter/cupertino.dart';

class NotificationItem extends StatelessWidget{
  String image;
  String text1;
  String text2;
  String text3;
  NotificationItem({required this.image,required this.text1
    ,required this.text2,required this.text3});
  
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * .02,
        vertical: height *.02
      ),
   decoration: BoxDecoration(
     color: AppColors.whiteColor,
     borderRadius: BorderRadius.circular(16),
     border: Border.all(
       color: AppColors.blackColorWithOpacity60,
       width: 1
     )

   ),      
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Image(image: AssetImage(image)),
            SizedBox(width: width*.03,),
            Text(text1,style: AppStyles.bold18Black,),
            Spacer(),
            Text(text2,style: AppStyles.regular14BlackWithOpacity60)
          ],),
          SizedBox(height: height*.01,),
          Text(text3,style: AppStyles.regular18BlackWithOpacity60)
        ],
      ),
    );

  }

}
