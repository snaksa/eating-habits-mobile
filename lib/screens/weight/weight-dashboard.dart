import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth.dart';
import '../../providers/weight-provider.dart';
import '../../providers/auth.dart';
import '../../widgets/dialog.dart' as dialog;
import '../../widgets/no-records.dart';
import '../user/user-form.dart';
import './widgets/weight-bmi.dart';
import './widgets/weight-stats.dart';
import './widgets/weight-chart.dart';
import './widgets/weight-form.dart';

class WeightDashboard extends StatefulWidget {
  @override
  _WeightDashboardState createState() => _WeightDashboardState();
}

class _WeightDashboardState extends State<WeightDashboard> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<WeightProvider>(context).fetchAndSetWeightRecords().then(
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

    final appBar = AppBar(
      title: Text('Weight Balance'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () =>
              Navigator.of(context).pushNamed(WeightForm.routeName),
        ),
      ],
    );

    final availableHeight =
        mediaQuery.size.height - appBar.preferredSize.height;

    var me = Provider.of<Auth>(context).me;

    return Padding(
      padding: const EdgeInsets.only(
        top: 0,
        left: 10,
        right: 10,
        bottom: 0,
      ),
      child: SingleChildScrollView(
        child: Consumer<WeightProvider>(
          builder: (ctx, provider, _) => _isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ],
                )
              : provider.items.length <= 0
                  ? NoRecords(availableHeight)
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: provider.items.length > 0
                              ? WeightStats(
                                  provider.items.first.weight,
                                  provider.items.last.weight,
                                )
                              : WeightStats(0, 0),
                        ),
                        me.height == null
                            ? Card(
                                child: FlatButton(
                                  child: Text(
                                    'Tell us more about yourself so we can calculate your BMI',
                                    textAlign: TextAlign.center,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed(UserForm.routeName);
                                  },
                                ),
                              )
                            : WeightBMI(
                                provider.items.length > 0
                                    ? provider.items.first.weight
                                    : null,
                                me.height),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          height: availableHeight * 0.3,
                          child: WeightChart(provider.items),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
