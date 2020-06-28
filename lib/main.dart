import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './providers/water-povider.dart';
import './providers/weight-provider.dart';
import './providers/medicine-provider.dart';
import './screens/water-supply/water-supply.dart';
import './screens/weight/weight.dart';
import './screens/water-supply/water-supply-daily.dart';
import './screens/medicine/medicine.dart';
import './screens/auth.dart';
import './screens/register.dart';
import './screens/water-supply/forms/water-supply-form.dart';
import './screens/weight/widgets/weight-form.dart';
import './screens/medicine/forms/medicine-form.dart';
import './screens/user/user-form.dart';

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
            auth.token != null && previous != null ? previous.items : [],
          ),
        ),
        ChangeNotifierProxyProvider<Auth, WaterProvider>(
          update: (ctx, auth, previous) => WaterProvider(
            auth.token,
            auth.token != null && previous != null ? previous.today : [],
            auth.token != null && previous != null ? previous.all : [],
          ),
        ),
        ChangeNotifierProxyProvider<Auth, MedicineProvider>(
          update: (ctx, auth, previous) => MedicineProvider(
            auth.token,
            auth.token != null && previous != null ? previous.medicines : [],
            auth.token != null && previous != null ? previous.schedule : [],
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
                            body: Center(child: Container(child: CircularProgressIndicator())))
                        : AuthScreen(),
                  ),
            routes: {
              WaterSupplyScreen.routeName: (ctx) => WaterSupplyScreen(),
              WaterSupplyDailyScreen.routeName: (ctx) =>
                  WaterSupplyDailyScreen(),
              WeightScreen.routeName: (ctx) => WeightScreen(),
              WeightForm.routeName: (ctx) => WeightForm(),
              WaterSupplyForm.routeName: (ctx) => WaterSupplyForm(),
              MedicineScreen.routeName: (ctx) => MedicineScreen(),
              MedicineForm.routeName: (ctx) => MedicineForm(),
              UserForm.routeName: (ctx) => UserForm(),
              AuthScreen.routeName: (ctx) => AuthScreen(),
              RegisterScreen.routeName: (ctx) => RegisterScreen(),
            }),
      ),
    );
  }
}
