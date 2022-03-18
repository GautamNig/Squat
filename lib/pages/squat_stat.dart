import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:squat/pages/squatters.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../helpers/Constants.dart';
import '../models/user.dart';
import '../widgets/progress.dart';
import 'Home.dart';

class SquatStat extends StatefulWidget {
  const SquatStat({Key? key}) : super(key: key);

  @override
  State<SquatStat> createState() => _SquatStatState();
}

class _SquatStatState extends State<SquatStat> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersRef.snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) return circularProgress();
          // return GroupedListView<dynamic, String>(
          //   elements: snapshot.data.docs,
          //   groupBy: (element) => element!['country'],
          //   groupSeparatorBuilder: (String groupByValue) => Text(groupByValue),
          //   itemBuilder: (context, obj) => Text(obj.toString()),
          //   order: GroupedListOrder.ASC,
          // );

          List<SquatData> squatDataList = [];

          var newMap = groupBy(
              snapshot.data!.docs,
              (DocumentSnapshot obj) => User.fromDocument(obj).country);

          newMap.forEach((key, value) {
            squatDataList.add(SquatData(key.toString(), value.length));
          });

          squatDataList.sort((a, b) => b.squaters.compareTo(a.squaters));

          if (squatDataList.length > 5) {
            squatDataList = squatDataList.take(5).toList();
          }

          return SfCircularChart(
              title: ChartTitle(
                  text: 'Squatters by Country',
                  textStyle: const TextStyle(
                      fontFamily: "Signatra",
                      fontSize: 30,
                      color: Constants.appColor
                  )),
              legend: Legend(isVisible: true),
              // Initialize category axis
              series: <CircularSeries>[
                PieSeries<SquatData, String>(
                    // Bind data source
                    //   dataSource:  <SquatData>[
                    //     SquatData('Jan', 35),
                    //     SquatData('Feb', 28),
                    //     SquatData('Mar', 34),
                    //     SquatData('Apr', 32),
                    //     SquatData('May', 40)
                    //   ],
                    dataSource: squatDataList,
                    xValueMapper: (SquatData sales, _) => sales.country.toString(),
                    yValueMapper: (SquatData sales, _) => sales.squaters,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: Constants.appHeaderTextSTyle,
                    ))
              ]);
        });
  }
}

class SquatData {
  SquatData(this.country, this.squaters);

  final String country;
  final int squaters;
}
