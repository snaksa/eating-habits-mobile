import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../http/request.dart' as http;
import '../exceptions/http_exception.dart';
import '../models/user.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  Timer _authTimer;
  User _me;

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

  User get me {
    if (_me == null) {
      return User();
    }
    return _me;
  }

  Future<void> fetchUserDetails() async {
    if (_me != null) {
      return;
    }

    final responseData = await http.Request(_token).fetch('users/me');
    final extractedData = responseData['data'];
    _me = User.fromJSON(extractedData);

    final prefs = await SharedPreferences.getInstance();
    final userDetails = json.encode(extractedData);
    prefs.setString('userDetails', userDetails);

    notifyListeners();
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

      await this.fetchUserDetails();

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

  Future<void> refresh(String token) async {
    final url = 'users/refresh';
    try {
      final responseData = await http.Request(token).fetch(url);

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

      await this.fetchUserDetails();

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

  Future<void> editUser(Map<String, dynamic> formData) async {
    final url = 'users/${_me.id}';
    try {
      final responseData = await http.Request(this.token).post(url, formData);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      var extractedData = responseData['data'];
      _me = User.fromJSON(extractedData);

      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userDetails = json.encode(extractedData);
      prefs.setString('userDetails', userDetails);
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
    await this.refresh(_token);

    if (!prefs.containsKey('userDetails')) {
      await this.fetchUserDetails();
    } else {
      final extractedUserDetails =
          json.decode(prefs.getString('userDetails')) as Map<String, Object>;
      _me = User.fromJSON(extractedUserDetails);
    }

    notifyListeners();

    return true;
  }

  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    _me = null;

    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

    notifyListeners();
  }
}
