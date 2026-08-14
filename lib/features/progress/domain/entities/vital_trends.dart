import 'package:equatable/equatable.dart';
import 'package:yelima/core/utils/app_date_formats.dart';

class TrendLabel {
  final String main;
  final String? sub;
  final bool isBoundary;

  const TrendLabel({required this.main, this.sub, this.isBoundary = false});
}

enum ChartDateRange { today, thisWeek, thisMonth }

extension ChartDateRangeExt on ChartDateRange {
  String get backendString => name;
}

class BPTrend extends Equatable {
  final List<String> labels;
  final List<int?> systolic;
  final List<int?> diastolic;
  final String? note;

  const BPTrend({
    required this.labels,
    required this.systolic,
    required this.diastolic,
    this.note,
  });

  factory BPTrend.fromJson(Map<String, dynamic> json) {
    return BPTrend(
      labels: List<String>.from(json['labels'] ?? []),
      systolic: List<int?>.from(json['systolic'] ?? []),
      diastolic: List<int?>.from(json['diastolic'] ?? []),
      note: json['note'] as String?,
    );
  }

  List<TrendLabel> get labelMetadata {
    if (labels.isEmpty) return [];

    final dates = labels.map((e) => DateTime.parse(e).toLocal()).toList();
    final first = dates.first;
    final last = dates.last;
    final isShortSpan = last.difference(first).inHours <= 26;

    final List<TrendLabel> metadata = [];

    for (int i = 0; i < dates.length; i++) {
      final current = dates[i];
      final prev = i > 0 ? dates[i - 1] : null;

      bool isBoundary = false;
      String main = '';
      String? sub;

      if (isShortSpan) {
        // Time based (24h)
        main = AppDateFormats.time24h.format(current);
        if (prev == null || current.day != prev.day) {
          isBoundary = true;
          sub = AppDateFormats.dayMonthShort.format(current).toUpperCase();
        }
      } else {
        // Date based (Multi-day)
        main = AppDateFormats.dayOnly.format(current);
        if (prev == null || current.month != prev.month) {
          isBoundary = true;
          sub = AppDateFormats.monthShort.format(current).toUpperCase();
        }
      }

      metadata.add(TrendLabel(main: main, sub: sub, isBoundary: isBoundary));
    }

    return metadata;
  }

  List<String> get formattedLabels => labelMetadata.map((m) => m.main).toList();

  @override
  List<Object?> get props => [labels, systolic, diastolic, note];
}

class VitalTrend extends Equatable {
  final List<String> labels;
  final List<double?> values;
  final double? latestValue;
  final String? note;

  const VitalTrend({
    required this.labels,
    required this.values,
    this.latestValue,
    this.note,
  });

  factory VitalTrend.fromJson(Map<String, dynamic> json) {
    return VitalTrend(
      labels: List<String>.from(json['labels'] ?? []),
      values: List<double?>.from(json['values']
              ?.map((x) => x != null ? (x as num).toDouble() : null) ??
          []),
      latestValue: json['latestValue'] != null
          ? (json['latestValue'] as num).toDouble()
          : null,
      note: json['note'] as String?,
    );
  }

  List<TrendLabel> get labelMetadata {
    if (labels.isEmpty) return [];

    final dates = labels.map((e) => DateTime.parse(e).toLocal()).toList();
    final first = dates.first;
    final last = dates.last;
    final isShortSpan = last.difference(first).inHours <= 26;

    final List<TrendLabel> metadata = [];

    for (int i = 0; i < dates.length; i++) {
      final current = dates[i];
      final prev = i > 0 ? dates[i - 1] : null;

      bool isBoundary = false;
      String main = '';
      String? sub;

      if (isShortSpan) {
        main = AppDateFormats.time24h.format(current);
        if (prev == null || current.day != prev.day) {
          isBoundary = true;
          sub = AppDateFormats.dayMonthShort.format(current).toUpperCase();
        }
      } else {
        main = AppDateFormats.dayOnly.format(current);
        if (prev == null || current.month != prev.month) {
          isBoundary = true;
          sub = AppDateFormats.monthShort.format(current).toUpperCase();
        }
      }

      metadata.add(TrendLabel(main: main, sub: sub, isBoundary: isBoundary));
    }

    return metadata;
  }

  List<String> get formattedLabels => labelMetadata.map((m) => m.main).toList();

  @override
  List<Object?> get props => [labels, values, latestValue, note];
}
