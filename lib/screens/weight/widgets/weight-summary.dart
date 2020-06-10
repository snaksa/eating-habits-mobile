import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../exceptions/http_exception.dart';
import '../../../providers/weight-provider.dart';
import '../../../screens/auth.dart';
import '../../../widgets/dialog.dart' as dialog;
import '../../../models/weight.dart';

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
        Provider.of<WeightProvider>(context, listen: false)
            .removeWeightRecord(widget.weight.id);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: showRemoveMenu,
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
                        fontSize:
                            Theme.of(context).textTheme.headline6.fontSize,
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
      ),
    );
  }
}
