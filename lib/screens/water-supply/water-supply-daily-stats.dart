import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../auth.dart';
import '../../providers/water-povider.dart';
import '../../widgets/charts/water-supply-chart.dart';
import '../../widgets/dialog.dart' as dialog;
import '../../widgets/water-daily-summary.dart';

class WaterSupplyStatsScreen extends StatefulWidget {
  @override
  _WaterSupplyStatsScreenState createState() => _WaterSupplyStatsScreenState();
}

class _WaterSupplyStatsScreenState extends State<WaterSupplyStatsScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<WaterProvider>(context).fetchAndSetWaterRecords().then(
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
    return Padding(
      padding: const EdgeInsets.only(
        top: 0,
        left: 10,
        right: 10,
        bottom: 0,
      ),
      child: LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints) =>
            Consumer<WaterProvider>(
          builder: (ctx, provider, _) => this._isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                )
              : provider.all.length <= 0
                  ? Center(
                      child: Text('No records yet'),
                    )
                  : Column(
                      children: <Widget>[
                        Container(
                          height: constraints.maxHeight *
                              (constraints.maxHeight < 600 ? 0.5 : 0.4),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: WaterSupplyChart(provider.all),
                          ),
                        ),
                        Container(
                          height: constraints.maxHeight *
                              (constraints.maxHeight < 500 ? 0.5 : 0.6),
                          child: ListView.builder(
                            itemCount: provider.all.length,
                            itemBuilder: (BuildContext ctx, int index) {
                              return WaterDailySummary(
                                provider.all[index],
                                DateFormat.yMMMd(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
