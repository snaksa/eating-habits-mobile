import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/medicine-schedule.dart';
import './medicine-form-everyday.dart';
import '../../../models/medicine.dart';
import '../../../providers/medicine-provider.dart';
import '../../auth.dart';
import '../../../exceptions/http_exception.dart';
import '../../../widgets/dialog.dart' as dialog;
import '../../../constants/medicine-frequency.dart' as MedicineFrequency;

class MedicineForm extends StatefulWidget {
  static final String routeName = '/medicine-form';

  @override
  _MedicineFormState createState() => _MedicineFormState();
}

class _MedicineFormState extends State<MedicineForm> {
  bool _isLoading = false;
  bool _isDeletingLoading = false;
  final Map<String, dynamic> _formData = {
    'name': '',
    'frequency': MedicineFrequency.everyday,
    'date': DateTime.now(),
    'time': TimeOfDay.now(),
    'periodSpan': 2
  };
  final _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  void didChangeDependencies() {
    if (passedMedicine != null && !_isLoading) {
      _formData['name'] = passedMedicine.name;
      _formData['frequency'] = passedMedicine.frequency;

      if (passedMedicine.schedule.length > 0) {
        if (passedMedicine.frequency != MedicineFrequency.everyday) {
          MedicineSchedule schedule = passedMedicine.schedule.first;
          _formData['date'] = schedule.intakeTime;
          _formData['time'] = TimeOfDay.fromDateTime(schedule.intakeTime);

          dateController.text = DateFormat.yMMMd().format(_formData['date']);

          String minutes = _formData['time'].minute.toString();
          if (minutes.length < 2) {
            minutes = '0' + minutes;
          }
          timeController.text = "${_formData['time'].hour}:$minutes";

          if (passedMedicine.frequency == MedicineFrequency.period) {
            _formData['periodSpan'] =
                (schedule.periodSpan / (24 * 60 * 60)).floor();
          }
        }
      }
    }

    super.didChangeDependencies();
  }

  Medicine get passedMedicine {
    Map<String, Object> args = ModalRoute.of(context).settings.arguments;
    if (args != null && args['medicine'] != null) {
      return args['medicine'];
    }

    return null;
  }

  void chooseDate() {
    showDatePicker(
      context: context,
      initialDate: _formData['date'],
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((picked) {
      if (picked != null && picked != _formData['date']) {
        setState(() {
          _formData['date'] = picked;
          dateController.text = DateFormat.yMMMd().format(picked);
        });
      }
    });
  }

  void chooseTime() {
    showTimePicker(
      context: context,
      initialTime: _formData['time'],
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    ).then((picked) {
      if (picked != null && picked != _formData['time'])
        setState(() {
          _formData['time'] = picked;
          String minutes = picked.minute.toString();
          if (minutes.length < 2) {
            minutes = '0' + minutes;
          }
          timeController.text = "${picked.hour}:$minutes";
        });
    });
  }

  Future<void> addRecord() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    Medicine medicine = Medicine(
      id: passedMedicine != null ? passedMedicine.id : null,
      name: _formData['name'],
      frequency: _formData['frequency'],
    );

    try {
      setState(() {
        _isLoading = true;
      });
      Medicine record;
      if (medicine.id != null) {
        record = await Provider.of<MedicineProvider>(context, listen: false)
            .editMedicineRecord(medicine);

        if (medicine.frequency != MedicineFrequency.everyday) {
          var selectedDate = _formData['date'];
          TimeOfDay selectedTime = _formData['time'];

          var date = DateTime(selectedDate.year, selectedDate.month,
                  selectedDate.day, selectedTime.hour, selectedTime.minute)
              .toUtc();

          int periodSpan;
          if (medicine.frequency == MedicineFrequency.period) {
            periodSpan = _formData['periodSpan'] * 24 * 60 * 60;
          }

          if (passedMedicine.schedule.length == 0) {
            await Provider.of<MedicineProvider>(context, listen: false)
                .addScheduleRecord(
                    MedicineSchedule(
                      intakeTime: date,
                      periodSpan: periodSpan,
                    ),
                    medicine);
          } else {
            await Provider.of<MedicineProvider>(context, listen: false)
                .editScheduleRecord(
                    MedicineSchedule(
                        id: passedMedicine.schedule.first.id,
                        intakeTime: date,
                        periodSpan: periodSpan),
                    medicine);
          }
        }

        Navigator.pop(context);
      } else {
        record = await Provider.of<MedicineProvider>(context, listen: false)
            .addMedicineRecord(medicine);

        Navigator.popAndPushNamed(context, MedicineForm.routeName,
            arguments: {'medicine': record});
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

  Future<void> deleteRecord() async {
    if (passedMedicine.id == null || _isDeletingLoading) {
      return;
    }

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

    if (!confirmed) {
      return;
    }

    try {
      setState(() {
        _isDeletingLoading = true;
      });
      await Provider.of<MedicineProvider>(context, listen: false)
          .removeMedicineRecord(passedMedicine);

      Navigator.pop(context);
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
    Medicine medicine;
    Map<String, Object> args = ModalRoute.of(context).settings.arguments;
    if (args != null && args['medicine'] != null) {
      Medicine m = args['medicine'];
      var filtered = Provider.of<MedicineProvider>(context, listen: true)
          .medicines
          .where((element) => element.id == m.id)
          .toList();
      if (filtered.length > 0) {
        medicine = filtered.first;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Record',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          _isLoading
              ? Container(
                  padding: const EdgeInsets.all(10),
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  icon: Icon(
                    Icons.save,
                    color: Colors.white,
                  ),
                  onPressed: addRecord,
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _formData['name'],
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Invalid name!';
                  }

                  return null;
                },
                onSaved: (value) {
                  _formData['name'] = value;
                },
              ),
              DropdownButtonFormField(
                hint: Text('Frequency'),
                value: _formData['frequency'],
                decoration: InputDecoration(labelText: 'Frequency'),
                disabledHint:
                    Text(MedicineFrequency.convert(_formData['frequency'])),
                items: [
                  DropdownMenuItem<int>(
                    child: Text(
                        MedicineFrequency.convert(MedicineFrequency.everyday)),
                    value: MedicineFrequency.everyday,
                  ),
                  DropdownMenuItem<int>(
                    child:
                        Text(MedicineFrequency.convert(MedicineFrequency.once)),
                    value: MedicineFrequency.once,
                  ),
                  DropdownMenuItem<int>(
                    child: Text(
                        MedicineFrequency.convert(MedicineFrequency.period)),
                    value: MedicineFrequency.period,
                  ),
                ],
                onChanged: medicine != null
                    ? null
                    : (value) {
                        setState(() {
                          _formData['frequency'] = value;
                        });
                      },
                onSaved: (value) {
                  _formData['frequency'] = value;
                },
              ),
              medicine != null &&
                      _formData['frequency'] != MedicineFrequency.everyday
                  ? Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: TextFormField(
                                  readOnly: true,
                                  decoration:
                                      InputDecoration(labelText: 'Intake Date'),
                                  controller: dateController,
                                  validator: (value) {
                                    if (_formData['date'] == null &&
                                        medicine.frequency ==
                                            MedicineFrequency.once) {
                                      return 'Invalid date!';
                                    }

                                    return null;
                                  },
                                  onTap: chooseDate,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: TextFormField(
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Intake Time'),
                                  controller: timeController,
                                  validator: (value) {
                                    if (_formData['time'] == null &&
                                        medicine.frequency ==
                                            MedicineFrequency.once) {
                                      return 'Invalid time!';
                                    }

                                    return null;
                                  },
                                  onTap: chooseTime,
                                ),
                              ),
                            ),
                          ],
                        ),
                        _formData['frequency'] == MedicineFrequency.period
                            ? TextFormField(
                                initialValue:
                                    _formData['periodSpan'].toString(),
                                decoration: const InputDecoration(
                                    labelText: 'Period in days'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  int parsed = int.tryParse(value);
                                  if ((value == null ||
                                          value.isEmpty ||
                                          parsed == null ||
                                          parsed < 1) &&
                                      medicine.frequency ==
                                          MedicineFrequency.period) {
                                    return 'Invalid period span! Provide positive whole number!';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _formData['periodSpan'] = int.parse(value);
                                },
                              )
                            : Text(''),
                      ],
                    )
                  : Text(''),
              medicine != null &&
                      _formData['frequency'] == MedicineFrequency.everyday
                  ? MedicineFormEveryday(
                      medicine: medicine,
                    )
                  : Text(''),
            ],
          ),
        ),
      ),
      floatingActionButton: medicine == null
          ? null
          : FloatingActionButton(
              onPressed: deleteRecord,
              child: Icon(Icons.delete),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
    );
  }
}
