import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './providers/water-povider.dart';
import './providers/weight-provider.dart';
import './providers/medicine-provider.dart';
import './screens/water-supply/water-supply.dart';
import './screens/weight-balance.dart';
import './screens/water-supply/water-supply-daily.dart';
import './screens/medicine/medicine.dart';
import './screens/auth.dart';
import './screens/register.dart';
import './widgets/forms/water-supply-form.dart';
import './widgets/forms/weight-form.dart';
import './widgets/forms/medicine-form.dart';

Future main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

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
            [],
          ),
        ),
        ChangeNotifierProxyProvider<Auth, WaterProvider>(
          update: (ctx, auth, previous) => WaterProvider(
            auth.token,
            [],
            [],
          ),
        ),
        ChangeNotifierProxyProvider<Auth, MedicineProvider>(
          update: (ctx, auth, previous) => MedicineProvider(
            auth.token,
            previous != null ? previous.medicines : [],
            previous != null ? previous.schedule : [],
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
            title: 'Eating Habits',
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
                textTheme: const TextTheme(
                  headline6: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              primarySwatch: Colors.cyan,
              accentColor: Colors.cyanAccent,
              textTheme: TextTheme(
                headline6: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            home: auth.isAuth
                ? WaterSupplyScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) => authResultSnapshot
                                .connectionState ==
                            ConnectionState.waiting
                        ? Scaffold(
                            body: Container(child: CircularProgressIndicator()))
                        : AuthScreen(),
                  ),
            routes: {
              WaterSupplyScreen.routeName: (ctx) => WaterSupplyScreen(),
              WaterSupplyDailyScreen.routeName: (ctx) =>
                  WaterSupplyDailyScreen(),
              WeightBalanceScreen.routeName: (ctx) => WeightBalanceScreen(),
              WeightForm.routeName: (ctx) => WeightForm(),
              WaterSupplyForm.routeName: (ctx) => WaterSupplyForm(),
              MedicineScreen.routeName: (ctx) => MedicineScreen(),
              MedicineForm.routeName: (ctx) => MedicineForm(),
              AuthScreen.routeName: (ctx) => AuthScreen(),
              RegisterScreen.routeName: (ctx) => RegisterScreen(),
            }),
      ),
    );
  }
}
