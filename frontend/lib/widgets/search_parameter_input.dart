import 'package:flutter/material.dart';

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
            _LocationInput(label: "From"),
            SizedBox(
              width: 50,
            ),
            _LocationInput(label: "To"),
          ],
        ),
        SizedBox(height: 20),
        _TimeAnchorSelection(),
      ],
    );
  }
}

class _LocationInput extends StatelessWidget {
  final String label;

  const _LocationInput({
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 400,
      ),
      child: SearchAnchor.bar(
        barHintText: label,
        suggestionsBuilder: (context, controller) => [],
      ),
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
