import './widgets/screens/water-supply.dart';
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
          headline6: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      home: WaterSupplyScreen(),
      routes: {
            WaterSupplyScreen.routeName: (ctx) => WaterSupplyScreen(),
            WeightBalanceScreen.routeName: (ctx) => WeightBalanceScreen(),
      }
    );
  }
}
