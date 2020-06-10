import './medicine.dart';
import './medicine-intake.dart';

class MedicineSchedule {
  int id;
  DateTime intakeTime;
  int periodSpan;
  Medicine medicine;
  List<MedicineIntake> intakes = [];

  MedicineSchedule({this.id, this.intakeTime, this.periodSpan});

  MedicineSchedule.fromJSON(Map<String, dynamic> json) {
    this.id = json['id'];
    this.intakeTime = DateTime.parse(json['intakeTime']).toLocal();
    this.periodSpan = json['periodSpan'];

    if (json['medicine'] != null) {
      var medicineData = json['medicine']['data'];
      medicine = Medicine.fromJSON(medicineData);
    }

    if (json['intakes'] != null) {
      var intakesData = json['intakes']['data'];
      intakesData.forEach((data) {
        intakes.add(MedicineIntake.fromJSON(data));
      });
    }
  }

  MedicineIntake get isTaken {
    var now = DateTime.now();
    MedicineIntake taken;
    intakes.forEach((MedicineIntake intake) {
      if (now.year == intake.date.year &&
          now.month == intake.date.month &&
          now.day == intake.date.day) {
        taken = intake;
      }
    });

    return taken;
  }
}
