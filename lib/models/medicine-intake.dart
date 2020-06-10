import './medicine-schedule.dart';

class MedicineIntake {
  int id;
  DateTime date;
  MedicineSchedule schedule;

  MedicineIntake({this.id, this.date});

  MedicineIntake.fromJSON(Map<String, dynamic> json) {
    this.id = json['id'];
    this.date = DateTime.parse(json['date']).toLocal();

    if (json['schedule'] != null) {
      var scheduleData = json['schedule']['data'];
      schedule = MedicineSchedule.fromJSON(scheduleData);
    }
  }
}
