
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class WaterDailyStats extends StatelessWidget {
  const WaterDailyStats({
    Key key,
    @required this.current,
    @required this.target,
  }) : super(key: key);

  final int current;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Today',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 14,
              ),
              LinearPercentIndicator(
                animation: true,
                lineHeight: 20.0,
                animationDuration: 500,
                percent:
                    current / target > 1 ? 1 : current / target,
                center: Text('${current}ml of ${target}ml',
                    style: TextStyle(color: Colors.white)),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: current / target < 0.3
                    ? Colors.red.shade500
                    : current / target < 0.7
                        ? Colors.orange.shade900
                        : current / target < 0.9
                            ? Colors.lightGreen
                            : Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
