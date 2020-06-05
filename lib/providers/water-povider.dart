import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../http/request.dart' as http;
import '../models/water.dart';

class WaterProvider with ChangeNotifier {
  List<Water> _today = [];
  List<Water> _specificDate = [];
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

  List<Water> get specificDate {
    var list = [..._specificDate];
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

  Future<void> fetchAndSetByDateWaterRecords(DateTime searchDate) async {
    if (_today.length > 0 && searchDate == null) {
      return;
    }

    var date = DateTime.now();
    if (searchDate != null) date = searchDate;
    date = new DateTime(date.year, date.month, date.day).toUtc();
    var formattedDate = DateFormat('y-MM-dd H:mm:ss').format(date);

    final responseData = await http.Request(authToken)
        .fetch('water-supplies/byDay?date=$formattedDate');

    final extractedData = responseData['data'];
    final List<Water> data = [];
    extractedData.forEach((item) {
      data.add(Water.fromJSON(item));
    });

    if (searchDate == null) {
      _today = data;
    } else {
      _specificDate = data;
    }
    notifyListeners();
  }

  Future<void> fetchAndSetWaterRecords() async {
    if (_all.length > 0) {
      return;
    }

    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: 6))
        .toUtc();
    var formattedDate = DateFormat('y-MM-dd H:mm:ss').format(date);

    var endDate = DateTime(now.year, now.month, now.day + 1).toUtc();
    var formattedEndDate = DateFormat('y-MM-dd H:mm:ss').format(endDate);

    final responseData = await http.Request(authToken)
        .fetch('water-supplies/groupByDays?startDate=$formattedDate&endDate=$formattedEndDate');
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
    final newRecord = Water.fromJSON(extractedData);

    final now = DateTime.now();
    if (newRecord.date.year == now.year &&
        newRecord.date.month == now.month &&
        newRecord.date.day == now.day) {
      _today.add(newRecord);
    }

    // update chart data
    var chartData = _all.map((Water item) {
      if (newRecord.date.year == item.date.year &&
          newRecord.date.month == item.date.month &&
          newRecord.date.day == item.date.day) {
        return Water(amount: item.amount + newRecord.amount, date: item.date);
      }

      return item;
    });

    _all = [...chartData];

    notifyListeners();
  }

  Future<void> removeWaterRecord(Water record) async {
    _today.removeWhere((item) => item.id == record.id);
    _specificDate.removeWhere((item) => item.id == record.id);

    // update chart data
    var chartData = _all.map((Water item) {
      if (record.date.year == item.date.year &&
          record.date.month == item.date.month &&
          record.date.day == item.date.day) {
        return Water(amount: item.amount - record.amount, date: item.date);
      }

      return item;
    });

    _all = [...chartData];

    notifyListeners();

    await http.Request(this.authToken).delete('water-supplies/${record.id}');
  }
}
