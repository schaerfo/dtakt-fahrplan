// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'package:dtakt_fahrplan_frontend/util/product_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/journey.dart';
import '../models/types.dart';
import '../util/format_duration.dart';
import 'product_badge.dart';

class JourneyDetails extends StatelessWidget {
  final Journey journey;

  const JourneyDetails(this.journey, {super.key});

  @override
  Widget build(BuildContext context) {
    final legs = <Widget>[];
    if (journey.legs.length == 1) {
      legs.add(_LegDetails(
        journey.legs.first,
        position: _Position.single,
      ));
    } else {
      legs.add(_LegDetails(
        journey.legs.first,
        position: _Position.start,
      ));
      for (var i = 1; i < journey.legs.length - 1; ++i) {
        legs.add(_TransferDetails(
          from: journey.legs.elementAt(i - 1),
          to: journey.legs.elementAt(i),
        ));
        legs.add(_LegDetails(
          journey.legs.elementAt(i),
          position: _Position.middle,
        ));
      }
      legs.add(_TransferDetails(
        from: journey.legs.elementAt(journey.legs.length - 2),
        to: journey.legs.last,
      ));
      legs.add(
        _LegDetails(
          journey.legs.last,
          position: _Position.end,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: legs,
    );
  }
}

enum _Position { single, start, middle, end }

class _LegDetails extends StatefulWidget {
  final Leg leg;
  final _Position pos;

  const _LegDetails(
    this.leg, {
    required _Position position,
    super.key,
  }) : pos = position;

  @override
  State<_LegDetails> createState() => _LegDetailsState();
}

class _LegDetailsState extends State<_LegDetails> {
  var _showIntermediateStops = false;

  @override
  Widget build(BuildContext context) {
    final intermediateStopCount = widget.leg.stops.length - 2;
    final nonStop = intermediateStopCount == 0;
    final durationStr =
        formatDuration(widget.leg.end.difference(widget.leg.start));
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      defaultColumnWidth: IntrinsicColumnWidth(),
      columnWidths: {
        0: FixedColumnWidth(20),
      },
      children: [
        _layoverRow(
          when: widget.leg.start,
          station: widget.leg.from,
          product: widget.leg.product,
          before: widget.pos == _Position.middle || widget.pos == _Position.end
              ? _TargetConnection.transfer
              : _TargetConnection.none,
          after: _TargetConnection.leg,
        ),
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.fill,
              child: CustomPaint(
                painter:
                    _ContinuousPainter(context, product: widget.leg.product),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 10.0),
                Text(durationStr),
                SizedBox(width: 10.0),
                ProductBadge(widget.leg),
                if (widget.leg.headsign != null) ...[
                  SizedBox(width: 10.0),
                  Text(
                      '${AppLocalizations.of(context)!.to} ${widget.leg.headsign}'),
                ],
              ],
            ),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.fill,
              child: CustomPaint(
                painter:
                    _ContinuousPainter(context, product: widget.leg.product),
              ),
            ),
            Row(
              children: [
                nonStop
                    ? Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          AppLocalizations.of(context)!.nonStop,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      )
                    : TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showIntermediateStops = !_showIntermediateStops;
                          });
                        },
                        label: Text(AppLocalizations.of(context)!
                            .nIntermediateStops(intermediateStopCount)),
                        icon: Icon(_showIntermediateStops
                            ? Icons.expand_less
                            : Icons.expand_more),
                        iconAlignment: IconAlignment.end,
                      ),
              ],
            ),
          ],
        ),
        if (_showIntermediateStops)
          for (final currStop
              in widget.leg.stops.take(widget.leg.stops.length - 1).skip(1))
            TableRow(
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.fill,
                  child: CustomPaint(
                    painter: _IntermediateStopPainter(context,
                        product: widget.leg.product),
                  ),
                ),
                Row(
                  children: [
                    Center(
                      child: Text(MaterialLocalizations.of(context)
                          .formatTimeOfDay(
                              TimeOfDay.fromDateTime(currStop.arrival!))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(currStop.station.name),
                    ),
                  ],
                ),
              ],
            ),
        _layoverRow(
          when: widget.leg.end,
          station: widget.leg.to,
          product: widget.leg.product,
          before: _TargetConnection.leg,
          after: widget.pos == _Position.middle || widget.pos == _Position.start
              ? _TargetConnection.transfer
              : _TargetConnection.none,
        ),
      ],
    );
  }

  TableRow _layoverRow({
    required DateTime when,
    required Station station,
    required Product product,
    required _TargetConnection before,
    required _TargetConnection after,
  }) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: CustomPaint(
            painter: _TargetPainter(
              context,
              product: product,
              before: before,
              after: after,
            ),
          ),
        ),
        Row(
          children: [
            SizedBox(width: 5),
            Center(
              child: Text(
                MaterialLocalizations.of(context)
                    .formatTimeOfDay(TimeOfDay.fromDateTime(when)),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                station.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TransferDetails extends StatelessWidget {
  final Leg from;
  final Leg to;

  const _TransferDetails({super.key, required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    final durationStr = formatDuration(to.start.difference(from.end));
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      defaultColumnWidth: IntrinsicColumnWidth(),
      columnWidths: {
        0: FixedColumnWidth(20),
      },
      children: [
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.fill,
              child: CustomPaint(
                painter: _TransferPainter(context),
              ),
            ),
            Icon(Icons.settings_ethernet),
            Text(durationStr),
          ],
        ),
      ],
    );
  }
}

enum _TargetConnection { none, leg, transfer }

const _connectionWidth = 2.0;
const _stopRadius = 3.0;
const _intermediateStopRadius = _stopRadius;
const _timelineRadius = 5.0;
const _timelineWidth = 2 * _timelineRadius;

Color _connectionColor(BuildContext context) =>
    Theme.of(context).colorScheme.onSurfaceVariant;

class _TimelineColors {
  final Color background;
  final Color foreground;
  final Color connection;

  _TimelineColors(BuildContext context, Product product)
      : background =
            backgroundProductColor(Theme.of(context).colorScheme, product),
        foreground =
            foregroundProductColor(Theme.of(context).colorScheme, product),
        connection = _connectionColor(context);
}

class _TargetPainter extends CustomPainter {
  final _TargetConnection before;
  final _TargetConnection after;
  final _TimelineColors _colors;

  _TargetPainter(BuildContext context,
      {required Product product, required this.before, required this.after})
      : _colors = _TimelineColors(context, product);

  @override
  void paint(Canvas canvas, Size size) {
    if (before == _TargetConnection.leg) {
      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height / 2),
        Paint()
          ..color = _colors.background
          ..strokeWidth = _timelineWidth,
      );
    } else if (before == _TargetConnection.transfer) {
      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height / 2),
        Paint()
          ..color = _colors.connection
          ..strokeWidth = _connectionWidth,
      );
    }
    if (after == _TargetConnection.leg) {
      canvas.drawLine(
        Offset(size.width / 2, size.height / 2),
        Offset(size.width / 2, size.height),
        Paint()
          ..color = _colors.background
          ..strokeWidth = _timelineWidth,
      );
    } else if (after == _TargetConnection.transfer) {
      canvas.drawLine(
        Offset(size.width / 2, size.height / 2),
        Offset(size.width / 2, size.height),
        Paint()
          ..color = _colors.connection
          ..strokeWidth = _connectionWidth,
      );
    }
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      _timelineRadius,
      Paint()..color = _colors.background,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      _stopRadius,
      Paint()..color = _colors.foreground,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _ContinuousPainter extends CustomPainter {
  final _TimelineColors _colors;

  _ContinuousPainter(BuildContext context, {required Product product})
      : _colors = _TimelineColors(context, product);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = _colors.background
        ..strokeWidth = _timelineWidth,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _IntermediateStopPainter extends _ContinuousPainter {
  _IntermediateStopPainter(super.context, {required super.product});

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    canvas.drawCircle(
      Offset(size.width / 2.0, size.height / 2.0),
      _intermediateStopRadius,
      Paint()..color = super._colors.foreground,
    );
  }
}

class _TransferPainter extends CustomPainter {
  final Color _color;

  _TransferPainter(BuildContext context) : _color = _connectionColor(context);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = _color
        ..strokeWidth = _connectionWidth,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
