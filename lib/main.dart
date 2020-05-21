import 'package:eating_habits_mobile/providers/water-povider.dart';
import 'package:eating_habits_mobile/providers/weight-provider.dart';
import 'package:eating_habits_mobile/widgets/forms/water-supply-form.dart';
import 'package:eating_habits_mobile/widgets/forms/weight-form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth.dart';
import './widgets/screens/water-supply.dart';
import './widgets/screens/weight-balance.dart';
import './widgets/screens/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, WeightProvider>(
          update: (ctx, auth, previous) => WeightProvider(
            auth.token,
            previous == null ? [] : previous.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, WaterProvider>(
          update: (ctx, auth, previous) => WaterProvider(
            auth.token,
            previous == null ? [] : previous.today,
            previous == null ? [] : previous.all,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
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
            home: auth.isAuth
                ? WeightBalanceScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? Container(
                                child: Text('Loading...'),
                              )
                            : AuthScreen(),
                  ),
            routes: {
              WaterSupplyScreen.routeName: (ctx) => WaterSupplyScreen(),
              WeightBalanceScreen.routeName: (ctx) => WeightBalanceScreen(),
              WeightForm.routeName: (ctx) => WeightForm(),
              WaterSupplyForm.routeName: (ctx) => WaterSupplyForm(),
              AuthScreen.routeName: (ctx) => AuthScreen(),
            }),
      ),
    );
  }
}
