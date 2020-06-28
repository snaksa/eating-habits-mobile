import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/auth.dart';
import '../screens/water-supply/water-supply.dart';
import '../screens/weight/weight.dart';
import '../screens/medicine/medicine.dart';
import '../screens/user/user-form.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text(
              'Eating Habits',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(UserForm.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_drink),
            title: const Text('Water Supply'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(WaterSupplyScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.show_chart),
            title: const Text('Weight Balance'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(WeightScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_hospital),
            title: const Text('Medicines'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(MedicineScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Log Out'),
            onTap: () {
              Provider.of<Auth>(context, listen: false).logout().then((_) =>
                  Navigator.of(context)
                      .pushReplacementNamed(AuthScreen.routeName));
            },
          ),
        ],
      ),
    );
  }
}
