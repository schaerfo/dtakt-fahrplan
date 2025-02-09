import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
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
      builder: (context, snapshot) => snapshot.hasData
          ? ListView.builder(
              itemBuilder: (context, index) {
                final journey = snapshot.data!.elementAt(index);
                return _JourneyDisplay(journey: journey);
              },
              itemCount: snapshot.data!.length,
            )
          : SizedBox(),
    );
  }
}

class _JourneyDisplay extends StatelessWidget {
  const _JourneyDisplay({
    super.key,
    required this.journey,
  });

  final Journey journey;

  @override
  Widget build(BuildContext context) {
    final start = intl.DateFormat.Hm().format(journey.start);
    final end = intl.DateFormat.Hm().format(journey.end);
    final duration = journey.end.difference(journey.start);
    final durationStr =
        '${duration.inHours}h ${duration.inMinutes - 60 * duration.inHours}min';
    final transferStr = journey.transferCount > 0
        ? '${journey.transferCount} transfer${journey.transferCount > 1 ? 's' : ''}'
        : 'direct';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$start - $end | $durationStr | $transferStr'),
            _LegSequenceDisplay(
              legs: journey.legs,
            ),
            Row(
              children: [
                Text(journey.from.name),
                Spacer(),
                Text(journey.to.name),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegSequenceDisplay extends StatelessWidget {
  const _LegSequenceDisplay({
    super.key,
    required this.legs,
  });

  final Iterable<Leg> legs;

  @override
  Widget build(BuildContext context) {
    final segments = <Widget>[_LegSegment(legs.first)];
    for (var i = 1; i < legs.length; ++i) {
      segments.add(_TransferSegment(legs.elementAt(i - 1), legs.elementAt(i)));
      segments.add(_LegSegment(legs.elementAt(i)));
    }
    return Row(
      children: segments,
    );
  }
}

class _TransferSegment extends StatelessWidget {
  final Leg from;
  final Leg to;

  const _TransferSegment(this.from, this.to);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: to.start.difference(from.end).inMinutes,
      child: SizedBox(),
    );
  }
}

class _LegSegment extends StatelessWidget {
  final Leg leg;

  const _LegSegment(this.leg);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: leg.end.difference(leg.start).inMinutes,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // have semi-circles on the left and right edges
          borderRadius: BorderRadius.circular(100),
          color: _colorForMode(Theme.of(context).colorScheme, leg.product),
        ),
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        child: Text(
          leg.lineName,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color:
                _textColorForMode(Theme.of(context).colorScheme, leg.product),
          ),
        ),
      ),
    );
  }

  Color _colorForMode(ColorScheme colorScheme, Product product) {
    switch (product) {
      case Product.highSpeed:
        return colorScheme.primary;
      case Product.longDistance:
        return colorScheme.secondary;
      case Product.regionalFast:
      case Product.regional:
      case Product.suburban:
        return colorScheme.tertiary;
    }
  }

  Color _textColorForMode(ColorScheme colorScheme, Product product) {
    switch (product) {
      case Product.highSpeed:
        return colorScheme.onPrimary;
      case Product.longDistance:
        return colorScheme.onSecondary;
      case Product.regionalFast:
      case Product.regional:
      case Product.suburban:
        return colorScheme.onTertiary;
    }
  }
}
