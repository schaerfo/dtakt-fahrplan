import 'package:flutter/material.dart';

class LocationInput extends StatelessWidget {
  final String label;

  const LocationInput({
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
