import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../auth.dart';
import '../../../exceptions/http_exception.dart';
import '../../../models/weight.dart';
import '../../../providers/weight-provider.dart';
import '../../../widgets/dialog.dart' as dialog;

class WeightForm extends StatefulWidget {
  static final String routeName = '/weight-form';

  @override
  _WeightFormState createState() => _WeightFormState();
}

class _WeightFormState extends State<WeightForm> {
  bool _isLoading = false;
  final Map<String, dynamic> _formData = {
    'weight': '',
    'date': DateTime.now(),
  };
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    dateController.text = DateFormat.yMMMd().format(_formData['date']);
    super.initState();
  }

  void chooseDate() {
    showDatePicker(
      context: context,
      initialDate: _formData['date'],
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((picked) {
      if (picked != null && picked != _formData['date'])
        setState(() {
          _formData['date'] = picked;
          dateController.text = DateFormat.yMMMd().format(picked);
        });
    });
  }

  Future<void> addRecord() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    var selectedDate = _formData['date'];
    var now = DateTime.now();
    var date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
        now.hour, now.minute, now.second);
    Weight weight = Weight(
      date: date.toUtc(),
      weight: double.parse(_formData['weight']),
    );

    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<WeightProvider>(context, listen: false)
          .addWeightRecord(weight);
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
                  icon: const Icon(
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
                decoration: InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty || double.tryParse(value) == null) {
                    return 'Invalid weight!';
                  }

                  return null;
                },
                onSaved: (value) {
                  _formData['weight'] = value;
                },
              ),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(labelText: 'Date'),
                controller: dateController,
                validator: (value) {
                  if (_formData['date'] == null) {
                    return 'Invalid date!';
                  }

                  return null;
                },
                onTap: chooseDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
