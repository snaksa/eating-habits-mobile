import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../models/water.dart';

class WaterSupplyScreen extends StatefulWidget {
  @override
  _WaterSupplyScreenState createState() => _WaterSupplyScreenState();
}

class _WaterSupplyScreenState extends State<WaterSupplyScreen> {
  final DateTime todayDate = DateTime(2020, 4, 2);
  final List<Water> weights = [
    Water(
      date: DateTime(2020, 4, 2, 9, 30),
      amount: 500,
    ),
    Water(
      date: DateTime(2020, 4, 2, 11, 30),
      amount: 1500,
    ),
    Water(
      date: DateTime(2020, 4, 2, 13, 0),
      amount: 250,
    ),
    Water(
      date: DateTime(2020, 4, 2, 15, 10),
      amount: 500,
    ),
  ];

  // void _addWeightRecord(Weight weight) {
  //   setState(() {
  //     weights.add(weight);
  //     weights.sort((Weight a, Weight b) => a.date.compareTo(b.date));
  //   });
  // }

  // void _deleteWeightRecord(Weight weight) {
  //   setState(() {
  //     weights.removeWhere((w) => w.id == weight.id);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final appBar = AppBar(
      title: Text(
        'Water Supply',
        style: TextStyle(color: Colors.white),
      ),
    );

    int current = 2500;
    int target = 5000;

    return Scaffold(
      appBar: appBar,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 0,
            left: 10,
            right: 10,
            bottom: 0,
          ),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                height:
                    (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) *
                        0.2,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 14,
                              ),
                              LinearPercentIndicator(
                                animation: true,
                                lineHeight: 20.0,
                                animationDuration: 500,
                                percent:
                                    current / target > 1 ? 1 : current / target,
                                center: Text('${current}ml of ${target}ml',
                                    style: TextStyle(color: Colors.white)),
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                progressColor: current / target < 0.3
                                    ? Colors.red.shade500
                                    : current / target < 0.7
                                        ? Colors.orange.shade900
                                        : current / target < 0.9
                                            ? Colors.lightGreen
                                            : Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height:
                    (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) *
                        0.8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
