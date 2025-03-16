// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

enum TimeAnchor { depart, arrive }

enum Mode { longDistance, regional, all }

enum Product {
  highSpeed,
  longDistance,
  regional,
}

class Station {
  String id;
  String name;

  Station({
    required this.id,
    required this.name,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String id,
        'name': String name,
      } =>
        Station(id: id, name: name),
      {
        'stopId': String id,
        'name': String name,
      } =>
        Station(id: id, name: name),
      _ => throw const FormatException('Failed to load station'),
    };
  }
}
