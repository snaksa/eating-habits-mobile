import 'package:flutter/material.dart';

import './water-supply-daily.dart';
import './water-supply-daily-stats.dart';
import '../../widgets/drawer.dart';
import '../../widgets/forms/water-supply-form.dart';

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
              Tab(
                  icon: Icon(
                Icons.today,
                color: Colors.white,
              )),
              Tab(
                  icon: Icon(
                Icons.insert_chart,
                color: Colors.white,
              )),
            ],
          ),
          title: Text('Water Supply'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () =>
                  Navigator.of(context).pushNamed(WaterSupplyForm.routeName),
            ),
          ],
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
