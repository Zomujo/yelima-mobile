import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../layout/app_text.dart';

/// Waits for typing to pause, then keeps only the newest search's result.
class LatestSearch {
  int _token = 0;

  /// Runs [fetch] once typing pauses; null if a newer search started meanwhile.
  Future<T?> run<T>(Future<T> Function() fetch) async {
    final token = ++_token;
    await Future.delayed(const Duration(milliseconds: 350));
    if (token != _token) return null;
    final result = await fetch();
    return token == _token ? result : null;
  }
}

/// The dropdown under a search field: a tappable row per item, or one [message] row.
class SuggestionList extends StatelessWidget {
  const SuggestionList({
    super.key,
    this.items = const [],
    this.message,
    this.onTap,
    this.width,
  });

  final List<String> items;
  final String? message;
  final ValueChanged<int>? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    return Material(
      elevation: 4.0,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.slate200),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 250),
        child: SizedBox(
          width: width,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: message != null ? 1 : items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.slate200),
            itemBuilder: (context, i) => message != null
                ? _row(message, AppColors.textGrey)
                : InkWell(
                    onTap: () => onTap?.call(i),
                    borderRadius: BorderRadius.circular(16),
                    child: _row(items[i], AppColors.slate800),
                  ),
          ),
        ),
      ),
    );
  }

  static Widget _row(String text, Color color) => Padding(
        padding: const EdgeInsets.all(16),
        child: AppText.bodyMedium(text, color: color),
      );
}
