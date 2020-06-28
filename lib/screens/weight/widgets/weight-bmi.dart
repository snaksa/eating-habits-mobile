import 'dart:math';

import 'package:flutter/material.dart';
import '../../../constants/weight-bmi.dart' as BMI;

class WeightBMI extends StatelessWidget {
  final double weight;
  final int height;

  WeightBMI(this.weight, this.height);

  double calculateBMI() {
    return this.weight / (pow(this.height / 100, 2));
  }

  double calcualteChart(double width) {
    double bmi = this.calculateBMI();

    double result = 0;
    if (bmi <= BMI.underweight) {
      double percentage = (bmi / BMI.underweight);
      result = percentage * (width / 4);
    } else if (bmi <= BMI.normal) {
      double percentage =
          ((bmi - BMI.underweight) / (BMI.normal - BMI.underweight));
      result = width * 0.25 + (percentage * (width / 4));
    } else if (bmi <= BMI.overweight) {
      double percentage = ((bmi - BMI.normal) / (BMI.overweight - BMI.normal));
      result = width * 0.5 + (percentage * (width / 4));
    } else {
      double percentage =
          ((bmi - BMI.overweight) / (BMI.obesity - BMI.overweight));
      result = width * 0.75 + (percentage * (width / 4));
    }

    return result;
  }

  Widget bmiLegendItem(
      String title, String range, Color color, bool highlight) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: highlight ? BoxDecoration(color: Colors.grey.shade200) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 4),
                height: 15,
                width: 15,
                decoration: BoxDecoration(color: color),
              ),
              Text(title),
            ],
          ),
          Text(range),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var bmi = this.calculateBMI();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Column(
            children: <Widget>[
              Text(
                'BMI: ${this.calculateBMI().toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              LayoutBuilder(
                builder: (ctx, constraints) => Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(color: Colors.blue),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 10,
                              decoration:
                                  BoxDecoration(color: Colors.green.shade300),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(color: Colors.yellow),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        height: 18,
                        width: this.calcualteChart(constraints.maxWidth),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.black, width: 3),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              this.bmiLegendItem(
                'Underweight',
                '< 18.5',
                Colors.blue,
                BMI.isUnderweight(bmi),
              ),
              this.bmiLegendItem(
                'Normal',
                '18.5 - 25',
                Colors.green.shade300,
                BMI.isNormal(bmi),
              ),
              this.bmiLegendItem(
                'Overweight',
                '25 - 30',
                Colors.yellow,
                BMI.isOverweight(bmi),
              ),
              this.bmiLegendItem(
                'Obese',
                '> 30',
                Colors.red,
                BMI.isObese(bmi),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
