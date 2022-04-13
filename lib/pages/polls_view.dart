import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:smart_select/smart_select.dart';
import 'package:squat/pages/home.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../helpers/Constants.dart';
import '../models/poll.dart';
import '../widgets/header.dart';
import '../widgets/progress.dart';
import 'create_poll.dart';

class PollView extends StatefulWidget {
  // final Poll poll;
  //
  // PollView({required this.poll}) : super();
  @override
  _PollViewState createState() => _PollViewState();
}

class _PollViewState extends State<PollView> {
  String _selectedPoll = '';
  List<DocumentSnapshot> documents = [];
  late TooltipBehavior _tooltip;
  late List<_ChartData> chartData;
  late Map<String, List<dynamic>> groupedData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tooltip = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: OpenContainer(
        openColor: Colors.teal,
        closedColor: Colors.teal,
        transitionType: ContainerTransitionType.fade,
        transitionDuration: const Duration(milliseconds: 1100),
        openBuilder: (_, closeContainer) {
          return CreatePoll();
        },
        closedBuilder: (_, openContainer) {
          return FloatingActionButton(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0))),
            backgroundColor: Constants.appColor,
            foregroundColor: Colors.white,
            onPressed: openContainer,
            child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
          );
        },
      ),
      appBar: header(context, titleText: 'Polls'),
      body: StreamBuilder(
          stream: pollsRef.snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            List<Column> polls = [];

            documents = snapshot.data.docs;

            if (documents.isEmpty) {
              return Image.asset('assets/images/notfound.png',
                  fit: BoxFit.fill);
            }

            documents.forEach((doc) {
              var poll = Poll.fromDocument(doc);
              if(poll.voters.keys.contains(currentUser.id)){
                _selectedPoll = poll.options![poll.voters[currentUser.id]];
              }

              polls.add(Column(
                children: <Widget>[
                  const SizedBox(height: 7),
                  SmartSelect<String>.single(
                    title: poll.pollTitle,
                    value: _selectedPoll,
                    choiceItems: S2Choice.listFrom(
                      source: poll.options,
                      value: (index, item) => poll.options![index],
                      title: (index, item) => poll.options![index],
                      disabled: (index, item) =>
                          poll.voters.keys.contains(currentUser.id),
                      // group: (index, item) => item.keys.first,
                    ),
                    onChange: (selected) => setState(() {
                      _selectedPoll = selected.value;

                      if (!poll.voters.keys.contains(currentUser.id) &&
                          poll.options!.contains(_selectedPoll)) {
                        pollsRef.doc(poll.pollId).update({
                          'voters.${currentUser.id}':
                              poll.options!.indexOf(_selectedPoll)
                        }).then((value)  {
                          groupedData =
                                    groupBy(poll.voters.values, (dynamic obj) => obj.toString());

                          chartData = groupedData.values.map((e) => _ChartData(poll.options![e.first],
                                  (e.length/poll.voters.length)*100)).toList();
                          
                              showAlert(chartData);
                            });
                      }else{
                        groupedData =
                            groupBy(poll.voters.values, (dynamic obj) => obj.toString());

                        chartData = groupedData.values.map((e) => _ChartData(poll.options![e.first],
                            (e.length/poll.voters.length)*100)).toList();
                              showAlert(chartData);
                      }
                    }),
                  ),
                  const Divider(indent: 20),
                ],
              ));
            });

            return Column(
              children: polls,
            );
          }),
    );
  }

  void showAlert(List<_ChartData> chartData) {
    Alert(
        context: context,
        title: "Poll Stat",
        content: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 100,
                interval: 5),
            tooltipBehavior: _tooltip,
            series: <ChartSeries<_ChartData, String>>[
              ColumnSeries<_ChartData, String>(
                  dataSource: chartData,
                  xValueMapper:
                      (_ChartData data, _) => data.x,
                  yValueMapper:
                      (_ChartData data, _) => data.y,
                  name: 'Vote %',
                  color: Constants.appColor)
            ]),
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Ok",
              style: TextStyle(
                  color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
