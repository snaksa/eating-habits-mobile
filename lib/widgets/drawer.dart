import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/auth.dart';
import '../screens/water-supply/water-supply.dart';
import '../screens/weight-balance.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text(
              'Eating Habits',
              style: TextStyle(color: Colors.white),
            ),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: Icon(Icons.local_drink),
            title: Text('Water Supply'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(WaterSupplyScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.show_chart),
            title: Text('Weight Balance'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(WeightBalanceScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Log Out'),
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
