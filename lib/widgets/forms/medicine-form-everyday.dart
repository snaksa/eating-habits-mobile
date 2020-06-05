import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../screens/auth.dart';
import '../../providers/medicine-provider.dart';
import '../../models/medicine.dart';
import '../../widgets/dialog.dart' as dialog;
import '../../models/medicine-schedule.dart';
import '../../exceptions/http_exception.dart';

class MedicineFormEveryday extends StatefulWidget {
  final List<MedicineSchedule> schedule;
  final Medicine medicine;

  MedicineFormEveryday({this.schedule, this.medicine});

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
          Text(
            'Schedule',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            direction: Axis.horizontal,
            children: <Widget>[
              ...widget.schedule.map((MedicineSchedule schedule) {
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
                            children: <Widget>[
                              Icon(Icons.delete),
                              Text("Delete"),
                            ],
                          ),
                        )
                      ],
                      context: context,
                    ).then((value) => removeRecord(schedule));
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8, top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      DateFormat.Hm().format(schedule.intakeTime),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
              GestureDetector(
                onTap: chooseTime,
                child: Container(
                  margin: EdgeInsets.only(right: 8, top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Text(
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
