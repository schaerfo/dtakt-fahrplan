// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

String formatDuration(Duration value) {
  return '${value.inHours != 0 ? '${value.inHours}h ' : ' '}${value.inMinutes - 60 * value.inHours}min';
}
