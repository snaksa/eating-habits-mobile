import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../http/request.dart' as http;
import '../models/medicine.dart';
import '../models/medicine-intake.dart';
import '../models/medicine-schedule.dart';

class MedicineProvider with ChangeNotifier {
  List<Medicine> _medicines = [];
  List<MedicineSchedule> _schedule = [];

  final String authToken;

  MedicineProvider(this.authToken, this._medicines, this._schedule);

  List<Medicine> get medicines {
    var list = [..._medicines];
    return list;
  }

  List<MedicineSchedule> get schedule {
    _schedule.sort((MedicineSchedule a, MedicineSchedule b) {
      return a.intakeTime.compareTo(b.intakeTime);
    });

    var list = [..._schedule];

    return list;
  }

  Future<void> fetchMedicineRecords() async {
    if (_medicines.length > 0) {
      return;
    }

    final responseData =
        await http.Request(authToken).fetch('medicines?include=schedule');
    final extractedData = responseData['data'];
    final List<Medicine> data = [];
    extractedData.forEach((item) {
      data.add(Medicine.fromJSON(item));
    });

    _medicines = data;

    notifyListeners();
  }

  Future<Medicine> addMedicineRecord(Medicine medicine) async {
    final responseData = await http.Request(this.authToken).post(
      'medicines',
      {
        'name': medicine.name,
        'frequency': medicine.frequency,
      },
    );

    final extractedData = responseData['data'];
    final newRecord = Medicine.fromJSON(extractedData);

    if (_medicines.length > 0) {
      _medicines.add(newRecord);
    }
    else {
      this.fetchMedicineRecords();
    }

    notifyListeners();

    return newRecord;
  }

  Future<Medicine> editMedicineRecord(Medicine medicine) async {
    final responseData = await http.Request(this.authToken).post(
      'medicines/${medicine.id}?include=schedule',
      {
        'name': medicine.name,
        'frequency': medicine.frequency,
      },
    );

    final extractedData = responseData['data'];
    final updatedRecord = Medicine.fromJSON(extractedData);

    var updatedList = _medicines.map((element) {
      if (element.id == updatedRecord.id) {
        return updatedRecord;
      }

      return element;
    });

    _medicines = [...updatedList];

    notifyListeners();

    return updatedRecord;
  }

  Future<void> removeMedicineRecord(Medicine record) async {
    _medicines.removeWhere((item) => item.id == record.id);
    _schedule.removeWhere(
        (MedicineSchedule sched) => sched.medicine.id == record.id);
    notifyListeners();

    await http.Request(this.authToken).delete('medicines/${record.id}');
  }

  Future<void> fetchScheduleRecords() async {
    if (_schedule.length > 0) {
      return;
    }

    var now = DateTime.now();
    var date = DateTime(now.year, now.month, now.day, 0, 0, 0).toUtc();
    String formattedDate = DateFormat('y-MM-dd H:mm:ss').format(date);

    final responseData = await http.Request(this.authToken).fetch(
      'medicines-schedule/byDay?$formattedDate&include=medicine,intakes',
    );

    final extractedData = responseData['data'];
    final List<MedicineSchedule> data = [];
    extractedData.forEach((item) {
      data.add(MedicineSchedule.fromJSON(item));
    });

    _schedule = data;

    notifyListeners();
  }

  Future<MedicineSchedule> addScheduleRecord(
      MedicineSchedule schedule, Medicine medicine) async {
    final responseData = await http.Request(this.authToken).post(
      'medicines-schedule?include=medicine,intakes',
      {
        'medicineId': medicine.id,
        'intakeTime': DateFormat('y-MM-dd H:mm:ss').format(schedule.intakeTime),
        'periodSpan': schedule.periodSpan,
      },
    );

    final extractedData = responseData['data'];
    final newRecord = MedicineSchedule.fromJSON(extractedData);

    var newData = _medicines.map((Medicine med) {
      if (med.id == medicine.id) {
        med.schedule.add(newRecord);
        med.schedule.sort((MedicineSchedule a, MedicineSchedule b) {
          return a.intakeTime.compareTo(b.intakeTime);
        });
      }

      return med;
    });

    _medicines = [...newData];

    _schedule = [];
    this.fetchScheduleRecords();

    notifyListeners();

    return newRecord;
  }

  Future<MedicineSchedule> editScheduleRecord(
      MedicineSchedule schedule, Medicine medicine) async {
    final responseData = await http.Request(this.authToken).post(
      'medicines-schedule/${schedule.id}?include=medicine,intakes',
      {
        'intakeTime': DateFormat('y-MM-dd H:mm:ss').format(schedule.intakeTime),
        'periodSpan': schedule.periodSpan,
      },
    );

    final extractedData = responseData['data'];
    final updatedRecord = MedicineSchedule.fromJSON(extractedData);

    var newData = _medicines.map((Medicine med) {
      if (med.id == medicine.id) {
        med.schedule.removeWhere(
            (MedicineSchedule sched) => sched.id == updatedRecord.id);
        med.schedule.add(updatedRecord);
        med.schedule.sort((MedicineSchedule a, MedicineSchedule b) {
          return a.intakeTime.compareTo(b.intakeTime);
        });
      }

      return med;
    });

    _medicines = [...newData];

    _schedule = [];
    this.fetchScheduleRecords();

    notifyListeners();

    return updatedRecord;
  }

  Future<void> removeScheduleRecord(MedicineSchedule record) async {
    var newData = _medicines.map((Medicine med) {
      med.schedule
          .removeWhere((MedicineSchedule sched) => sched.id == record.id);
      return med;
    });

    _medicines = [...newData];

    _schedule.removeWhere((MedicineSchedule sched) => sched.id == record.id);

    notifyListeners();

    await http.Request(this.authToken)
        .delete('medicines-schedule/${record.id}');
  }

  Future<MedicineIntake> addIntake(
      MedicineIntake record, MedicineSchedule schedule) async {
        print(schedule.intakeTime);
    final responseData = await http.Request(this.authToken).post(
      'medicines-intake',
      {
        'medicineScheduleId': schedule.id,
        'date': DateFormat('y-MM-dd H:mm:ss').format(schedule.intakeTime.toUtc()),
      },
    );

    final extractedData = responseData['data'];
    final newRecord = MedicineIntake.fromJSON(extractedData);

    var newData = _schedule.map((MedicineSchedule sched) {
      if (sched.id == schedule.id) {
        sched.intakes.add(newRecord);
      }

      return sched;
    });

    _schedule = [...newData];

    notifyListeners();

    return newRecord;
  }

  Future<void> removeIntake(
      MedicineIntake record, MedicineSchedule schedule) async {
    var newSchedule = _schedule.map((MedicineSchedule sched) {
      if (sched.id == schedule.id) {
        sched.intakes
            .removeWhere((MedicineIntake intake) => intake.id == record.id);
      }

      return sched;
    });

    _schedule = [...newSchedule];

    notifyListeners();

    await http.Request(this.authToken).delete('medicines-intake/${record.id}');
  }
}
