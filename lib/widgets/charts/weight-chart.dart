import 'package:charts_flutter/flutter.dart' as charts;
import '../../models/weight.dart';
import 'package:flutter/material.dart';

class WeightSeries {
  final DateTime time;
  final double weight;

  WeightSeries(this.time, this.weight);
}

class WeightChart extends StatelessWidget {
  final List<Weight> weightRecords;

  WeightChart(this.weightRecords);

  double get minWeight {
    double min = double.maxFinite;

    weightRecords.forEach((weight) {
      if (weight.weight < min) {
        min = weight.weight;
      }
    });

    return min.floor() - 1.0;
  }

  double get maxWeight {
    double max = double.minPositive;

    weightRecords.forEach((weight) {
      if (weight.weight > max) {
        max = weight.weight;
      }
    });

    return max.ceil() + 1.0;
  }

  List<charts.Series<WeightSeries, DateTime>> get seriesList {
    final data =
        weightRecords.map((w) => WeightSeries(w.date, w.weight)).toList();

    return [
      new charts.Series<WeightSeries, DateTime>(
        id: 'Weight',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (WeightSeries weight, _) => weight.time,
        measureFn: (WeightSeries weight, _) => weight.weight,
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
          child: new charts.TimeSeriesChart(
            seriesList,
            animate: true,
            dateTimeFactory: const charts.LocalDateTimeFactory(),
            primaryMeasureAxis: charts.NumericAxisSpec(
              tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                zeroBound: false,
                dataIsInWholeNumbers: false,
                desiredMinTickCount: 5,
              ),
              tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                (value) => value.toStringAsFixed(1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
