// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n/app_localizations.dart';
import '../models/search_parameters.dart';
import '../models/types.dart';
import '../util/responsive.dart';
import 'location_input.dart';

class SearchParameterInput extends StatelessWidget {
  const SearchParameterInput({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<EndpointNotifier>(
              builder: (context, endpoints, child) {
                final fromInput = LocationInput(
                  label: AppLocalizations.of(context)!.from,
                  initialValue: endpoints.from,
                  onSelected: (Station value) {
                    endpoints.setFrom(value);
                  },
                );
                final toInput = LocationInput(
                  label: AppLocalizations.of(context)!.toCapitalized,
                  initialValue: endpoints.to,
                  onSelected: (Station value) {
                    endpoints.setTo(value);
                  },
                );
                if (useNarrowLayout(context)) {
                  return Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: [
                      Column(
                        children: [
                          fromInput,
                          SizedBox(height: 10.0),
                          toInput,
                        ],
                      ),
                      IconButton.outlined(
                        onPressed: () {
                          endpoints.swap();
                        },
                        icon: Icon(Icons.swap_vert),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow),
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: fromInput),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: IconButton(
                        onPressed: () {
                          endpoints.swap();
                        },
                        icon: Icon(Icons.swap_horiz),
                      ),
                    ),
                    Expanded(child: toInput),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _TimeInput(),
                _TimeAnchorSelection(),
                _ModeInput(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeInput extends StatelessWidget {
  const _TimeInput({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeNotifier>(
      builder: (context, time, child) => OutlinedButton.icon(
        onPressed: () async {
          final newTime = await showTimePicker(
            context: context,
            initialTime: time.value,
          );
          if (newTime == null) {
            return;
          }
          time.value = newTime;
        },
        icon: Icon(Icons.access_time),
        label:
            Text(MaterialLocalizations.of(context).formatTimeOfDay(time.value)),
      ),
    );
  }
}

class _TimeAnchorSelection extends StatelessWidget {
  const _TimeAnchorSelection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeAnchorNotifier>(
      builder: (context, anchor, child) => SegmentedButton<TimeAnchor>(
        segments: [
          ButtonSegment<TimeAnchor>(
            value: TimeAnchor.depart,
            label: Text(AppLocalizations.of(context)!.departure),
          ),
          ButtonSegment<TimeAnchor>(
            value: TimeAnchor.arrive,
            label: Text(AppLocalizations.of(context)!.arrival),
          )
        ],
        selected: <TimeAnchor>{anchor.value},
        showSelectedIcon: false,
        onSelectionChanged: (Set<TimeAnchor> newSelection) {
          anchor.value = newSelection.first;
        },
      ),
    );
  }
}

class _ModeInput extends StatelessWidget {
  const _ModeInput({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductNotifier>(builder: (context, product, child) {
      if (useNarrowLayout(context)) {
        return MenuAnchor(
          builder: (context, controller, child) => IconButton.outlined(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: Icon(Icons.directions_railway),
          ),
          menuChildren: [
            buildProductToggle(
              product,
              context,
              Product.highSpeed,
              AppLocalizations.of(context)!.highSpeed,
            ),
            buildProductToggle(
              product,
              context,
              Product.longDistance,
              AppLocalizations.of(context)!.longDistance,
            ),
            buildProductToggle(
              product,
              context,
              Product.regional,
              AppLocalizations.of(context)!.regional,
            ),
          ],
        );
      }
      return SegmentedButton<Product>(
        segments: [
          ButtonSegment(
            value: Product.highSpeed,
            label: Text(AppLocalizations.of(context)!.highSpeed),
          ),
          ButtonSegment(
            value: Product.longDistance,
            label: Text(AppLocalizations.of(context)!.longDistance),
          ),
          ButtonSegment(
            value: Product.regional,
            label: Text(AppLocalizations.of(context)!.regional),
          ),
        ],
        selected: product.value,
        multiSelectionEnabled: true,
        emptySelectionAllowed: false,
        onSelectionChanged: (Set<Product> newSelection) {
          product.value = newSelection;
        },
        showSelectedIcon: true,
      );
    });
  }

  MenuItemButton buildProductToggle(ProductNotifier currentSelection,
      BuildContext context, Product product, String label) {
    return MenuItemButton(
      onPressed: () {
        final newSelection = Set<Product>.from(currentSelection.value);
        if (newSelection.contains(product)) {
          newSelection.remove(product);
        } else {
          newSelection.add(product);
        }
        currentSelection.value = newSelection;
      },
      child: Row(
        children: [
          if (currentSelection.value.contains(product)) Icon(Icons.check),
          Text(label),
        ],
      ),
    );
  }
}
