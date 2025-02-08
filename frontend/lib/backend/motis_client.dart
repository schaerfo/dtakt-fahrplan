import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/types.dart';

class MotisClient {
  final _client = http.Client();

  Future<Iterable<Station>> searchLocation(String query) async {
    if (query.isEmpty) {
      return const Iterable<Station>.empty();
    }
    final uri = Uri(
      scheme: 'https',
      host: 'dtakt-fahrplan.v6.rocks',
      path: 'api/v1/geocode',
      queryParameters: {'text': query},
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      print('Error: HTTP status ${response.statusCode}');
      return const Iterable<Station>.empty();
    }
    final parsed = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    final result = parsed.map((station) {
      return Station.fromJson(station);
    });
    return result;
  }
}
