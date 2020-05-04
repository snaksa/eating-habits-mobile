import 'package:flutter/material.dart';
import '../../widgets/charts/water-supply-chart.dart';

class WaterSupplyStatsScreen extends StatefulWidget {
  @override
  _WaterSupplyStatsScreenState createState() => _WaterSupplyStatsScreenState();
}

class _WaterSupplyStatsScreenState extends State<WaterSupplyStatsScreen> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) => Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            height: constraints.maxHeight * 0.4,
            child: WaterSupplyChart(),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            height: constraints.maxHeight * 0.6,
            width: double.infinity,
            child: Card(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Trends',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Average intake'),
                              Text('4500ml'),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Streak'),
                              Text('16 days'),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Average completion'),
                              Text('95%'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }
}
