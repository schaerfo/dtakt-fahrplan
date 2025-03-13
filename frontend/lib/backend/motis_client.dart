// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/journey.dart';
import '../models/types.dart';
import '../util/environment.dart';

class MotisClient {
  final _client = http.Client();

  Future<Iterable<Station>> searchLocation(String query) async {
    if (query.isEmpty) {
      return const Iterable<Station>.empty();
    }
    final uri = Uri(
      scheme: 'https',
      host: Environment.motisHost,
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

  Future<Iterable<Journey>> searchJourneys(Station from, Station to,
      TimeOfDay time, TimeAnchor timeAnchor, Mode mode) async {
    // Since the the schedule is the same on every day, the date does not matter
    final dateTime = DateTime.utc(2025, 2, 16, time.hour, time.minute);
    final uri = Uri(
      scheme: 'https',
      host: Environment.motisHost,
      path: 'api/v1/plan',
      queryParameters: {
        'fromPlace': from.id,
        'toPlace': to.id,
        'time': dateTime.toIso8601String(),
        'arriveBy': (timeAnchor == TimeAnchor.arrive).toString(),
        if (mode != Mode.all)
          'transitModes': mode == Mode.longDistance
              ? 'HIGHSPEED_RAIL,LONG_DISTANCE'
              : 'REGIONAL_RAIL,REGIONAL_FAST_RAIL,METRO',
      },
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      print('Error: HTTP status ${response.statusCode}');
      return const Iterable<Journey>.empty();
    }
    final parsed =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final result = (parsed['itineraries'] as List)
        .cast<Map<String, dynamic>>()
        .map(_convertJourney);
    return result;
  }

  Journey _convertJourney(Map<String, dynamic> journey) {
    return Journey((journey['legs'] as List)
        .cast<Map<String, dynamic>>()
        .where((leg) => leg['mode'] != 'WALK')
        .map(_convertLeg));
  }

  Leg _convertLeg(Map<String, dynamic> leg) {
    final firstStop = _convertStop(leg['from']);
    final lastStop = _convertStop(leg['to']);
    final intermediate = (leg['intermediateStops'] as List)
        .cast<Map<String, dynamic>>()
        .map(_convertStop);
    return Leg(
      [firstStop].followedBy(intermediate).followedBy([lastStop]),
      id: leg['tripId'],
      lineName: leg['routeShortName'],
      product: _convertProduct(leg['mode']),
    );
  }

  Stop _convertStop(Map<String, dynamic> stop) {
    return Stop(
      station: Station.fromJson(stop),
      arrival:
          stop.containsKey('arrival') ? DateTime.parse(stop['arrival']) : null,
      departure: stop.containsKey('departure')
          ? DateTime.parse(stop['departure'])
          : null,
    );
  }

  _convertProduct(String product) {
    switch (product) {
      case 'METRO':
        return Product.suburban;
      case 'REGIONAL_RAIL':
        return Product.regional;
      case 'REGIONAL_FAST_RAIL':
        return Product.regionalFast;
      case 'LONG_DISTANCE':
        return Product.longDistance;
      case 'HIGHSPEED_RAIL':
        return Product.highSpeed;
      case 'RAIL':
        return Product.regional;
    }
  }
}
