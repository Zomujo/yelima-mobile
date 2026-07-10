import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/vital_trends.dart';
import 'base_vital_graph.dart';

class BPGraph extends StatelessWidget {
  final BPTrend data;

  const BPGraph({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final systolicValues = data.systolic.where((v) => v != null).map((v) => v!.toDouble()).toList();
    final diastolicValues = data.diastolic.where((v) => v != null).map((v) => v!.toDouble()).toList();

    final allValues = [...systolicValues, ...diastolicValues];

    double minY = 70;
    double maxY = 160;

    if (allValues.isNotEmpty) {
      final dataMin = allValues.reduce(min);
      final dataMax = allValues.reduce(max);
      minY = (dataMin / 10).floor() * 10.0;
      maxY = (dataMax / 10).ceil() * 10.0;
      if (minY == maxY) {
         minY -= 10;
         maxY += 10;
      }
    }

    final mid1 = minY + (maxY - minY) * 0.33;
    final mid2 = minY + (maxY - minY) * 0.66;
    final leftLabelValues = [minY, mid1, mid2, maxY];

    return BaseVitalGraph(
      minX: 0,
      maxX: (data.labels.isEmpty ? 0 : data.labels.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      bottomLabels: data.formattedLabels.isEmpty ? [''] : data.formattedLabels,
      leftLabelValues: leftLabelValues,
      targetLineY: 130,
      targetLineColor: const Color(0xFFF59E0B), // Orange dashed line
      getExtraLinesOnTouch: (showingTooltipOnX) {
        final index = showingTooltipOnX.toInt();
        if (index >= 0 &&
            index < data.systolic.length &&
            index < data.diastolic.length &&
            data.systolic[index] != null &&
            data.diastolic[index] != null) {
          return [
            LineChartBarData(
              spots: [
                FlSpot(
                  showingTooltipOnX,
                  data.systolic[index]!.toDouble(),
                ),
                FlSpot(
                  showingTooltipOnX,
                  data.diastolic[index]!.toDouble(),
                ),
              ],
              isCurved: false,
              barWidth: 2,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFEF4444),
                  Color(0xFF3B82F6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              dotData: const FlDotData(show: false),
            ),
          ];
        }
        return [];
      },
      lineBarsData: [
        LineChartBarData(
          spots: data.systolic
              .asMap()
              .entries
              .where((e) => e.value != null)
              .map((e) => FlSpot(e.key.toDouble(), e.value!.toDouble()))
              .toList(),
          isCurved: false, // Straight lines between points as in screenshot
          color: const Color(0xFFEF4444), // Zyptyk Red
          barWidth: 2,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFFFCA5A5), // Lighter red fill
                strokeWidth: 2,
                strokeColor: const Color(0xFFEF4444), // Border matches line
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        ),
        LineChartBarData(
          spots: data.diastolic
              .asMap()
              .entries
              .where((e) => e.value != null)
              .map((e) => FlSpot(e.key.toDouble(), e.value!.toDouble()))
              .toList(),
          isCurved: false,
          color: const Color(0xFF3B82F6), // Zyptyk Blue
          barWidth: 2,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFF93C5FD), // Lighter blue fill
                strokeWidth: 2,
                strokeColor: const Color(0xFF3B82F6), // Border matches line
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }
}
