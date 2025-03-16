// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'types.dart';

enum Product {
  highSpeed,
  longDistance,
  regional,
}

class Journey {
  final List<Leg> _legs;
  Iterable<Leg> get legs => _legs;

  Station get from => _legs.first.from;
  DateTime get start => _legs.first.start;
  Station get to => _legs.last.to;
  DateTime get end => _legs.last.end;
  int get transferCount => _legs.length - 1;

  Journey(Iterable<Leg> legs) : _legs = List<Leg>.of(legs);
}

class Leg {
  final List<Stop> _stops;
  Iterable<Stop> get stops => _stops;

  String id;
  String lineName;
  Product product;
  String? headsign;

  Station get from => _stops.first.station;
  DateTime get start => _stops.first.departure!;
  Station get to => _stops.last.station;
  DateTime get end => _stops.last.arrival!;

  Leg(
    Iterable<Stop> stops, {
    required this.id,
    required this.lineName,
    required this.product,
    this.headsign,
  }) : _stops = List<Stop>.of(stops);
}

class Stop {
  final Station station;
  final DateTime? arrival;
  final DateTime? departure;

  const Stop({required this.station, this.departure, this.arrival});
}
