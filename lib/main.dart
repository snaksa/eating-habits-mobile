import 'package:eating_habits_mobile/models/weight.dart';
import 'package:eating_habits_mobile/widgets/charts/weight-chart.dart';
import 'package:eating_habits_mobile/widgets/forms/weight-form.dart';
import 'package:eating_habits_mobile/widgets/weight-stats.dart';
import 'package:eating_habits_mobile/widgets/weight-summary.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eating Habits',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        accentColor: Colors.cyanAccent,
        textTheme: TextTheme(
          title: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Weight> weights = [
    Weight(
      date: DateTime(2020, 4, 2),
      weight: 88.8,
    ),
    Weight(
      date: DateTime(2020, 4, 3),
      weight: 88.5,
    ),
    Weight(
      date: DateTime(2020, 4, 4),
      weight: 88.65,
    ),
    Weight(
      date: DateTime(2020, 4, 5),
      weight: 88.2,
    ),
    Weight(
      date: DateTime(2020, 4, 6),
      weight: 88.4,
    ),
    Weight(
      date: DateTime(2020, 4, 7),
      weight: 88.2,
    ),
    Weight(
      date: DateTime(2020, 4, 8),
      weight: 88.0,
    ),
    Weight(
      date: DateTime(2020, 4, 9),
      weight: 87.4,
    ),
    Weight(
      date: DateTime(2020, 4, 10),
      weight: 87.0,
    ),
    Weight(
      date: DateTime(2020, 4, 11),
      weight: 86.6,
    ),
  ];

  void _addWeightRecord(Weight weight) {
    setState(() {
      weights.add(weight);
      weights.sort((Weight a, Weight b) => a.date.compareTo(b.date));
    });
  }

  void _deleteWeightRecord(Weight weight) {
    setState(() {
      weights.removeWhere((w) => w.id == weight.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final appBar = AppBar(
      title: Text(
        'Weight balance',
        style: TextStyle(color: Colors.white),
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 0,
            left: 10,
            right: 10,
            bottom: 0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height:
                      (mediaQuery.size.height - appBar.preferredSize.height) *
                          0.15,
                  child: WeightStats(),
                ),
                Container(
                  height:
                      (mediaQuery.size.height - appBar.preferredSize.height) *
                          0.3,
                  child: WeightChart(weights),
                ),
                Container(
                  height:
                      (mediaQuery.size.height - appBar.preferredSize.height) *
                          0.5,
                  child: ListView.builder(
                    itemCount: weights.length,
                    itemBuilder: (BuildContext ctx, int index) {
                      return WeightSummary(
                        weights[index],
                        deleteWeightRecord: this._deleteWeightRecord,
                        diff: num.parse(
                          (index > 0
                                  ? weights[index].weight -
                                      weights[index - 1].weight
                                  : 0)
                              .toStringAsFixed(3),
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
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (_) {
                return WeightForm(
                  _addWeightRecord,
                );
              });
        },
      ),
    );
  }
}
