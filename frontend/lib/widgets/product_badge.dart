// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';

import '../models/journey.dart';
import '../util/product_color.dart';

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
        color:
            backgroundProductColor(Theme.of(context).colorScheme, leg.product),
      ),
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Text(
        leg.lineName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foregroundProductColor(
              Theme.of(context).colorScheme, leg.product),
        ),
      ),
    );
  }
}
