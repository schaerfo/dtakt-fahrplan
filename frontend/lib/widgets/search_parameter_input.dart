import 'package:dtakt_fahrplan_frontend/models/search_parameters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            LocationInput(label: "From"),
            SizedBox(
              width: 50,
            ),
            LocationInput(label: "To"),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: 8, minute: 00),
                );
              },
              icon: Icon(Icons.access_time),
              label: Text("8:00"),
            ),
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

class _TimeAnchorSelection extends StatelessWidget {
  const _TimeAnchorSelection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchParameters>(
      builder: (context, parameters, child) => SegmentedButton<TimeAnchor>(
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
        selected: <TimeAnchor>{parameters.anchor},
        showSelectedIcon: false,
        onSelectionChanged: (Set<TimeAnchor> newSelection) {
          parameters.anchor = newSelection.first;
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
    return Consumer<SearchParameters>(
      builder: (context, parameters, child) => SegmentedButton<Mode>(
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
        selected: <Mode>{parameters.mode},
        onSelectionChanged: (Set<Mode> newSelection) {
          parameters.mode = newSelection.first;
        },
        showSelectedIcon: false,
      ),
    );
  }
}
