import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_motion.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../user/user_providers.dart';
import '../../../../user/presentation/widgets/user_avatar.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// The patient's avatar, name and role at the top of the profile tab.
class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider).userEntity;
    final name = user?.fullName ?? '';

    return _GrowIn(
      child: Center(
        child: Column(
          children: [
            UserAvatar(user: user),
            const SizedBox(height: 16),
            AppText.titleLarge(
              name.isEmpty ? context.l10n.unknownUser : name,
              fontWeight: FontWeight.w600,
              color: AppColors.slate800,
            ),
            const SizedBox(height: 4),
            AppText.bodyMedium(
              context.l10n.patient,
              color: AppColors.slate500,
            ),
          ],
        ),
      ),
    );
  }
}

/// Fades and gently grows [child] into place the first time the tab opens.
class _GrowIn extends StatefulWidget {
  const _GrowIn({required this.child});

  final Widget child;

  @override
  State<_GrowIn> createState() => _GrowInState();
}

class _GrowInState extends State<_GrowIn> {
  bool? _animate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animate ??=
        !AppMotion.reduced(context) && AppMotion.firstTime('profile/avatar');
  }

  @override
  Widget build(BuildContext context) {
    if (_animate != true) return widget.child;
    // Scale is the outermost effect, so the tutorial spotlight measures the
    // avatar's final box even mid-animation.
    return widget.child
        .animate()
        .fadeIn(duration: AppMotion.slow, curve: AppMotion.enter)
        .scaleXY(
            begin: 0.9,
            end: 1,
            duration: AppMotion.slow,
            curve: AppMotion.enter);
  }
}
