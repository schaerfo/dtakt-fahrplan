import 'package:flutter/material.dart';
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LocationInput(
              label: "From",
              onSelected: (Station value) {
                Provider.of<EndpointNotifier>(context, listen: false)
                    .setFrom(value);
              },
            ),
            SizedBox(
              width: 50,
            ),
            LocationInput(
              label: "To",
              onSelected: (Station value) {
                Provider.of<EndpointNotifier>(context, listen: false)
                    .setTo(value);
              },
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TimeInput(),
            SizedBox(width: 5),
            _TimeAnchorSelection(),
            SizedBox(width: 5),
            _ModeInput(),
          ],
        ),
      ],
    );
  }
}

class TimeInput extends StatelessWidget {
  const TimeInput({
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
        // TODO use GlobalMaterialLocalizations
        label: Text(DefaultMaterialLocalizations().formatTimeOfDay(time.value)),
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
            label: Text("Departure"),
          ),
          ButtonSegment<TimeAnchor>(
            value: TimeAnchor.arrive,
            label: Text("Arrival"),
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
            label: Text("Long distance"),
          ),
          ButtonSegment(
            value: Mode.regional,
            label: Text("Regional"),
          ),
          ButtonSegment(
            value: Mode.all,
            label: Text("All"),
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
