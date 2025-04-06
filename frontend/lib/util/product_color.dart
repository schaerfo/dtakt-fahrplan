import 'package:flutter/material.dart';

import '../models/types.dart';

Color backgroundProductColor(ColorScheme colorScheme, Product product) {
  switch (product) {
    case Product.highSpeed:
      return colorScheme.primary;
    case Product.longDistance:
      return colorScheme.secondary;
    case Product.regional:
      return colorScheme.tertiary;
  }
}

Color foregroundProductColor(ColorScheme colorScheme, Product product) {
  switch (product) {
    case Product.highSpeed:
      return colorScheme.onPrimary;
    case Product.longDistance:
      return colorScheme.onSecondary;
    case Product.regional:
      return colorScheme.onTertiary;
  }
}
