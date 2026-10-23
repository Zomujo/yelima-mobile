import 'package:yelima/core/theme/app_colors.dart';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/vital_trends.dart';
import 'base_vital_graph.dart';

/// The blood sugar line.
class GlucoseGraph extends StatelessWidget {
  final VitalTrend data;

  const GlucoseGraph({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final validValues =
        data.values.where((v) => v != null).map((v) => v!.toDouble()).toList();

    double minY = 4.0;
    double maxY = 12.0;

    if (validValues.isNotEmpty) {
      final dataMin = validValues.reduce(min);
      final dataMax = validValues.reduce(max);
      minY = (dataMin - 1).floor().toDouble();
      maxY = (dataMax + 1).ceil().toDouble();
      if (minY == maxY) {
        minY -= 1;
        maxY += 1;
      }
    }

    final step = (maxY - minY) / 4;
    final leftLabelValues = [
      minY,
      minY + step,
      minY + 2 * step,
      minY + 3 * step,
      maxY
    ];

    return BaseVitalGraph(
      minX: 0,
      maxX: (data.labels.isEmpty ? 0 : data.labels.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      bottomLabels: data.formattedLabels.isEmpty ? [''] : data.formattedLabels,
      leftLabelValues: leftLabelValues,
      targetLineY: 5.6,
      targetLineColor: AppColors.emerald500,
      lineBarsData: [
        LineChartBarData(
          spots: data.values
              .asMap()
              .entries
              .where((e) => e.value != null)
              .map((e) => FlSpot(e.key.toDouble(), e.value!.toDouble()))
              .toList(),
          isCurved: true,
          color: AppColors.blue500,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFF93C5FD),
                strokeWidth: 2,
                strokeColor: AppColors.blue500,
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }
}
