import 'package:flutter/material.dart';

import './weight-records.dart';
import './weight-dashboard.dart';
import '../../widgets/drawer.dart';
import './widgets/weight-form.dart';

class WeightScreen extends StatefulWidget {
  static const String routeName = '/weight-balance';

  @override
  _WeightScreenState createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
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
                  Icons.show_chart,
                  color: Colors.white,
                ),
              ),
              const Tab(
                icon: Icon(
                  Icons.format_list_bulleted,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          title: const Text('Weight Balance'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  Navigator.of(context).pushNamed(WeightForm.routeName),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: TabBarView(
          children: [
            WeightDashboard(),
            WeightRecords(),
          ],
        ),
      ),
    );
  }
}
