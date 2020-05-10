import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/water.dart';

class WaterDailySummary extends StatefulWidget {
  final Water water;
  final Function deleteWaterRecord;

  WaterDailySummary(this.water, {this.deleteWaterRecord});

  @override
  _WaterDailySummaryState createState() => _WaterDailySummaryState();
}

class _WaterDailySummaryState extends State<WaterDailySummary> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showMenu(
          position: RelativeRect.fill,
          items: <PopupMenuEntry>[
            PopupMenuItem(
              value: 0,
              child: Row(
                children: <Widget>[
                  Icon(Icons.delete),
                  Text("Delete"),
                ],
              ),
            ),
          ],
          context: context,
        ).then((value) {
          if (value == 0) {
            widget.deleteWaterRecord(widget.water);
          }
        });
      },
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.access_time),
                    SizedBox(width: 10,),
                    Text(
                      DateFormat.Hm().format(widget.water.date),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  '${widget.water.amount.toStringAsFixed(0)} ml',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
