import 'package:eating_habits_mobile/widgets/screens/water-supply.dart';
import 'package:flutter/material.dart';
import './widgets/screens/weight-balance.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eating Habits',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        accentColor: Colors.cyanAccent,
        textTheme: TextTheme(
          title: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      home: WaterSupplyScreen(),
    );
  }
}
