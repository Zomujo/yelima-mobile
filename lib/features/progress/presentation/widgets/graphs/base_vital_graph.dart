import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BaseVitalGraph extends StatefulWidget {
  final List<LineChartBarData> lineBarsData;
  final double minY;
  final double maxY;
  final double minX;
  final double maxX;
  final List<String> bottomLabels;
  final List<double> leftLabelValues;
  final double targetLineY;
  final Color targetLineColor;
  final List<LineChartBarData> Function(double touchedX)? getExtraLinesOnTouch;

  const BaseVitalGraph({
    super.key,
    required this.lineBarsData,
    required this.minY,
    required this.maxY,
    required this.minX,
    required this.maxX,
    required this.bottomLabels,
    required this.leftLabelValues,
    required this.targetLineY,
    required this.targetLineColor,
    this.getExtraLinesOnTouch,
  });

  @override
  State<BaseVitalGraph> createState() => _BaseVitalGraphState();
}

class _BaseVitalGraphState extends State<BaseVitalGraph> {
  double? showingTooltipOnX;

  @override
  void didUpdateWidget(BaseVitalGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bottomLabels.length != oldWidget.bottomLabels.length) {
      showingTooltipOnX = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int pointCount = widget.bottomLabels.length;
    final double screenWidth = MediaQuery.of(context).size.width;
    const double pointSpacing = 46.0;

    // 60 is the padding/reserved size for titles
    final double minChartWidth = screenWidth - 48; // Account for screen padding
    final double actualDataWidth = pointCount * pointSpacing + 60;
    final double chartWidth = max(minChartWidth, actualDataWidth);

    // Calculate how many points would fit in the screen width
    final double fitCount = (screenWidth - 60) / pointSpacing;
    final double maxX = max(pointCount.toDouble() - 1, fitCount - 1) + 0.5;

    final range = widget.maxY - widget.minY;
    final padding = range > 0 ? range * 0.3 : 15.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: chartWidth,
        height: 180,
        child: LineChart(
          LineChartData(
            minX: -0.5,
            maxX: maxX,
            minY: widget.minY - padding,
            maxY: widget.maxY + padding,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              drawHorizontalLine: true,
              horizontalInterval: range > 0 ? range / 3 : 10,
              getDrawingHorizontalLine: (value) {
                if (value == widget.targetLineY) {
                  return FlLine(
                    color: widget.targetLineColor,
                    strokeWidth: 1.5,
                    dashArray: [4, 4],
                  );
                }
                return FlLine(
                  color: Colors.grey.withValues(alpha: 0.15),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.withValues(alpha: 0.15),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                );
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value != value.roundToDouble()) {
                      return const SizedBox.shrink();
                    }
                    final index = value.toInt();
                    if (index >= 0 && index < widget.bottomLabels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          widget.bottomLabels[index],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchSpotThreshold: 50,
              handleBuiltInTouches: false,
              getTouchedSpotIndicator:
                  (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  return TouchedSpotIndicatorData(
                    const FlLine(
                      color: Colors.transparent,
                      strokeWidth: 0,
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: barData.color ?? Colors.black,
                        );
                      },
                    ),
                  );
                }).toList();
              },
              touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                if (event is FlTapDownEvent &&
                    response != null &&
                    response.lineBarSpots != null &&
                    response.lineBarSpots!.isNotEmpty) {
                  final x = response.lineBarSpots!.first.x;
                  setState(() {
                    if (showingTooltipOnX == x) {
                      showingTooltipOnX = null;
                    } else {
                      showingTooltipOnX = x;
                    }
                  });
                }
              },
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                tooltipRoundedRadius: 8,
                getTooltipColor: (_) => const Color(0xFF1F2937),
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    return LineTooltipItem(
                      '${barSpot.y}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            showingTooltipIndicators: showingTooltipOnX != null
                ? [
                    ShowingTooltipIndicators(
                      widget.lineBarsData.asMap().entries.expand((entry) {
                        final barIndex = entry.key;
                        final bar = entry.value;
                        final spotIndex = bar.spots
                            .indexWhere((s) => s.x == showingTooltipOnX);
                        if (spotIndex != -1) {
                          return [
                            LineBarSpot(bar, barIndex, bar.spots[spotIndex])
                          ];
                        }
                        return <LineBarSpot>[];
                      }).toList(),
                    ),
                  ]
                : [],
            clipData: const FlClipData.none(),
            lineBarsData: [
              ...widget.lineBarsData,
              if (showingTooltipOnX != null &&
                  widget.getExtraLinesOnTouch != null)
                ...widget.getExtraLinesOnTouch!(showingTooltipOnX!),
            ],
          ),
        ),
      ),
    );
  }
}
