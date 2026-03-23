
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_styles.dart';

class DialogUtils{

  static void showLoading({required String textLoading,required BuildContext context}){
    showDialog(barrierDismissible: false,
      context: context, builder: (context) =>
          AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: AppColors.softBlue,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(textLoading,style: AppStyles.medium20BlackWithOpacity60,),
                )
              ],
            ),
          )
      ,);
  }
  static void hideLoading({required BuildContext context}){
    Navigator.pop(context);

  }

  static void showMsg({required BuildContext context,
    required String msg,String? title,String? posActionName,
    Function? posAction,String? negActionName,Function? negAction,bool barrierDismissible= true }){
    List<Widget>? actions=[];
    if(posActionName != null){
      actions.add(TextButton(onPressed: (){
        Navigator.pop(context);
        posAction?.call();
      }, child: Text(posActionName,style:AppStyles.bold24SoftBlue,)));

    }
    if(negActionName !=null){
      actions.add(TextButton(onPressed: (){
        Navigator.pop(context);
        negAction?.call();
      }, child: Text(negActionName,style:AppStyles.medium16Red ,)));
    }
    if (actions.isEmpty) {
      actions.add(
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("OK", style: AppStyles.bold20BlackWithOpacity60),
        ),
      );
    }

    showDialog(barrierDismissible: barrierDismissible,
        context: context, builder: (context) => AlertDialog(
          content: Text(msg,style: AppStyles.medium20BlackWithOpacity60,),
          title: Text(title??'',style: AppStyles.bold20BlackWithOpacity60,),
          actions: actions,
        ));
  }
}