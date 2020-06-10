import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../auth.dart';
import '../../../providers/water-povider.dart';
import '../../../exceptions/http_exception.dart';
import '../../../widgets/dialog.dart' as dialog;
import '../../../models/water.dart';
import '../water-supply-daily.dart';

class WaterDailySummary extends StatefulWidget {
  final Water _water;
  final DateFormat _formatter;
  final bool _showHistory;

  WaterDailySummary(this._water, this._formatter, [this._showHistory]);

  @override
  _WaterDailySummaryState createState() => _WaterDailySummaryState();
}

class _WaterDailySummaryState extends State<WaterDailySummary> {
  void removeRecord(context) async {
    try {
      bool confirmed = await dialog.Dialog(
        'Are you sure?',
        'The item will be deleted',
        {
          'Yes': () {
            Navigator.of(context).pop(true);
          },
          'No': () {
            Navigator.of(context).pop(false);
          }
        },
      ).show(context);

      if (confirmed) {
        Provider.of<WaterProvider>(context, listen: false)
            .removeWaterRecord(widget._water);
      }
    } on HttpException catch (error) {
      dialog.Dialog(
        'An Error Occurred!',
        error.message,
        {
          'Okay': () {
            Navigator.of(context).pop();
            if (error.status == 403) {
              Navigator.of(context).popAndPushNamed(AuthScreen.routeName);
            }
          }
        },
      ).show(context);
    }
  }

  void showRemoveMenu(details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    showMenu(
      position: RelativeRect.fromRect(
        details.globalPosition & Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 0,
          child: Row(
            children: <Widget>[
              Icon(Icons.delete),
              Text("Delete"),
            ],
          ),
        )
      ],
      context: context,
    ).then((value) {
      if (value == 0) {
        removeRecord(context);
      }
    });
  }

  void showHistory() {
    Navigator.pushNamed(
      context,
      WaterSupplyDailyScreen.routeName,
      arguments: {'date': widget._water.date},
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget._showHistory ? showHistory : null,
      onLongPressStart: widget._showHistory ? null : showRemoveMenu,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.3,
              ),
            ),
          ),
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
      ),
    );
  }
}
