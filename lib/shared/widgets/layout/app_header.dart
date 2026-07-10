import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'app_text.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Color backgroundColor;

  const AppHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.onBackPressed,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor = AppColors.globalBackground,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: automaticallyImplyLeading
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B), size: 20),
              onPressed: onBackPressed ?? () => Navigator.maybePop(context),
            )
          : null,
      title: titleWidget ??
          (title != null
              ? AppText.headlineSmall(
                  title!,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                )
              : const SizedBox()),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
