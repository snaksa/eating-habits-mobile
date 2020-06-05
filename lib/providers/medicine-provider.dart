import 'package:eating_habits_mobile/models/medicine-schedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../http/request.dart' as http;
import '../models/medicine.dart';

class MedicineProvider with ChangeNotifier {
  List<Medicine> _medicines = [];

  final String authToken;

  MedicineProvider(this.authToken, this._medicines);

  List<Medicine> get medicines {
    var list = [..._medicines];
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

  Future<void> addMedicineRecord(Medicine medicine) async {
    final responseData = await http.Request(this.authToken).post(
      'medicines',
      {
        'name': medicine.name,
        'frequency': medicine.frequency,
      },
    );

    final extractedData = responseData['data'];
    final newRecord = Medicine.fromJSON(extractedData);

    _medicines.add(newRecord);

    notifyListeners();
  }

  Future<void> editMedicineRecord(Medicine medicine) async {
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
  }

  Future<void> removeMedicineRecord(Medicine record) async {
    _medicines.removeWhere((item) => item.id == record.id);
    notifyListeners();

    await http.Request(this.authToken).delete('medicines/${record.id}');
  }

  Future<MedicineSchedule> addScheduleRecord(
      MedicineSchedule schedule, Medicine medicine) async {
    final responseData = await http.Request(this.authToken).post(
      'medicines-schedule',
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

    notifyListeners();

    return newRecord;
  }


  Future<void> removeScheduleRecord(MedicineSchedule record) async {
    var newData = _medicines.map((Medicine med) {
      med.schedule.removeWhere((MedicineSchedule sched) => sched.id == record.id);
      return med;
    });

    _medicines = [...newData];

    notifyListeners();

    await http.Request(this.authToken).delete('medicines-schedule/${record.id}');
  }
}
