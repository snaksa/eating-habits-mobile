import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth.dart';
import '../../providers/weight-provider.dart';
import '../../widgets/dialog.dart' as dialog;
import '../../widgets/no-records.dart';
import './widgets/weight-summary.dart';
import './widgets/weight-form.dart';

class WeightRecords extends StatefulWidget {
  @override
  _WeightRecordsState createState() => _WeightRecordsState();
}

class _WeightRecordsState extends State<WeightRecords> {
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
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
                    : Card(
                      child: Container(
                        height: availableHeight,
                        child: ListView.builder(
                          itemCount: provider.items.length,
                          itemBuilder: (BuildContext ctx, int index) {
                            return WeightSummary(
                              provider.items[index],
                              deleteWeightRecord: () {},
                              diff: num.parse(
                                (index < provider.items.length - 1
                                        ? provider
                                                .items[index + 1].weight -
                                            provider.items[index].weight
                                        : 0)
                                    .toStringAsFixed(3),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
