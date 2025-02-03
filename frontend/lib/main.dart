import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  static const _seedColor = Colors.indigo;

  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(colorSchemeSeed: _seedColor),
      darkTheme: ThemeData(
        colorSchemeSeed: _seedColor,
        brightness: Brightness.dark,
      ),
      home: const Scaffold(
        body: Center(
          child: Column(
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
              TimeAnchorSelection(),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationInput extends StatelessWidget {
  final String label;

  const LocationInput({
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      barHintText: label,
      suggestionsBuilder: (context, controller) => [],
    );
  }
}

enum TimeAnchor { depart, arrive }

class TimeAnchorSelection extends StatefulWidget {
  const TimeAnchorSelection({
    super.key,
  });

  @override
  State<TimeAnchorSelection> createState() => _TimeAnchorSelectionState();
}

class _TimeAnchorSelectionState extends State<TimeAnchorSelection> {
  TimeAnchor _selection = TimeAnchor.depart;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TimeAnchor>(
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
      selected: <TimeAnchor>{_selection},
      showSelectedIcon: false,
      onSelectionChanged: (Set<TimeAnchor> newSelection) {
        setState(() {
          _selection = newSelection.first;
        });
      },
    );
  }
}
