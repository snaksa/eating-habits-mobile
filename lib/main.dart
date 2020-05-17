import 'package:eating_habits_mobile/providers/weight-provider.dart';
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
          update: (ctx, auth, previousProducts) => WeightProvider(
            auth.token,
            previousProducts == null ? [] : previousProducts.items,
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
              AuthScreen.routeName: (ctx) => AuthScreen(),
            }),
      ),
    );
  }
}
