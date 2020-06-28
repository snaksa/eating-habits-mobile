import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth.dart';
import '../../screens/water-supply/water-supply.dart';
import '../../services/calculation-helper.dart';
import '../../screens/weight/widgets/weight-form.dart';
import '../../widgets/drawer.dart';
import '../../models/user.dart';
import '../../providers/auth.dart';
import '../../exceptions/http_exception.dart';
import '../../providers/weight-provider.dart';
import '../../constants/gender.dart' as Gender;
import '../../widgets/dialog.dart' as dialog;

class UserForm extends StatefulWidget {
  static final String routeName = '/user-form';

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  bool _isLoading = false;
  bool _init = false;
  final Map<String, dynamic> _formData = {
    'username': '',
    'name': '',
    'age': 0,
    'height': 0,
    'gender': 0,
    'lang': '',
    'waterCalculation': false,
    'waterAmount': 5000
  };
  final _formKey = GlobalKey<FormState>();
  final TextEditingController waterAmountController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  bool _radioValue = false;

  @override
  void didChangeDependencies() async {
    if (!_init) {
      User user = Provider.of<Auth>(context, listen: false).me;
      _formData['username'] = user.username;
      _formData['name'] = user.name;
      _formData['age'] = user.age ?? '';
      _formData['height'] = user.height ?? '';
      _formData['gender'] = user.gender;
      _formData['lang'] = user.lang;
      _formData['water_calculation'] = user.waterCalculation;
      _formData['water_amount'] = user.waterAmount;

      await Provider.of<WeightProvider>(context, listen: false)
          .fetchAndSetWeightRecords();

      if (!_isLoading) {
        setState(() {
          waterAmountController.text = '0';
          _radioValue = user.waterCalculation;
        });
      }
      setState(() {
        _init = true;
      });
    }

    super.didChangeDependencies();
  }

  Future<void> save() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Auth>(context, listen: false).editUser(_formData);

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        await Navigator.of(context)
            .popAndPushNamed(WaterSupplyScreen.routeName);
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

  void onRadioChange(bool value) {
    setState(() {
      _radioValue = value;
      _formData['water_calculation'] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var weightRecords =
        Provider.of<WeightProvider>(context, listen: true).items;
    var lastWeightRecord =
        weightRecords.length > 0 ? weightRecords.first : null;
    if (lastWeightRecord != null) {
      int intake =
          CalculationHelper().calculateDynamicWeight(lastWeightRecord).ceil();
      var text = "${intake}ml";
      if (text != waterAmountController.text) {
        setState(() {
          waterAmountController.text = text;
          weightController.text =
              "${lastWeightRecord.weight.toStringAsFixed(2)} kg";
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
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
                  onPressed: save,
                ),
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  enabled: false,
                  decoration: InputDecoration(labelText: 'Username'),
                  initialValue: _formData['username'],
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  initialValue: _formData['name'],
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
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        initialValue: _formData['age'].toString(),
                        validator: (value) {
                          var parsed = int.tryParse(value);
                          if (value.isEmpty || parsed == null || parsed <= 0) {
                            return 'Invalid age!';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formData['age'] = value;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Height'),
                        keyboardType: TextInputType.number,
                        initialValue: _formData['height'].toString(),
                        validator: (value) {
                          var parsed = int.tryParse(value);
                          if (value.isEmpty || parsed == null || parsed <= 0) {
                            return 'Invalid height!';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formData['height'] = value;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              enabled: false,
                              decoration:
                                  InputDecoration(labelText: 'Latest Weight'),
                              controller: weightController,
                            ),
                          ),
                          lastWeightRecord == null
                              ? GestureDetector(
                                  child: Icon(
                                    Icons.add_circle,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(WeightForm.routeName);
                                  },
                                )
                              : Text(''),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        hint: Text('Gender'),
                        value: _formData['gender'],
                        decoration: InputDecoration(labelText: 'Gender'),
                        disabledHint: Text(Gender.convert(_formData['gender'])),
                        items: [
                          DropdownMenuItem<int>(
                            child: Text(Gender.convert(Gender.male)),
                            value: Gender.male,
                          ),
                          DropdownMenuItem<int>(
                            child: Text(Gender.convert(Gender.female)),
                            value: Gender.female,
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _formData['gender'] = value;
                          });
                        },
                        onSaved: (value) {
                          _formData['gender'] = value;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Radio(
                        value: false,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        groupValue: _radioValue,
                        onChanged: (value) => this.onRadioChange(value),
                      ),
                    ),
                    GestureDetector(
                      child: Text('Fixed water intake'),
                      onTap: () => this.onRadioChange(false),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Radio(
                        value: true,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        groupValue: _radioValue,
                        onChanged: (value) => this.onRadioChange(value),
                      ),
                    ),
                    GestureDetector(
                      child: Text('Dynamic water intake based on weight'),
                      onTap: () => this.onRadioChange(true),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        enabled: !_radioValue,
                        decoration: InputDecoration(
                          labelText: 'Fixed (ml)',
                          fillColor: Theme.of(context).primaryColor,
                          filled: !_radioValue,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          labelStyle: !_radioValue
                              ? TextStyle(color: Colors.white)
                              : null,
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _formData['water_amount'].toString(),
                        style: TextStyle(
                            color: !_radioValue ? Colors.white : Colors.black),
                        validator: (value) {
                          if (value.isEmpty || int.tryParse(value) == null) {
                            return 'Invalid amount!';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formData['water_amount'] = value;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Calculated',
                          fillColor: Theme.of(context).primaryColor,
                          filled: _radioValue,
                          labelStyle: _radioValue
                              ? TextStyle(color: Colors.white)
                              : null,
                        ),
                        controller: waterAmountController,
                        style: TextStyle(
                            color: _radioValue ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
