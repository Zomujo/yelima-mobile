import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../shared/utils/failure_message.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../controllers/progress_state.dart';

/// A chart, or its loading, error or no-data state.
class TrendView<T> extends StatelessWidget {
  const TrendView(
      {super.key, required this.state, required this.chart, this.height = 180});

  final ProgressState<T> state;
  final Widget Function(T data) chart;

  /// Shimmer height while loading; null fills the space.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final data = state.data;
    if (data != null) return chart(data);
    if (state.isLoading) {
      return Center(
          child: AppShimmer.box(
              width: double.infinity, height: height ?? double.infinity));
    }
    return Center(
        child: AppText.bodyMedium(state.error?.message(context.l10n) ??
            context.l10n.noDataAvailable));
  }
}
