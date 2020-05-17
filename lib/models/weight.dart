class Weight {
  int id;
  DateTime date;
  double weight;

  Weight({this.id, this.date, this.weight});

  Weight.fromJSON(Map<String, dynamic> json) {
    this.id = json['id'];
    this.date = DateTime.parse(json['date']).toLocal();
    this.weight = double.parse(json['weight'].toString());
  }
}
