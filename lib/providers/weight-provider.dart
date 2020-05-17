import 'package:eating_habits_mobile/http/request.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weight.dart';

class WeightProvider with ChangeNotifier {
  List<Weight> _items = [];

  final String authToken;

  WeightProvider(this.authToken, this._items);

  List<Weight> get items {
    var list = [..._items];
    list.sort((Weight a, Weight b) {
      return b.date.compareTo(a.date);
    });

    return list;
  }

  Future<void> fetchAndSetWeightRecords() async {
    final responseData = await http.Request(authToken).fetch('weights');

    final extractedData = responseData['data'];
    final List<Weight> data = [];
    extractedData.forEach((item) {
      data.add(Weight.fromJSON(item));
    });

    _items = data;
    notifyListeners();
  }

  Future<void> addWeightRecord(Weight weight) async {
    final responseData = await http.Request(this.authToken).post(
      'weights',
      {
        'date': DateFormat('y-MM-dd H:mm:ss').format(weight.date),
        'weight': weight.weight,
      },
    );

    final extractedData = responseData['data'];
    _items.add(Weight.fromJSON(extractedData));

    notifyListeners();
  }

  Future<void> removeWeightRecord(int id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();

    await http.Request(this.authToken).delete('weights/$id');
  }
}
