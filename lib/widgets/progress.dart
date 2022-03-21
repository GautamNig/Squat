import 'package:flutter/material.dart';

import '../helpers/Constants.dart';

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 10),
    child: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Constants.appColor),
    ),
  );
}

Container linearProgress() {
  return Container(
    padding: const EdgeInsets.only(bottom: 10),
    child: const LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Constants.appColor),
    ),
  );
}
