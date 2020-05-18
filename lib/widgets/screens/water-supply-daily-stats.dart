import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/water-povider.dart';
import '../../widgets/screens/auth.dart';
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
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) =>
          Consumer<WaterProvider>(
        builder: (ctx, provider, _) => this._isLoading
            ? Container(child: CircularProgressIndicator())
            : Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: constraints.maxHeight * 0.4,
                    child: WaterSupplyChart(provider.all),
                  ),
                  Container(
                    height: constraints.maxHeight * 0.6,
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
    );
  }
}
