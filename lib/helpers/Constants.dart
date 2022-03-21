import 'package:flutter/material.dart';
import 'package:squat/json_parsers/json_parser_firebase_appSettings.dart';

class Constants {
  static const Color appColor = Colors.teal;
  static const String nyTimesBaseUri = 'https://api.nytimes.com/svc/search/v2/articlesearch.json';
  static late AppSettings appSettings;
  static const TextStyle appHeaderTextSTyle = TextStyle(
      fontFamily: "Signatra",
      fontSize: 30,
      color: Colors.white
  );

  static Align createAttributionAlignWidget(
      String text, {AlignmentGeometry alignmentGeometry = Alignment.bottomRight}) {
    return Align(
      alignment: alignmentGeometry,
      child: Text(
        text,
        style: const TextStyle(fontSize: 9),
      ),
    );
  }
}
