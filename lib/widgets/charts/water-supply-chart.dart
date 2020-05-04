import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/water.dart';

class WaterSeries {
  final DateTime date;
  final double amount;

  WaterSeries(this.date, this.amount);
}

class WaterSupplyChart extends StatelessWidget {
  final List<Water> waterRecords = [
    Water(date: DateTime(2020, 4, 1), amount: 3500),
    Water(date: DateTime(2020, 4, 2), amount: 4500),
    Water(date: DateTime(2020, 4, 3), amount: 5000),
    Water(date: DateTime(2020, 4, 4), amount: 2000),
    Water(date: DateTime(2020, 4, 5), amount: 2500),
    Water(date: DateTime(2020, 4, 6), amount: 4500),
    Water(date: DateTime(2020, 4, 7), amount: 4000),
  ];

  WaterSupplyChart();

  List<charts.Series<WaterSeries, String>> get seriesList {
    final data =
        waterRecords.map((w) => WaterSeries(w.date, w.amount)).toList();

    return [
      new charts.Series<WaterSeries, String>(
        id: 'Water',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (WaterSeries water, _) => DateFormat.Md().format(water.date),
        measureFn: (WaterSeries water, _) => water.amount,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              Text(
                'Last 7 days',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: new charts.BarChart(
                  seriesList,
                  animate: true,
                  primaryMeasureAxis: charts.NumericAxisSpec(
                    tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                      dataIsInWholeNumbers: false,
                      desiredMinTickCount: 5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
