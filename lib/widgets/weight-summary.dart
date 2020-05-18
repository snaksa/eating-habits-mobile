import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '.././models/weight.dart';

class WeightSummary extends StatefulWidget {
  final Weight weight;
  final double diff;
  final Function deleteWeightRecord;

  WeightSummary(this.weight, {this.diff, this.deleteWeightRecord});

  Color get color =>
      this.diff < 0 ? Colors.red : this.diff > 0 ? Colors.green : Colors.black;

  IconData get icon => this.diff < 0
      ? Icons.arrow_upward
      : this.diff > 0 ? Icons.arrow_downward : null;

  @override
  _WeightSummaryState createState() => _WeightSummaryState();
}

class _WeightSummaryState extends State<WeightSummary> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                DateFormat.yMMMd().format(widget.weight.date.toLocal()),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Expanded(
              child: Text(
                '${widget.weight.weight.toStringAsFixed(2)} kg',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${widget.diff.abs().toStringAsFixed(3)} kg',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline6.fontSize,
                      color: widget.color,
                    ),
                  ),
                  Icon(
                    widget.icon,
                    color: widget.color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
