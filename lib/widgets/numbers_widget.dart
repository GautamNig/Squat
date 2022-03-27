import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user.dart';

class NumbersWidget extends StatelessWidget {
  final User user;
  NumbersWidget(this.user);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, DateFormat('dd/MM/yy').format(user.joiningDateTime.toDate()), 'Joined'),
          buildDivider(),
          buildButton(context, DateFormat('dd/MM/yy').format(user.lastSquatTime.toDate()), 'Last Squat'),
          // buildDivider(),
          // buildButton(context, '50', 'Followers'),
        ],
      );
  Widget buildDivider() => Container(
        height: 24,
        child: const VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}
