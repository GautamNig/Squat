import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:squat/pages/squats.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: squatsRef.snapshots(),
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
          // List<Squat> squats = [];

          var newMap = groupBy(
              snapshot.data!.docs,
              (DocumentSnapshot<Object?> obj) =>
                  Squat.fromDocument(obj).country);

          newMap.forEach((key, value) {
            squatDataList.add(SquatData(key, value.length));
          });

          return SfCircularChart(
              title: ChartTitle(text: 'Squats by Country', textStyle: const TextStyle(fontFamily: "Signatra",
                fontSize: 30,)),
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
                    xValueMapper: (SquatData sales, _) => sales.country,
                    yValueMapper: (SquatData sales, _) => sales.squats,
                    dataLabelSettings: const DataLabelSettings(isVisible : true, textStyle: TextStyle(fontFamily: "Signatra",
                      fontSize: 18,),)
                )
              ]);
        });
  }
}

class SquatData {
  SquatData(this.country, this.squats);

  final String country;
  final int squats;
}
