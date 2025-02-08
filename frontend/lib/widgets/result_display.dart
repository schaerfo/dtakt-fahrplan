import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/search_parameters.dart';

class ResultDisplay extends StatelessWidget {
  const ResultDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final endpoints = Provider.of<EndpointNotifier>(context);
    final bothEndpointsSet = endpoints.from != null && endpoints.to != null;
    if (bothEndpointsSet) {
      return Expanded(
        child: Placeholder(),
      );
    }
    return SizedBox.shrink();
  }
}
