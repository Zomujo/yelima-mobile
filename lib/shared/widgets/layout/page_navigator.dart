import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import 'app_text.dart';

/// "Page 2 of 5" with previous and next buttons.
class PageNavigator extends StatelessWidget {
  const PageNavigator({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPage,
  });

  final int page;
  final int totalPages;

  /// Called with the page to show.
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.bodyMedium(context.l10n.pageOfTotal(page, totalPages),
            color: const Color(0xFF575F69), fontWeight: FontWeight.w600),
        Row(
          children: [
            _PageButton(
                icon: Icons.chevron_left,
                onPressed: page > 1 ? () => onPage(page - 1) : null),
            const SizedBox(width: 8),
            _PageButton(
                icon: Icons.chevron_right,
                onPressed: page < totalPages ? () => onPage(page + 1) : null),
          ],
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.orange300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
            icon: Icon(icon, color: AppColors.orange300), onPressed: onPressed),
      );
}
