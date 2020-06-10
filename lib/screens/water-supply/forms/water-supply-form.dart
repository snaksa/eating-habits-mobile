import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../screens/auth.dart';
import '../../../models/water.dart';
import '../../../providers/water-povider.dart';
import '../../../exceptions/http_exception.dart';
import '../../../widgets/dialog.dart' as dialog;
import './water-amount-option.dart';

class WaterSupplyForm extends StatefulWidget {
  static final String routeName = '/water-supply-form';

  @override
  _WaterSupplyFormState createState() => _WaterSupplyFormState();
}

class _WaterSupplyFormState extends State<WaterSupplyForm> {
  bool _isLoading = false;
  final Map<String, dynamic> _formData = {
    'amount': 0,
    'date': DateTime.now(),
    'time': TimeOfDay.now(),
  };

  final Map<int, bool> _selectedAmount = {
    100: false,
    250: false,
    500: false,
    1000: false
  };

  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    amountController.text = "0";
    dateController.text = DateFormat.yMMMd().format(_formData['date']);

    String minutes = _formData['time'].minute.toString();
    if (minutes.length < 2) {
      minutes = '0' + minutes;
    }
    timeController.text = "${_formData['time'].hour}:$minutes";

    super.initState();
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

    var selectedDate = _formData['date'];
    TimeOfDay selectedTime = _formData['time'];

    var date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
        selectedTime.hour, selectedTime.minute);

    Water waterSupply = Water(
      date: date.toUtc(),
      amount: _formData['amount'],
    );

    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<WaterProvider>(context, listen: false)
          .addWaterRecord(waterSupply);
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

  void _selectOption(int amount) {
    setState(() {
      _selectedAmount[amount] = !_selectedAmount[amount];
      var currentAmount = _formData['amount'];

      currentAmount = _selectedAmount[amount]
          ? currentAmount + amount
          : currentAmount - amount;

      amountController.text = "${currentAmount}ml";
      _formData['amount'] = currentAmount;
    });
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  validator: (value) {
                    if (_formData['amount'] <= 0) {
                      return 'Invalid amount!';
                    }

                    return null;
                  },
                  onSaved: (value) {},
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      WaterAmountOption(
                        empty: 'assets/images/cup-100-empty.png',
                        full: 'assets/images/cup-100-full.png',
                        selected: _selectedAmount[100],
                        text: '100ml',
                        onTap: () => _selectOption(100),
                      ),
                      WaterAmountOption(
                        empty: 'assets/images/glass-250-empty.png',
                        full: 'assets/images/glass-250-full.png',
                        selected: _selectedAmount[250],
                        text: '250ml',
                        onTap: () => _selectOption(250),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      WaterAmountOption(
                        empty: 'assets/images/bottle-500-empty.png',
                        full: 'assets/images/bottle-500-full.png',
                        selected: _selectedAmount[500],
                        text: '500ml',
                        onTap: () => _selectOption(500),
                      ),
                      WaterAmountOption(
                        empty: 'assets/images/bottle-1000-empty.png',
                        full: 'assets/images/bottle-1000-full.png',
                        selected: _selectedAmount[1000],
                        text: '1L',
                        onTap: () => _selectOption(1000),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
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
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(labelText: 'Time'),
                          controller: timeController,
                          validator: (value) {
                            if (_formData['time'] == null) {
                              return 'Invalid time!';
                            }

                            return null;
                          },
                          onTap: chooseTime,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
