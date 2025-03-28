// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

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
                painter: _ContinuousPainter(context),
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
                painter: _ContinuousPainter(context),
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
                    painter: _IntermediateStopPainter(context),
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
const _connectionRadius = _connectionWidth / 2;
const _targetPitch = 4.0;
const _targetRadius = 5.0;
const _gap = 3.0;

class _TargetPainter extends CustomPainter {
  final _TargetConnection before;
  final _TargetConnection after;
  final Color _color;

  _TargetPainter(BuildContext context,
      {required this.before, required this.after})
      : _color = Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  void paint(Canvas canvas, Size size) {
    if (before == _TargetConnection.leg) {
      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height / 2 - _targetRadius - _gap),
        Paint()
          ..color = _color
          ..strokeWidth = _connectionWidth,
      );
    } else if (before == _TargetConnection.transfer) {
      final available =
          size.height - _targetRadius - 2 * _gap - 2 * _connectionRadius;
      final count = (available / _targetPitch).ceil();
      final pitch = available / (count - 1);
      final start =
          size.height / 2.0 - _targetRadius - _gap - _connectionRadius;
      for (int i = 0; i < (count / 2.0).floor(); ++i) {
        final y = start - i * pitch;
        canvas.drawCircle(
          Offset(size.width / 2, y),
          _connectionRadius,
          Paint()..color = _color,
        );
      }
    }
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      _targetRadius,
      Paint()
        ..color = _color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      2,
      Paint()..color = _color,
    );
    if (after == _TargetConnection.leg) {
      canvas.drawLine(
        Offset(size.width / 2, size.height / 2 + _targetRadius + _gap),
        Offset(size.width / 2, size.height),
        Paint()
          ..color = _color
          ..strokeWidth = _connectionWidth,
      );
    } else if (after == _TargetConnection.transfer) {
      final available =
          size.height - _targetRadius - 2 * _gap - 2 * _connectionRadius;
      final count = (available / _targetPitch).ceil();
      final pitch = available / (count - 1);
      final start =
          size.height / 2.0 + _targetRadius + _gap + _connectionRadius;
      for (int i = 0; i < (count / 2.0).floor(); ++i) {
        final y = start + i * pitch;
        canvas.drawCircle(
          Offset(size.width / 2, y),
          _connectionRadius,
          Paint()..color = _color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _ContinuousPainter extends CustomPainter {
  final Color _color;

  _ContinuousPainter(
    BuildContext context,
  ) : _color = Theme.of(context).colorScheme.onSurfaceVariant;

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

class _IntermediateStopPainter extends _ContinuousPainter {
  static const _radius = 4.0;

  _IntermediateStopPainter(super.context);

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    canvas.drawCircle(
      Offset(size.width / 2.0, size.height / 2.0),
      _radius,
      Paint()..color = super._color,
    );
  }
}

class _TransferPainter extends CustomPainter {
  final Color _color;

  _TransferPainter(
    BuildContext context,
  ) : _color = Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  void paint(Canvas canvas, Size size) {
    final available = size.height - 2 * _gap - 2 * _connectionRadius;
    final count = (available / _targetPitch).ceil();
    final pitch = available / (count - 1);
    for (int i = 0; i < count; ++i) {
      final y = i * pitch;
      canvas.drawCircle(
        Offset(size.width / 2, y),
        _connectionRadius,
        Paint()..color = _color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
