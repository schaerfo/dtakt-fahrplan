import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../backend/motis_client.dart';
import '../models/journey.dart';
import '../models/search_parameters.dart';
import '../models/types.dart';
import 'journey_details.dart';
import 'product_badge.dart';

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

class _JourneyDisplay extends StatefulWidget {
  const _JourneyDisplay({
    super.key,
    required this.journey,
  });

  final Journey journey;

  @override
  State<_JourneyDisplay> createState() => _JourneyDisplayState();
}

class _JourneyDisplayState extends State<_JourneyDisplay> {
  var _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final start = intl.DateFormat.Hm().format(widget.journey.start);
    final end = intl.DateFormat.Hm().format(widget.journey.end);
    final duration = widget.journey.end.difference(widget.journey.start);
    final durationStr =
        '${duration.inHours}h ${duration.inMinutes - 60 * duration.inHours}min';
    final transferStr = widget.journey.transferCount > 0
        ? '${widget.journey.transferCount} transfer${widget.journey.transferCount > 1 ? 's' : ''}'
        : 'direct';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          setState(() {
            _showDetails = !_showDetails;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$start - $end | $durationStr | $transferStr'),
              _LegSequenceDisplay(
                legs: widget.journey.legs,
              ),
              Row(
                children: [
                  Text(widget.journey.from.name),
                  Spacer(),
                  Text(widget.journey.to.name),
                ],
              ),
              if (_showDetails) ...[
                Divider(),
                JourneyDetails(widget.journey),
              ],
            ],
          ),
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
    final items = <(TableColumnWidth, Widget)>[];
    items.add(_legSegment(legs.first));
    for (var i = 1; i < legs.length; ++i) {
      items.add(
          _transferSegment(legs.elementAt(i - 1), legs.elementAt(i), context));
      items.add(_legSegment(legs.elementAt(i)));
    }
    return Table(
      columnWidths: Map.fromEntries(items.indexed
          .map((indexedItem) => MapEntry(indexedItem.$1, indexedItem.$2.$1))),
      children: [
        TableRow(
          children: items.map((item) => item.$2).toList(growable: false),
        )
      ],
    );
  }

  static (TableColumnWidth, Widget) _legSegment(Leg leg) {
    return (
      FlexColumnWidth(leg.end.difference(leg.start).inMinutes.toDouble()),
      ProductBadge(leg),
    );
  }

  static (TableColumnWidth, Widget) _transferSegment(
      Leg from, Leg to, BuildContext context) {
    return (
      FlexColumnWidth(to.start.difference(from.end).inMinutes.toDouble()),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.fill,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: CustomPaint(
            painter: _TransferDotsPainter(context),
          ),
        ),
      ),
    );
  }
}

class _TransferDotsPainter extends CustomPainter {
  static const _targetPitch = 6.0;
  static const _radius = 1.5;
  BuildContext context;

  _TransferDotsPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final count = ((size.width - 2 * _radius) / _targetPitch).ceil();
    final pitch = (size.width - 2 * _radius) / (count - 1);
    for (int i = 0; i < count; ++i) {
      final x = pitch == double.infinity ? _radius : i * pitch + _radius;
      canvas.drawCircle(
        Offset(x, size.height / 2),
        _radius,
        Paint()..color = Theme.of(context).colorScheme.onSurface,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
