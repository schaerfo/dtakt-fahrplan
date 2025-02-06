import 'package:flutter/material.dart';

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

enum _TimeAnchor { depart, arrive }

class _TimeAnchorSelection extends StatefulWidget {
  const _TimeAnchorSelection({
    super.key,
  });

  @override
  State<_TimeAnchorSelection> createState() => _TimeAnchorSelectionState();
}

class _TimeAnchorSelectionState extends State<_TimeAnchorSelection> {
  _TimeAnchor _selection = _TimeAnchor.depart;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_TimeAnchor>(
      segments: [
        ButtonSegment<_TimeAnchor>(
          value: _TimeAnchor.depart,
          label: Text("Departure"),
        ),
        ButtonSegment<_TimeAnchor>(
          value: _TimeAnchor.arrive,
          label: Text("Arrival"),
        )
      ],
      selected: <_TimeAnchor>{_selection},
      showSelectedIcon: false,
      onSelectionChanged: (Set<_TimeAnchor> newSelection) {
        setState(() {
          _selection = newSelection.first;
        });
      },
    );
  }
}

enum _Mode { longDistance, regional, all }

class _ModeInput extends StatefulWidget {
  const _ModeInput({
    super.key,
  });

  @override
  State<_ModeInput> createState() => _ModeInputState();
}

class _ModeInputState extends State<_ModeInput> {
  _Mode _mode = _Mode.all;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_Mode>(
      segments: [
        ButtonSegment(
          value: _Mode.longDistance,
          label: Text("Long distance"),
        ),
        ButtonSegment(
          value: _Mode.regional,
          label: Text("Regional"),
        ),
        ButtonSegment(
          value: _Mode.all,
          label: Text("All"),
        ),
      ],
      selected: <_Mode>{_mode},
      onSelectionChanged: (Set<_Mode> newSelection) {
        setState(() {
          _mode = newSelection.first;
        });
      },
      showSelectedIcon: false,
    );
  }
}
