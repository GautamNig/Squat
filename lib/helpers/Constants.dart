import 'package:flutter/material.dart';

class Constants {
  static const Color appColor = Colors.teal;
  static const TextStyle appHeaderTextSTyle = TextStyle(
      fontFamily: "Signatra",
      fontSize: 30,
      color: Colors.white
  );

  static Align createAttributionAlignWidget(
      String text, {AlignmentGeometry alignmentGeometry = Alignment.bottomCenter}) {
    return Align(
      alignment: alignmentGeometry,
      child: Text(
        text,
        style: const TextStyle(fontSize: 8),
      ),
    );
  }
}
