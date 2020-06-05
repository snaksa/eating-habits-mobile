class MedicineSchedule {
  int id;
  DateTime intakeTime;
  int periodSpan;

  MedicineSchedule({this.id, this.intakeTime, this.periodSpan});

  MedicineSchedule.fromJSON(Map<String, dynamic> json) {
    this.id = json['id'];
    this.intakeTime = DateTime.parse(json['intakeTime']).toLocal();
    this.periodSpan = json['periodSpan'];
  }
}
