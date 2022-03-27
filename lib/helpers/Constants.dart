import 'package:flutter/material.dart';
import 'package:squat/json_parsers/json_parser_firebase_appSettings.dart';

class Constants {
  static const Color appColor = Colors.teal;
  static const String nyTimesBaseUri = 'https://api.nytimes.com/svc/search/v2/articlesearch.json';
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
}
