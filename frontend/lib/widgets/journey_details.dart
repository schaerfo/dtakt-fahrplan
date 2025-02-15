import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../models/journey.dart';

class JourneyDetails extends StatelessWidget {
  final Journey journey;

  const JourneyDetails(this.journey, {super.key});

  @override
  Widget build(BuildContext context) {
    return journey.legs.length == 1
        ? _LegDetails(
            journey.legs.first,
            position: _Position.single,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegDetails(
                journey.legs.first,
                position: _Position.start,
              ),
              for (final currLeg
                  in journey.legs.take(journey.legs.length - 1).skip(1))
                _LegDetails(
                  currLeg,
                  position: _Position.middle,
                ),
              _LegDetails(journey.legs.last, position: _Position.end),
            ],
          );
  }
}

enum _Position { single, start, middle, end }

class _LegDetails extends StatelessWidget {
  final Leg leg;
  final _Position pos;

  const _LegDetails(
    this.leg, {
    required _Position position,
    super.key,
  }) : pos = position;

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      defaultColumnWidth: IntrinsicColumnWidth(),
      columnWidths: {
        0: FixedColumnWidth(20),
        3: FlexColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.fill,
              child: CustomPaint(
                painter: _TargetPainter(
                  context,
                  before: pos == _Position.middle || pos == _Position.end
                      ? _TargetConnection.transfer
                      : _TargetConnection.none,
                  after: _TargetConnection.leg,
                ),
              ),
            ),
            Center(child: Text(intl.DateFormat.Hm().format(leg.start))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(leg.from.name),
            ),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.fill,
              child: CustomPaint(
                painter: _TargetPainter(
                  context,
                  before: _TargetConnection.leg,
                  after: pos == _Position.middle || pos == _Position.start
                      ? _TargetConnection.transfer
                      : _TargetConnection.none,
                ),
              ),
            ),
            Center(child: Text(intl.DateFormat.Hm().format(leg.end))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(leg.to.name),
            ),
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
