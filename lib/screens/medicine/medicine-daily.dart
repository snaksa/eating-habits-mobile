import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../auth.dart';
import '../../providers/medicine-provider.dart';
import '../../widgets/dialog.dart' as dialog;

class MedicineDailyScreen extends StatefulWidget {
  @override
  _MedicineDailyScreenState createState() => _MedicineDailyScreenState();
}

class _MedicineDailyScreenState extends State<MedicineDailyScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<MedicineProvider>(context).fetchScheduleRecords().then(
        (_) {
          setState(() {
            _isLoading = false;
          });
        },
      ).catchError((error) {
        dialog.Dialog('An error occured', error.message, {
          'Okay': () {
            Navigator.of(context).pop();
            if (error.status == 403) {
              Navigator.of(context).popAndPushNamed(AuthScreen.routeName);
            }
          },
        }).show(context);
      });
    }

    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          child: Consumer<MedicineProvider>(
            builder: (ctx, provider, _) {
              return _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    )
                  : provider.schedule.length <= 0
                      ? Center(
                          child: const Text('No medicine intake today'),
                        )
                      : Container(
                          height: double.infinity,
                          child: ListView.builder(
                            itemCount: provider.schedule.length,
                            itemBuilder: (BuildContext ctx, int index) {
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: Row(
                                            children: [
                                              Text(
                                                provider.schedule[index]
                                                    .medicine.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              const Icon(
                                                Icons.watch_later,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                DateFormat.Hm().format(provider
                                                    .schedule[index]
                                                    .intakeTime),
                                              ),
                                            ],
                                          ),
                                          RaisedButton(
                                            color: provider.schedule[index]
                                                        .isTaken !=
                                                    null
                                                ? Colors.green
                                                : Colors.grey,
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              if (provider.schedule[index]
                                                      .isTaken !=
                                                  null) {
                                                Provider.of<MedicineProvider>(
                                                  context,
                                                  listen: false,
                                                ).removeIntake(
                                                    provider.schedule[index]
                                                        .isTaken,
                                                    provider.schedule[index]);
                                              } else {
                                                Provider.of<MedicineProvider>(
                                                  context,
                                                  listen: false,
                                                ).addIntake(
                                                    provider.schedule[index]
                                                        .isTaken,
                                                    provider.schedule[index]);
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
            },
          ),
        ),
      ),
    );
  }
}
