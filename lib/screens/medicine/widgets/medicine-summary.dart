import 'package:flutter/material.dart';

import '../forms/medicine-form.dart';
import '../../../models/medicine.dart';
import '../../../constants/medicine-frequency.dart' as MedicineFrequency;

class MedicineSummary extends StatefulWidget {
  final Medicine _medicine;

  MedicineSummary(this._medicine);

  @override
  _MedicineSummaryState createState() => _MedicineSummaryState();
}

class _MedicineSummaryState extends State<MedicineSummary> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        MedicineForm.routeName,
        arguments: {'medicine': widget._medicine},
      ),
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
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget._medicine.name,
                        overflow: TextOverflow.clip,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Text(
                        MedicineFrequency.convert(widget._medicine.frequency),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
