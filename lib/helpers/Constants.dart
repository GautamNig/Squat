
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:squat/json_parsers/json_parser_firebase_appSettings.dart';

import '../json_parsers/json_parser_nytimes_articlesearch.dart';
import '../pages/Home.dart';

class Constants {
  static const Color appColor = Colors.teal;
  static const String nyTimesBaseUri = 'https://api.nytimes.com/svc/search/v2/articlesearch.json';
  static const String nyTimesBaseUriForImages = 'https://www.nytimes.com/';
  static late AppSettings appSettings;
  static const TextStyle appHeaderTextSTyle = TextStyle(
      fontFamily: "Signatra",
      fontSize: 30,
      color: Colors.white,
  );

  static createEventDetailscontainer(String text) {
    return Container(
      padding: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5.0)),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, overflow: TextOverflow.ellipsis),),);
  }

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

  static InputDecoration getTextFormFieldInputDecoration(String hintText) =>
      InputDecoration(
        hintText: hintText,
        hintStyle:
        const TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            width: 50,
            style: BorderStyle.solid,
          ),
        ),
        filled: true,
        contentPadding: const EdgeInsets.all(16),);

  static AutoSizeText getAutoSizeText(String text, { Color color = Constants.appColor,
    double fontSize = 20, int maxLines = 4, FontWeight fontWeight = FontWeight.normal}) =>
      AutoSizeText(
        text,
        style: TextStyle(fontSize: fontSize, color: color, fontStyle: FontStyle.italic, fontWeight: fontWeight),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
}
