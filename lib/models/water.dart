import 'dart:math';

class Water {
  int id = Random().nextInt(10000);
  DateTime date;
  double amount;

  Water({this.date, this.amount});

  Water.fromJSON(Map<String, dynamic> json) {
    this.id = json['id'] ?? 0;
    this.date = DateTime.parse(json['date']);
    this.amount = double.parse(json['amount'].toString());
  }
}
