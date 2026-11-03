import 'dart:math';

import 'package:equatable/equatable.dart';

import '../../../../core/utils/app_date_formats.dart';

/// How far back a chart goes.
enum ChartDateRange {
  today,
  thisWeek,
  thisMonth;

  /// Where the chart starts, the way the server works it out: midnight of the
  /// day 24 hours, 7 days or one month ago. So "today" also covers yesterday.
  DateTime since(DateTime now) {
    final from = switch (this) {
      today => now.subtract(const Duration(hours: 24)),
      thisWeek => DateTime(now.year, now.month, now.day - 7),
      // Like date-fns subMonths: 31 March goes back to 28 or 29 February.
      thisMonth => DateTime(now.year, now.month - 1,
          min(now.day, DateTime(now.year, now.month, 0).day)),
    };
    return DateTime(from.year, from.month, from.day);
  }
}

/// A reading saved on the phone: when, and its value as stored ("122/76", "5.9").
typedef PhoneReading = (DateTime at, String value);

/// The trend's points plus [phone] readings since [since] it doesn't have yet,
/// oldest first. The same moment is one point, to the millisecond like the server.
List<(DateTime, V)> _mergePoints<V>(List<String> labels, List<V> values,
    Iterable<(DateTime, V)> phone, DateTime since) {
  DateTime ms(DateTime t) =>
      DateTime.fromMillisecondsSinceEpoch(t.millisecondsSinceEpoch,
          isUtc: true);
  final points = {
    for (var i = 0; i < labels.length && i < values.length; i++)
      ms(DateTime.parse(labels[i])): values[i],
    for (final (at, v) in phone)
      if (!at.isBefore(since)) ms(at): v,
  };
  return [for (final e in points.entries) (e.key, e.value)]
    ..sort((a, b) => a.$1.compareTo(b.$1));
}

/// A chart's points over time, with x-axis labels built from their timestamps.
mixin TrendLabels {
  /// ISO timestamps, one per point.
  List<String> get labels;

  /// Times for a span of about a day; otherwise the day number, once per day.
  List<String> get formattedLabels {
    final dates = [for (final l in labels) DateTime.parse(l).toLocal()];
    if (dates.isEmpty) return const [];
    if (dates.last.difference(dates.first).inHours <= 26) {
      return [for (final d in dates) AppDateFormats.time24h.format(d)];
    }
    return [
      for (var i = 0; i < dates.length; i++)
        i > 0 && _sameDay(dates[i], dates[i - 1])
            ? ''
            : AppDateFormats.dayOnly.format(dates[i]),
    ];
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
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

  /// Adds readings saved on the phone since [since], e.g. ones logged offline
  /// or after this trend was downloaded.
  BPTrend withReadings(Iterable<PhoneReading> readings, DateTime since) {
    final phone = [
      for (final (at, value) in readings)
        if (value.split('/') case [final s, final d]
            when int.tryParse(s) != null && int.tryParse(d) != null)
          (at, (int.parse(s), int.parse(d)) as (int?, int?)),
    ];
    if (phone.isEmpty) return this;
    final points = _mergePoints(
        labels,
        [for (var i = 0; i < systolic.length; i++) (systolic[i], diastolic[i])],
        phone,
        since);
    return BPTrend(
      labels: [for (final p in points) p.$1.toIso8601String()],
      systolic: [for (final p in points) p.$2.$1],
      diastolic: [for (final p in points) p.$2.$2],
      note: note,
    );
  }

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

  /// Adds readings saved on the phone since [since]; the newest becomes the latest.
  VitalTrend withReadings(Iterable<PhoneReading> readings, DateTime since) {
    final phone = [
      for (final (at, value) in readings)
        if (double.tryParse(value) case final v?) (at, v as double?),
    ];
    if (phone.isEmpty) return this;
    final points = _mergePoints(labels, values, phone, since);
    return VitalTrend(
      labels: [for (final p in points) p.$1.toIso8601String()],
      values: [for (final p in points) p.$2],
      latestValue: points.isEmpty ? latestValue : points.last.$2,
      note: note,
    );
  }

  @override
  List<Object?> get props => [labels, values, latestValue, note];
}
