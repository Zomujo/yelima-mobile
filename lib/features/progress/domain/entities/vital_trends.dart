import 'package:equatable/equatable.dart';

import '../../../../core/utils/app_date_formats.dart';

/// One x-axis label; a boundary label also shows the day or month it starts.
class TrendLabel {
  const TrendLabel({required this.main, this.sub, this.isBoundary = false});

  final String main;
  final String? sub;
  final bool isBoundary;
}

/// How far back a chart goes.
enum ChartDateRange { today, thisWeek, thisMonth }

/// A chart's points over time, with x-axis labels built from their timestamps.
mixin TrendLabels {
  /// ISO timestamps, one per point.
  List<String> get labels;

  /// Times for a span of about a day, otherwise day numbers; the day or month shows where it changes.
  List<TrendLabel> get labelMetadata {
    if (labels.isEmpty) return const [];
    final dates = [for (final l in labels) DateTime.parse(l).toLocal()];
    final short = dates.last.difference(dates.first).inHours <= 26;
    TrendLabel label(DateTime d, DateTime? prev) {
      final boundary =
          prev == null || (short ? d.day != prev.day : d.month != prev.month);
      return TrendLabel(
        main:
            (short ? AppDateFormats.time24h : AppDateFormats.dayOnly).format(d),
        sub: boundary
            ? (short ? AppDateFormats.dayMonthShort : AppDateFormats.monthShort)
                .format(d)
                .toUpperCase()
            : null,
        isBoundary: boundary,
      );
    }

    return [
      for (var i = 0; i < dates.length; i++)
        label(dates[i], i > 0 ? dates[i - 1] : null)
    ];
  }

  List<String> get formattedLabels => [for (final m in labelMetadata) m.main];
}

/// Systolic and diastolic readings over time.
class BPTrend extends Equatable with TrendLabels {
  const BPTrend({
    required this.labels,
    required this.systolic,
    required this.diastolic,
    this.note,
  });

  @override
  final List<String> labels;
  final List<int?> systolic;
  final List<int?> diastolic;

  /// The server's comment on the trend, if any.
  final String? note;

  factory BPTrend.fromJson(Map<String, dynamic> json) => BPTrend(
        labels: List<String>.from(json['labels'] ?? const []),
        systolic: List<int?>.from(json['systolic'] ?? const []),
        diastolic: List<int?>.from(json['diastolic'] ?? const []),
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'labels': labels,
        'systolic': systolic,
        'diastolic': diastolic,
        if (note != null) 'note': note,
      };

  @override
  List<Object?> get props => [labels, systolic, diastolic, note];
}

/// One vital's values over time (blood sugar).
class VitalTrend extends Equatable with TrendLabels {
  const VitalTrend({
    required this.labels,
    required this.values,
    this.latestValue,
    this.note,
  });

  @override
  final List<String> labels;
  final List<double?> values;
  final double? latestValue;

  /// The server's comment on the trend, if any.
  final String? note;

  factory VitalTrend.fromJson(Map<String, dynamic> json) => VitalTrend(
        labels: List<String>.from(json['labels'] ?? const []),
        values: [
          for (final x in json['values'] ?? const []) (x as num?)?.toDouble()
        ],
        latestValue: (json['latestValue'] as num?)?.toDouble(),
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'labels': labels,
        'values': values,
        if (latestValue != null) 'latestValue': latestValue,
        if (note != null) 'note': note,
      };

  @override
  List<Object?> get props => [labels, values, latestValue, note];
}
