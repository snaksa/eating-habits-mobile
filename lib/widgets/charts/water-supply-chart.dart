import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../models/water.dart';

class WaterSeries {
  final DateTime date;
  final int amount;

  WaterSeries(this.date, this.amount);
}

class WaterSupplyChart extends StatelessWidget {
  final List<Water> waters;

  WaterSupplyChart(this.waters);

  List<Water> get waterRecords {
    final records = [...this.waters];
    records.sort((Water a, Water b) => a.date.compareTo(b.date));

    return records;
  }

  List<charts.Series<WaterSeries, String>> get seriesList {
    final data =
        waterRecords.map((w) => WaterSeries(w.date, w.amount)).toList();

    return [
      new charts.Series<WaterSeries, String>(
        id: 'Water',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (WaterSeries water, _) => DateFormat.Md().format(water.date.toLocal()),
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
