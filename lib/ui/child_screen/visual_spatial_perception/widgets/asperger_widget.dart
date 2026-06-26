import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:au_somes/utils/dialog_utils.dart';
import 'package:flutter/material.dart';

class AspergerWidget {
  void aspergerFun(
      BuildContext context, {
        VoidCallback? onSkip,
        VoidCallback? onOk,
        String? msg
      }) {
    DialogUtils.showMsg(
      context: context,
      msg:msg?? AppLocalizations.of(context)!.asperger,
      posActionName: AppLocalizations.of(context)!.ok,
      negActionName: AppLocalizations.of(context)!.skip,
      postActionStyle: AppStyles.bold16SoftBlue,
      negActionStyle: AppStyles.medium16Red,
      msgStyle: AppStyles.bold20BlackWithOpacity60,

     posAction: (){
        onOk?.call();
     },

      // Skip → ينفذ اللي انتي بعتاه
      negAction: () {
        onSkip?.call();
      },
    );
  }
}
