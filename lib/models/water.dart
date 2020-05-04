import 'dart:math';

class Water {
  final int id = Random().nextInt(10000);
  final DateTime date;
  final double amount;

  Water({this.date, this.amount});
}
