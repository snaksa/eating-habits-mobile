import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class WaterDailyStats extends StatelessWidget {
  final int current;
  final int target;
  final String label;

  const WaterDailyStats({
    Key key,
    @required this.current,
    @required this.target,
    @required this.label,
  }) : super(key: key);

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
                this.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              LinearPercentIndicator(
                animation: true,
                lineHeight: 20.0,
                animationDuration: 500,
                percent: current / target > 1 ? 1 : current / target,
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
