import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../http/request.dart' as http;
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
    if (_today.length > 0) {
      return;
    }

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
    if (_all.length > 0) {
      return;
    }

    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: 6))
        .toUtc();
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

    if (_today.length == 0) {
      _all = [];
    } else {
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
    }

    notifyListeners();

    await http.Request(this.authToken).delete('water-supplies/${record.id}');
  }
}
