// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';

// Below this width, the mode selection does not fit in a single line in German localization
const narrowLayoutBreakPoint = 495.0;

bool useNarrowLayout(BuildContext context) =>
    MediaQuery.of(context).size.width < narrowLayoutBreakPoint;
