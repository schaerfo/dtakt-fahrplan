// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';

import '../models/journey.dart';

class ProductBadge extends StatelessWidget {
  final Leg leg;

  const ProductBadge(this.leg, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // have semi-circles on the left and right edges
        borderRadius: BorderRadius.circular(100),
        color: _colorForMode(Theme.of(context).colorScheme, leg.product),
      ),
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Text(
        leg.lineName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: _textColorForMode(Theme.of(context).colorScheme, leg.product),
        ),
      ),
    );
  }

  Color _colorForMode(ColorScheme colorScheme, Product product) {
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

  Color _textColorForMode(ColorScheme colorScheme, Product product) {
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
}
