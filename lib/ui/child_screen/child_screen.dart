import 'package:au_somes/ui/child_screen/reinforcement_widgets/sound_helper.dart';
import 'package:au_somes/ui/child_screen/reinforcement_widgets/well_done_card.dart';
import 'package:au_somes/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChildScreen extends StatefulWidget{
  @override
  State<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
  bool showOverlay = false;

  @override
    Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('child screen'),
            iconTheme: IconThemeData(
              color: AppColors.softBlue,
            ),
          ),
          body:

          ElevatedButton(
            onPressed: showSuccess,
            child: const Text("Finish"),
          ),
        ),

        WellDoneCard(
          visible: showOverlay,
        ),
      ],
    );
  }

  void showSuccess() {
    setState(() => showOverlay = true);

    SoundHelper.playSuccess();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => showOverlay = false);
      }
    });
  }

}