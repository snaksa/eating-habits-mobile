import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth.dart';
import '../../providers/weight-provider.dart';
import '../../widgets/drawer.dart';
import '../../widgets/dialog.dart' as dialog;
import '../../widgets/no-records.dart';
import './widgets/weight-stats.dart';
import './widgets/weight-summary.dart';
import './widgets/weight-chart.dart';
import './widgets/weight-form.dart';

class WeightBalanceScreen extends StatefulWidget {
  static const String routeName = '/weight-balance';

  @override
  _WeightBalanceScreenState createState() => _WeightBalanceScreenState();
}

class _WeightBalanceScreenState extends State<WeightBalanceScreen> {
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
    return Scaffold(
      appBar: appBar,
      drawer: AppDrawer(),
      body: Center(
        child: Padding(
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
                          children: <Widget>[
                            Container(
                              height: availableHeight * 0.15,
                              child: provider.items.length > 0
                                  ? WeightStats(
                                      provider.items.first.weight,
                                      provider.items.last.weight,
                                    )
                                  : WeightStats(0, 0),
                            ),
                            Container(
                              height: availableHeight * 0.3,
                              child: WeightChart(provider.items),
                            ),
                            Card(
                              child: Container(
                                height: availableHeight * 0.55,
                                child: ListView.builder(
                                  itemCount: provider.items.length,
                                  itemBuilder: (BuildContext ctx, int index) {
                                    return WeightSummary(
                                      provider.items[index],
                                      deleteWeightRecord: () {},
                                      diff: num.parse(
                                        (index < provider.items.length - 1
                                                ? provider.items[index + 1]
                                                        .weight -
                                                    provider.items[index].weight
                                                : 0)
                                            .toStringAsFixed(3),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
