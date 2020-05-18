import 'package:eating_habits_mobile/http/request.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/water.dart';

class WaterProvider with ChangeNotifier {
  List<Water> _today = [];
  List<Water> _all = [];

  final String authToken;

  WaterProvider(this.authToken, this._today, this._all);

  List<Water> get today {
    var list = [..._today];
    list.sort((Water a, Water b) {
      return a.date.compareTo(b.date);
    });

    return list;
  }

  List<Water> get all {
    var list = [..._all];
    list.sort((Water a, Water b) {
      return b.date.compareTo(a.date);
    });

    return list;
  }

  Future<void> fetchAndSetTodayWaterRecords() async {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day).toUtc();
    var formattedDate = DateFormat('y-MM-dd H:mm:ss').format(date);

    final responseData = await http.Request(authToken)
        .fetch('water-supplies/byDay?date=$formattedDate');

    final extractedData = responseData['data'];
    final List<Water> data = [];
    extractedData.forEach((item) {
      data.add(Water.fromJSON(item));
    });

    _today = data;
    notifyListeners();
  }

  Future<void> fetchAndSetWaterRecords() async {
    DateTime now = DateTime.now();
    DateTime date =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: 6)).toUtc();
    var formattedDate = DateFormat('y-MM-dd H:mm:ss').format(date);

    final responseData = await http.Request(authToken)
        .fetch('water-supplies/groupByDays?startDate=$formattedDate');
    final extractedData = responseData['data'];
    final List<Water> data = [];
    extractedData.forEach((item) {
      data.add(Water.fromJSON(item));
    });

    _all = data;
    notifyListeners();
  }

  Future<void> addWaterRecord(Water water) async {
    final responseData = await http.Request(this.authToken).post(
      'water-supplies',
      {
        'date': DateFormat('y-MM-dd H:mm:ss').format(water.date),
        'amount': water.amount,
      },
    );

    final extractedData = responseData['data'];
    _today.add(Water.fromJSON(extractedData));

    notifyListeners();
  }

  Future<void> removeWaterRecord(int id) async {
    _today.removeWhere((item) => item.id == id);
    notifyListeners();

    await http.Request(this.authToken).delete('water-supplies/$id');
  }
}
