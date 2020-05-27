import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../exceptions/http_exception.dart';

class Request {
  String baseUrl;
  final String _authToken;

  Request(this._authToken) {
    this.baseUrl = DotEnv().env['API_URL'];
  }

  Future<Map<String, dynamic>> fetch(String resource) async {
    var response = await http.get(
      '${this.baseUrl}$resource',
      headers:
          this._authToken != null ? {'Authorization': this._authToken} : {},
    );

    final data = json.decode(response.body) as Map<String, dynamic>;
    this._handleError(data);

    return data;
  }

  Future<Map<String, dynamic>> post(
      String resource, Map<String, dynamic> body) async {
    var response = await http.post(
      '${this.baseUrl}$resource',
      headers:
          this._authToken != null ? {'Authorization': this._authToken} : {},
      body: json.encode(body),
    );

    final data = json.decode(response.body) as Map<String, dynamic>;
    this._handleError(data);

    return data;
  }

  void _handleError(Map<String, dynamic> data) {
    if (data == null) {
      throw HttpException('Could not load data');
    }

    if (data['error'] != null) {
      throw HttpException(data['error']['message'], data['error']['status']);
    }
  }

  Future<Map<String, dynamic>> delete(String resource) async {
    var response = await http.delete(
      '${this.baseUrl}$resource',
      headers:
          this._authToken != null ? {'Authorization': this._authToken} : {},
    );

    final data = json.decode(response.body) as Map<String, dynamic>;
    this._handleError(data);

    return data;
  }
}
