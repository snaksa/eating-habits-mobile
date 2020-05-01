import 'dart:math';

class Weight {
  final int id = Random().nextInt(10000);
  final DateTime date;
  final double weight;

  Weight({this.date, this.weight});
}
