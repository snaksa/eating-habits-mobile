import 'package:flutter/material.dart';

import './medicine-list.dart';
import '../../widgets/drawer.dart';
import '../../widgets/forms/medicine-form.dart';

class MedicineScreen extends StatefulWidget {
  static const String routeName = '/medicines';

  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
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
              )),
              Tab(
                  icon: Icon(
                Icons.insert_chart,
                color: Colors.white,
              )),
            ],
          ),
          title: const Text('Medicines'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  Navigator.of(context).pushNamed(MedicineForm.routeName),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: TabBarView(
          children: [
            MedicineListScreen(),
            MedicineListScreen(),
          ],
        ),
      ),
    );
  }
}
