import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../auth.dart';
import '../../../providers/medicine-provider.dart';
import '../../../exceptions/http_exception.dart';
import '../../../models/medicine.dart';
import '../../../models/medicine-schedule.dart';
import '../../../widgets/dialog.dart' as dialog;

class MedicineFormEveryday extends StatefulWidget {
  final Medicine medicine;

  MedicineFormEveryday({this.medicine});

  @override
  _MedicineFormEverydayState createState() => _MedicineFormEverydayState();
}

class _MedicineFormEverydayState extends State<MedicineFormEveryday> {
  void chooseTime() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    ).then((picked) {
      addRecord(picked);
    });
  }

  Future<void> addRecord(TimeOfDay picked) async {
    var now = DateTime.now();
    var date =
        DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

    MedicineSchedule medicineSchedule = MedicineSchedule(
      intakeTime: date.toUtc(),
    );

    try {
      await Provider.of<MedicineProvider>(context, listen: false)
          .addScheduleRecord(medicineSchedule, widget.medicine);
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

  Future<void> removeRecord(MedicineSchedule schedule) async {
    try {
      await Provider.of<MedicineProvider>(context, listen: false)
          .removeScheduleRecord(schedule);
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: <Widget>[
          const Text(
            'Schedule',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            direction: Axis.horizontal,
            children: <Widget>[
              ...widget.medicine.schedule.map((MedicineSchedule schedule) {
                return GestureDetector(
                  onLongPressStart: (LongPressStartDetails details) {
                    final RenderBox overlay =
                        Overlay.of(context).context.findRenderObject();

                    showMenu(
                      position: RelativeRect.fromRect(
                        details.globalPosition & Size(40, 40),
                        Offset.zero & overlay.size,
                      ),
                      items: <PopupMenuEntry>[
                        PopupMenuItem(
                          value: 0,
                          child: Row(
                            children: const <Widget>[
                              Icon(Icons.delete),
                              Text("Delete"),
                            ],
                          ),
                        )
                      ],
                      context: context,
                    ).then((value) {
                      if (value == 0) {
                        removeRecord(schedule);
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8, top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      DateFormat.Hm().format(schedule.intakeTime),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
              GestureDetector(
                onTap: chooseTime,
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Text(
                    '+ Add',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
