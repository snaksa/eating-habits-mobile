import './medicine-schedule.dart';

class Medicine {
  int id;
  String name;
  int frequency;
  List<MedicineSchedule> schedule = [];

  Medicine({this.id, this.name, this.frequency});

  Medicine.fromJSON(Map<String, dynamic> json) {
    this.id = json['id'];
    this.name = json['name'];
    this.frequency = json['frequency'];

    if(json['schedule'] != null) {
      var scheduleData = json['schedule']['data'];
      scheduleData.forEach((data) {
        schedule.add(MedicineSchedule.fromJSON(data));
      });
    }
  }
}
