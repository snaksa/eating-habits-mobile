import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../auth.dart';
import '../../models/water.dart';
import '../../providers/water-povider.dart';
import '../../exceptions/http_exception.dart';
import '../../widgets/water-daily-stats.dart';
import '../../widgets/dialog.dart' as dialog;
import '../../widgets/water-daily-summary.dart';

class WaterSupplyDailyScreen extends StatefulWidget {
  @override
  _WaterSupplyDailyScreenState createState() => _WaterSupplyDailyScreenState();
}

class _WaterSupplyDailyScreenState extends State<WaterSupplyDailyScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<WaterProvider>(context).fetchAndSetTodayWaterRecords().then(
        (_) {
          setState(() {
            _isLoading = false;
          });
        },
      ).catchError((error) {
        dialog.Dialog('An error occured', error.message, {
          'Okay': () {
            Navigator.of(context).pop();
            if (error.status == 403) {
              Navigator.of(context).popAndPushNamed(AuthScreen.routeName);
            }
          },
        }).show(context);
      });
    }

    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final waterRecords = Provider.of<WaterProvider>(context).today;

    final appBar = AppBar(
      title: Text('Water Supply'),
    );

    int current = 0;
    waterRecords.forEach((Water water) {
      current += water.amount;
    });

    int target = 5000;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 0,
          left: 10,
          right: 10,
          bottom: 0,
        ),
        child: SingleChildScrollView(
          child: Consumer<WaterProvider>(
            builder: (ctx, provider, _) => _isLoading
                ? Container(child: CircularProgressIndicator())
                : Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topCenter,
                        height: (mediaQuery.size.height -
                                appBar.preferredSize.height -
                                mediaQuery.padding.top) *
                            (mediaQuery.size.height < 600 ? 0.25 : 0.2),
                        child: Column(
                          children: <Widget>[
                            WaterDailyStats(current: current, target: target),
                          ],
                        ),
                      ),
                      Container(
                        height: (mediaQuery.size.height -
                                appBar.preferredSize.height -
                                mediaQuery.padding.top) *
                            (mediaQuery.size.height < 600 ? 0.75 : 0.8),
                        child: ListView.builder(
                          itemCount: waterRecords.length,
                          itemBuilder: (BuildContext ctx, int index) {
                            return Dismissible(
                              key: ValueKey(provider.today[index].id),
                              background: Container(
                                color: Theme.of(context).errorColor,
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 20),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 4,
                                ),
                              ),
                              direction: DismissDirection.startToEnd,
                              onDismissed: (_) {
                                try {
                                  Provider.of<WaterProvider>(context,
                                          listen: false)
                                      .removeWaterRecord(provider.today[index]);
                                } on HttpException catch (error) {
                                  dialog.Dialog(
                                    'An Error Occurred!',
                                    error.message,
                                    {
                                      'Okay': () {
                                        Navigator.of(context).pop();
                                        if (error.status == 403) {
                                          Navigator.of(context).popAndPushNamed(
                                              AuthScreen.routeName);
                                        }
                                      }
                                    },
                                  ).show(context);
                                }
                              },
                              confirmDismiss: (_) {
                                return dialog.Dialog(
                                  'Are you sure?',
                                  'The item will be deleted',
                                  {
                                    'Yes': () {
                                      Navigator.of(ctx).pop(true);
                                    },
                                    'No': () {
                                      Navigator.of(ctx).pop(false);
                                    }
                                  },
                                ).show(context);
                              },
                              child: WaterDailySummary(
                                waterRecords[index],
                                DateFormat.Hm(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
