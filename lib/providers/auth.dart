import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import '../http/request.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../exceptions/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    final url = 'users/login';
    try {
      final responseData = await http.Request(null).post(
        url,
        {
          'username': email,
          'password': password,
        },
      );

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      var data = responseData['data'];

      _token = data['token'];

      _expiryDate = DateTime.now().add(
        Duration(
          seconds: data['expiresIn'],
        ),
      );

      // logout user when token expires
      _autoLogout();

      notifyListeners();

      // save in device memory
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> register(
      String email, String password, String confirmPassword) async {
    final url = 'users';
    try {
      final responseData = await http.Request(null).post(
        url,
        {
          'username': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      var data = responseData['data'];

      _token = data['token'];

      _expiryDate = DateTime.now().add(
        Duration(
          seconds: data['expiresIn'],
        ),
      );

      // logout user when token expires
      _autoLogout();

      notifyListeners();

      // save in device memory
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );

      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  // try auto login on app start
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'];
    _expiryDate = expiryDate;
    notifyListeners();

    _autoLogout();

    // TO DO: set to true
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
