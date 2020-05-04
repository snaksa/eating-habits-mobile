import 'package:eating_habits_mobile/widgets/water-daily-summary.dart';
import 'package:flutter/material.dart';
import '../../widgets/water-daily-stats.dart';
import '../../models/water.dart';

class WaterSupplyScreen extends StatefulWidget {
  @override
  _WaterSupplyScreenState createState() => _WaterSupplyScreenState();
}

class _WaterSupplyScreenState extends State<WaterSupplyScreen> {
  final DateTime todayDate = DateTime(2020, 4, 2);
  final List<Water> waters = [
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

  void _deleteWaterRecord(Water water) {
    setState(() {
      waters.removeWhere((w) => w.id == water.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final waterRecords = waters
        .where((Water water) =>
            water.date.day == todayDate.day &&
            water.date.month == todayDate.month &&
            water.date.year == todayDate.year)
        .toList();

    waterRecords.sort((Water a, Water b) => a.date.compareTo(b.date));

    final appBar = AppBar(
      title: Text(
        'Water Supply',
        style: TextStyle(color: Colors.white),
      ),
    );

    double current = 0;
    waterRecords.forEach((Water water) {
      current += water.amount;
    });
    
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
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topCenter,
                  height: (mediaQuery.size.height -
                          appBar.preferredSize.height -
                          mediaQuery.padding.top) *
                      0.2,
                  child: Column(
                    children: <Widget>[
                      WaterDailyStats(current: current, target: target),
                    ],
                  ),
                ),
                Container(
                  height: (mediaQuery.size.height -
                          appBar.preferredSize.height -
                          mediaQuery.padding.top) *
                      0.8,
                  child: ListView.builder(
                    itemCount: waterRecords.length,
                    itemBuilder: (BuildContext ctx, int index) {
                      return WaterDailySummary(waterRecords[index],
                          deleteWaterRecord: _deleteWaterRecord);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
