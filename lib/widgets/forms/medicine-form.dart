import 'package:eating_habits_mobile/widgets/forms/medicine-form-everyday.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/medicine.dart';
import '../../providers/medicine-provider.dart';
import '../../screens/auth.dart';
import '../../exceptions/http_exception.dart';
import '../../widgets/dialog.dart' as dialog;
import '../../constants/medicine-frequency.dart' as MedicineFrequency;

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
  };
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    if (passedMedicine != null) {
      _formData['name'] = passedMedicine.name;
      _formData['frequency'] = passedMedicine.frequency;
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
      if (medicine.id != null) {
        await Provider.of<MedicineProvider>(context, listen: false)
            .editMedicineRecord(medicine);
      } else {
        await Provider.of<MedicineProvider>(context, listen: false)
            .addMedicineRecord(medicine);
      }
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

  Future<void> deleteRecord() async {
    if (passedMedicine.id == null || _isDeletingLoading) {
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
        title: Text(
          'Add Record',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          _isLoading
              ? Container(
                  padding: EdgeInsets.all(10),
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
                onChanged: (value) {},
                onSaved: (value) {
                  _formData['frequency'] = value;
                },
              ),
              medicine != null &&
                      medicine.frequency == MedicineFrequency.everyday
                  ? MedicineFormEveryday(
                      schedule: medicine.schedule,
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
