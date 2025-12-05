import 'package:flutter/material.dart';

class SelectingBoxWidget extends StatelessWidget {
  final String image;
  final String text;
  final TextStyle textStyle;
  final VoidCallback onTapFunction;

  SelectingBoxWidget({
    required this.image,
    required this.text,
    required this.textStyle,
    required this.onTapFunction,
  });

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onTapFunction,
      child: Container(
        child: Column(
          children: [
            Image(image: AssetImage(image)),
            SizedBox(height: height * .01),
            Text(text, style: textStyle),
          ],
        ),
      ),
    );
  }
}
