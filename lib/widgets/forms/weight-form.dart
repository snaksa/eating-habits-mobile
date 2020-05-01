import 'package:eating_habits_mobile/models/weight.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeightForm extends StatefulWidget {
  final Function addWeightRecord;

  WeightForm(this.addWeightRecord);

  @override
  _WeightSummaryState createState() => _WeightSummaryState();
}

class _WeightSummaryState extends State<WeightForm> {
  TextEditingController weightTextController = TextEditingController();
  TextEditingController dateTextController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  void chooseDate() {
    showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((picked) {
      if (picked != null && picked != selectedDate)
        setState(() {
          selectedDate = picked;
          dateTextController.text = DateFormat.yMMMd().format(picked);
        });
    });
  }

  void addRecord() {
    if (selectedDate != null && weightTextController.text.isNotEmpty) {
      Weight weight = Weight(
          date: selectedDate, weight: double.parse(weightTextController.text));
      widget.addWeightRecord(weight);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Weight'),
                controller: weightTextController,
                keyboardType: TextInputType.number,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Date'),
                controller: dateTextController,
                onTap: chooseDate,
              ),
              RaisedButton(
                child: Text('Add'),
                onPressed: addRecord,
              )
            ],
          ),
        ),
      ),
    );
  }
}
