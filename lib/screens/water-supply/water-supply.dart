import 'package:flutter/material.dart';

import './water-supply-daily.dart';
import './water-supply-daily-stats.dart';
import '../../widgets/drawer.dart';
import './forms/water-supply-form.dart';

class WaterSupplyScreen extends StatefulWidget {
  static const String routeName = '/water-supply';

  @override
  _WaterSupplyScreenState createState() => _WaterSupplyScreenState();
}

class _WaterSupplyScreenState extends State<WaterSupplyScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              const Tab(
                icon: Icon(
                  Icons.today,
                  color: Colors.white,
                ),
              ),
              const Tab(
                icon: Icon(
                  Icons.insert_chart,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          title: const Text('Water Supply'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
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
