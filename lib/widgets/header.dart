import 'package:flutter/material.dart';
import '../helpers/Constants.dart';
AppBar header(context,
    {required String titleText, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
     titleText,
      style: Constants.appHeaderTextSTyle,
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).colorScheme.secondary,
  );
}

class Constant {
}
