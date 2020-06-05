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
  static const String routeName = '/water-supply-daily';

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
      var date = this.getDate();
      Provider.of<WaterProvider>(context)
          .fetchAndSetByDateWaterRecords(date)
          .then(
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

  DateTime getDate() {
    Map<String, Object> args = ModalRoute.of(context).settings.arguments;
    if (args != null && args['date'] != null) {
      return args['date'];
    }

    return null;
  }

  Widget content(AppBar appBar) {
    final mediaQuery = MediaQuery.of(context);

    int target = 5000;
    final availableHeight = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;
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
            builder: (ctx, provider, _) {
              var waterRecords;
              var date = this.getDate();
              if (date != null) {
                waterRecords = provider.specificDate;
              } else {
                waterRecords = provider.today;
              }

              int current = 0;
              waterRecords.forEach((Water water) {
                current += water.amount;
              });

              return _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    )
                  : waterRecords.length <= 0
                      ? Center(
                          child: Text('No records yet'),
                        )
                      : Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 16),
                              alignment: Alignment.topCenter,
                              height: availableHeight *
                                  (mediaQuery.size.height < 600 ? 0.25 : 0.2),
                              child: WaterDailyStats(
                                  current: current,
                                  target: target,
                                  label: date == null
                                      ? 'Today'
                                      : DateFormat.yMMMd().format(date)),
                            ),
                            Container(
                              height: availableHeight *
                                  (mediaQuery.size.height < 600 ? 0.75 : 0.8),
                              child: ListView.builder(
                                itemCount: waterRecords.length,
                                itemBuilder: (BuildContext ctx, int index) {
                                  return Dismissible(
                                    key: ValueKey(waterRecords[index].id),
                                    background: Container(
                                      color: Theme.of(context).errorColor,
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(left: 20),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 4,
                                      ),
                                    ),
                                    direction: DismissDirection.startToEnd,
                                    onDismissed: (_) {
                                      try {
                                        Provider.of<WaterProvider>(context,
                                                listen: false)
                                            .removeWaterRecord(
                                                waterRecords[index]);
                                      } on HttpException catch (error) {
                                        dialog.Dialog(
                                          'An Error Occurred!',
                                          error.message,
                                          {
                                            'Okay': () {
                                              Navigator.of(context).pop();
                                              if (error.status == 403) {
                                                Navigator.of(context)
                                                    .popAndPushNamed(
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
                        );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var date = this.getDate();
    final appBar = AppBar(
      title: Text(date == null ? 'Water Supply' : 'History'),
    );

    return date == null
        ? this.content(appBar)
        : Scaffold(
            appBar: appBar,
            body: this.content(appBar),
          );
  }
}
