import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/water.dart';

class WaterDailySummary extends StatefulWidget {
  final Water _water;
  final DateFormat _formatter;

  WaterDailySummary(this._water, this._formatter);

  @override
  _WaterDailySummaryState createState() => _WaterDailySummaryState();
}

class _WaterDailySummaryState extends State<WaterDailySummary> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  const Icon(Icons.access_time),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget._formatter.format(widget._water.date.toLocal()),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                '${widget._water.amount.toStringAsFixed(0)} ml',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
