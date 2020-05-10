import 'package:flutter/material.dart';

import '../../widgets/drawer.dart';
import '../../widgets/screens/water-supply-daily-stats.dart';
import '../../widgets/screens/water-supply-daily.dart';

class WaterSupplyScreen extends StatefulWidget {
  static const String routeName = '/water-supply';

  @override
  _WaterSupplyScreenState createState() => _WaterSupplyScreenState();
}

class _WaterSupplyScreenState extends State<WaterSupplyScreen> {
  final DateTime todayDate = DateTime(2020, 4, 2);

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.today)),
              Tab(icon: Icon(Icons.insert_chart)),
            ],
          ),
          title: Text('Water Supply'),
        ),
        drawer: AppDrawer(),
        body: TabBarView(
          children: [
            WaterSupplyDailyScreen(),
            WaterSupplyStatsScreen(),
          ],
        ),
      ),
    );
  }
}
