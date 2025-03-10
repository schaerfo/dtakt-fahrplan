// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/search_parameters.dart';
import '../models/types.dart';
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
              builder: (context, endpoints, child) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LocationInput(
                    label: AppLocalizations.of(context)!.from,
                    initialValue: endpoints.from,
                    onSelected: (Station value) {
                      endpoints.setFrom(value);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: IconButton(
                      onPressed: () {
                        endpoints.swap();
                      },
                      icon: Icon(Icons.swap_horiz),
                    ),
                  ),
                  LocationInput(
                    label: AppLocalizations.of(context)!.to,
                    initialValue: endpoints.to,
                    onSelected: (Station value) {
                      endpoints.setTo(value);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              alignment: WrapAlignment.center,
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
    return Consumer<ModeNotifier>(
      builder: (context, mode, child) => SegmentedButton<Mode>(
        segments: [
          ButtonSegment(
            value: Mode.longDistance,
            label: Text(AppLocalizations.of(context)!.longDistance),
          ),
          ButtonSegment(
            value: Mode.regional,
            label: Text(AppLocalizations.of(context)!.regional),
          ),
          ButtonSegment(
            value: Mode.all,
            label: Text(AppLocalizations.of(context)!.all),
          ),
        ],
        selected: <Mode>{mode.value},
        onSelectionChanged: (Set<Mode> newSelection) {
          mode.value = newSelection.first;
        },
        showSelectedIcon: false,
      ),
    );
  }
}
