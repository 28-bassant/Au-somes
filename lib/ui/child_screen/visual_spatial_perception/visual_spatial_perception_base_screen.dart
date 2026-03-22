import 'package:flutter/material.dart';

import '../../../utils/app_routes.dart';

class VisualSpatialPerceptionBaseScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 70,),
          Row(
            children: [
              IconButton(onPressed: (){
                Navigator.pushNamed(context, AppRoutes.shapeAndShadowBaseActivityScreenRouteName);
              }, icon:Icon(Icons.add))
            ],
          )
        ],
      ),
    );
  }

}