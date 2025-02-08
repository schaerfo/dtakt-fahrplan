import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../backend/motis_client.dart';
import '../models/journey.dart';
import '../models/search_parameters.dart';
import '../models/types.dart';

class ResultDisplay extends StatelessWidget {
  const ResultDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final endpoints = Provider.of<EndpointNotifier>(context);
    final timeAnchor = Provider.of<TimeAnchorNotifier>(context);
    final time = Provider.of<TimeNotifier>(context);
    final mode = Provider.of<ModeNotifier>(context);
    final bothEndpointsSet = endpoints.from != null && endpoints.to != null;
    if (bothEndpointsSet) {
      return Expanded(
        child: ResultList(
          endpoints.from!,
          endpoints.to!,
          time.value,
          timeAnchor.value,
          mode.value,
        ),
      );
    }
    return SizedBox.shrink();
  }
}

class ResultList extends StatefulWidget {
  final Station from;
  final Station to;
  final TimeOfDay time;
  final TimeAnchor timeAnchor;
  final Mode mode;

  const ResultList(
    this.from,
    this.to,
    this.time,
    this.timeAnchor,
    this.mode, {
    super.key,
  });

  @override
  State<ResultList> createState() => _ResultListState();
}

class _ResultListState extends State<ResultList> {
  late Future<Iterable<Journey>> _result;
  final _client = MotisClient();

  Future<Iterable<Journey>> _fetchJourneys() async {
    final results = await _client.searchJourneys(
      widget.from,
      widget.to,
      widget.time,
      widget.timeAnchor,
      widget.mode,
    );
    return results;
  }

  @override
  void initState() {
    super.initState();
    _result = _fetchJourneys();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _result,
      builder: (context, snapshot) => Placeholder(),
    );
  }
}
