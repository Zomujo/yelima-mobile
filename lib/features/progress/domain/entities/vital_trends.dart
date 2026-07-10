import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class TrendLabel {
  final String main;
  final String? sub;
  final bool isBoundary;

  const TrendLabel({required this.main, this.sub, this.isBoundary = false});
}

class BPTrend extends Equatable {
  final List<String> labels;
  final List<int?> systolic;
  final List<int?> diastolic;

  const BPTrend({
    required this.labels,
    required this.systolic,
    required this.diastolic,
  });

  factory BPTrend.fromJson(Map<String, dynamic> json) {
    return BPTrend(
      labels: List<String>.from(json['labels'] ?? []),
      systolic: List<int?>.from(json['systolic'] ?? []),
      diastolic: List<int?>.from(json['diastolic'] ?? []),
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
        main = DateFormat('HH:mm').format(current);
        if (prev == null || current.day != prev.day) {
          isBoundary = true;
          sub = DateFormat('dd MMM').format(current).toUpperCase();
        }
      } else {
        // Date based (Multi-day)
        main = DateFormat('dd').format(current);
        if (prev == null || current.month != prev.month) {
          isBoundary = true;
          sub = DateFormat('MMM').format(current).toUpperCase();
        }
      }

      metadata.add(TrendLabel(main: main, sub: sub, isBoundary: isBoundary));
    }

    return metadata;
  }

  List<String> get formattedLabels => labelMetadata.map((m) => m.main).toList();

  @override
  List<Object?> get props => [labels, systolic, diastolic];
}

class VitalTrend extends Equatable {
  final List<String> labels;
  final List<double?> values;

  const VitalTrend({
    required this.labels,
    required this.values,
  });

  factory VitalTrend.fromJson(Map<String, dynamic> json) {
    return VitalTrend(
      labels: List<String>.from(json['labels'] ?? []),
      values: List<double?>.from(json['values']?.map((x) => x != null ? (x as num).toDouble() : null) ?? []),
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
        main = DateFormat('HH:mm').format(current);
        if (prev == null || current.day != prev.day) {
          isBoundary = true;
          sub = DateFormat('dd MMM').format(current).toUpperCase();
        }
      } else {
        main = DateFormat('dd').format(current);
        if (prev == null || current.month != prev.month) {
          isBoundary = true;
          sub = DateFormat('MMM').format(current).toUpperCase();
        }
      }

      metadata.add(TrendLabel(main: main, sub: sub, isBoundary: isBoundary));
    }

    return metadata;
  }

  List<String> get formattedLabels => labelMetadata.map((m) => m.main).toList();

  @override
  List<Object?> get props => [labels, values];
}
