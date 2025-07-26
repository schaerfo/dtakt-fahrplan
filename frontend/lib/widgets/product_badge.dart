// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';

import '../models/journey.dart';
import '../util/product_color.dart';

class ProductBadge extends StatelessWidget {
  final Leg leg;
  final void Function()? onPressed;

  const ProductBadge(this.leg, {super.key}) : onPressed = null;

  const ProductBadge.button(this.leg, {super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final label = Text(
      leg.lineName,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color:
            foregroundProductColor(Theme.of(context).colorScheme, leg.product),
      ),
    );
    final backgroundColor =
        backgroundProductColor(Theme.of(context).colorScheme, leg.product);
    if (onPressed != null) {
      return TextButton(
        style: TextButton.styleFrom(backgroundColor: backgroundColor),
        onPressed: onPressed,
        child: label,
      );
    }
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // have semi-circles on the left and right edges
        borderRadius: BorderRadius.circular(100),
        color: backgroundColor,
      ),
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: label,
    );
  }
}
