// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

class Environment {
  static const imprintAddress = String.fromEnvironment("IMPRINT_ADDRESS");
  static const imprintEmail = String.fromEnvironment("IMPRINT_EMAIL");
  static const motisHost =
      String.fromEnvironment('MOTIS_HOST', defaultValue: 'dtakt-fahrplan.de');
}
