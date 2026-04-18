import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class YearHeatmapRenderer {
  static Future<Uint8List> renderPng({
    required Map<String, int> values,
    required DateTime endDateInclusive,
    required int imageWidthPx,
    required int imageHeightPx,
    int maxIntensity = 4,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(imageWidthPx.toDouble(), imageHeightPx.toDouble());

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0B0F14),
    );

    const rows = 7;

    final margin = (size.shortestSide * 0.008).clamp(0.0, 5.0);
    final gridWMax = size.width - margin * 2;
    final gridHMax = size.height - margin * 2;

    final today = DateTime(
      endDateInclusive.year,
      endDateInclusive.month,
      endDateInclusive.day,
    );
    final yearAgo = today.subtract(const Duration(days: 364));

    final fullStart = _startOfWeekSunday(yearAgo);
    final fullEnd = _endOfWeekSaturday(today);
    final fullTotalDays = fullEnd.difference(fullStart).inDays + 1;
    final fullCols = (fullTotalDays / 7).ceil();

    final aspect = gridWMax / gridHMax;

    int targetCols;
    if (aspect >= 7.0) {
      targetCols = 10;
    } else if (aspect >= 5.0) {
      targetCols = 14;
    } else if (aspect >= 3.5) {
      targetCols = 20;
    } else if (aspect >= 2.2) {
      targetCols = 30;
    } else {
      targetCols = fullCols;
    }

    final cols = targetCols.clamp(8, fullCols);

    final cellSize = (gridWMax / cols).clamp(0, gridHMax / rows);

    final gridW = cellSize * cols;
    final gridH = cellSize * rows;
    final startX = (size.width - gridW) / 2.0;
    final startY = (size.height - gridH) / 2.0;

    final base = cellSize;
    final cellPad = (base * 0.12).clamp(0.0, 2.5);
    final radius = (base * 0.25).clamp(1.0, 6.0);

    const levels = <Color>[
      Color(0xFF1A1A1A),
      Color(0xFF0E4429),
      Color(0xFF006D32),
      Color(0xFF26A641),
      Color(0xFF39D353),
    ];

    Color pickColor(int v) {
      final clamped = v.clamp(0, maxIntensity);
      return levels[clamped.clamp(0, levels.length - 1)];
    }

    final start = fullEnd.subtract(Duration(days: cols * 7 - 1));

    final paint = Paint()..style = PaintingStyle.fill;

    for (int w = 0; w < cols; w++) {
      for (int r = 0; r < rows; r++) {
        final date = start.add(Duration(days: w * 7 + r));
        final iso = _isoDate(date);

        paint.color = pickColor(values[iso] ?? 0);

        final x = startX + w * cellSize;
        final y = startY + r * cellSize;

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x + cellPad,
            y + cellPad,
            cellSize - cellPad * 2,
            cellSize - cellPad * 2,
          ),
          Radius.circular(radius),
        );

        canvas.drawRRect(rect, paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(imageWidthPx, imageHeightPx);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  static DateTime _startOfWeekSunday(DateTime d) {
    final dd = DateTime(d.year, d.month, d.day);
    final weekday = dd.weekday;
    final daysSinceSunday = weekday % 7;
    return dd.subtract(Duration(days: daysSinceSunday));
  }

  static DateTime _endOfWeekSaturday(DateTime d) {
    final sunday = _startOfWeekSunday(d);
    return sunday.add(const Duration(days: 6));
  }

  static String _isoDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
