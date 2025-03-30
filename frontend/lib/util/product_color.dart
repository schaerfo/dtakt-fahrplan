import 'package:flutter/material.dart';

import '../models/journey.dart';

Color backgroundProductColor(ColorScheme colorScheme, Product product) {
  switch (product) {
    case Product.highSpeed:
      return colorScheme.primary;
    case Product.longDistance:
      return colorScheme.secondary;
    case Product.regionalFast:
    case Product.regional:
    case Product.suburban:
      return colorScheme.tertiary;
  }
}

Color foregroundProductColor(ColorScheme colorScheme, Product product) {
  switch (product) {
    case Product.highSpeed:
      return colorScheme.onPrimary;
    case Product.longDistance:
      return colorScheme.onSecondary;
    case Product.regionalFast:
    case Product.regional:
    case Product.suburban:
      return colorScheme.onTertiary;
  }
}
