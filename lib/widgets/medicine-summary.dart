import 'package:eating_habits_mobile/widgets/forms/medicine-form.dart';
import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../screens/water-supply/water-supply-daily.dart';
import '../constants/medicine-frequency.dart' as MedicineFrequency;

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
      onTap: () {
        Navigator.pushNamed(
          context,
          WaterSupplyDailyScreen.routeName,
          arguments: {'date': widget._medicine.name},
        );
      },
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          MedicineForm.routeName,
          arguments: {'medicine': widget._medicine},
        ),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Image.network(
                  'https://images-na.ssl-images-amazon.com/images/I/51%2Bsvqfjd-L._SL1000_.jpg',
                  width: 50,
                  fit: BoxFit.cover,
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      ),
    );
  }
}
