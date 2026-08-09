import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:yelima/core/constants/app_decoration.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/core/services/shared_prefs_service.dart';
import 'package:yelima/shared/widgets/layout/app_button.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/injection_container.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

class AppTutorialService {
  static final GlobalKey homeMetricsKey = GlobalKey();
  static final GlobalKey homeAdherenceKey = GlobalKey();
  static final GlobalKey homeNextStepKey = GlobalKey();
  static final GlobalKey homeDailyCheckInKey = GlobalKey();
  static final GlobalKey homeActionCardsKey = GlobalKey();
  static final GlobalKey medicationsAdherenceKey = GlobalKey();
  static final GlobalKey medicationsListKey = GlobalKey();
  static final GlobalKey progressGraphKey = GlobalKey();
  static final GlobalKey appointmentAskKey = GlobalKey();
  static final GlobalKey appointmentListKey = GlobalKey();
  static final GlobalKey appointmentPastListKey = GlobalKey();
  static final GlobalKey profileAvatarKey = GlobalKey();

  static final GlobalKey logReadingTypeKey = GlobalKey();
  static final GlobalKey logReadingInputKey = GlobalKey();
  static final GlobalKey logReadingDateKey = GlobalKey();
  static final GlobalKey logReadingSaveKey = GlobalKey();

  static Future<void> showTutorial({
    required BuildContext context,
    required String tutorialId,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) async {
    final prefsService = sl<SharedPrefsService>();
    final bool isCompleted = prefsService.isTutorialCompleted(tutorialId);
    if (isCompleted) return;

    if (!context.mounted) return;

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withValues(alpha: 0.85),
      paddingFocus: 10,
      opacityShadow: 0.85,
      hideSkip: true,
      onFinish: () {
        prefsService.setTutorialCompleted(tutorialId);
        onFinish?.call();
      },
      onSkip: () {
        prefsService.setTutorialCompleted(tutorialId);
        onSkip?.call();
        return true;
      },
    ).show(context: context, rootOverlay: true);
  }

  static TargetFocus createTarget({
    required String identify,
    required GlobalKey key,
    required String title,
    required String description,
    ContentAlign? align,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    double radius = 16.0,
  }) {
    ContentAlign computedAlign = ContentAlign.bottom;

    if (align != null) {
      computedAlign = align;
    } else {
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero);
          final screenHeight = MediaQuery.of(context).size.height;
          // Auto-align: if target is in bottom half, show text on top
          if (position.dy > (screenHeight / 2)) {
            computedAlign = ContentAlign.top;
          } else {
            computedAlign = ContentAlign.bottom;
          }
        }
      }
    }

    return TargetFocus(
      identify: identify,
      keyTarget: key,
      shape: shape,
      radius: radius,
      contents: [
        TargetContent(
          align: computedAlign,
          builder: (context, controller) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallDevice = screenWidth < 360;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallDevice ? screenWidth * 0.9 : 400,
                ),
                child: Container(
                  padding: EdgeInsets.all(isSmallDevice ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppDecoration.shadowSm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.titleLarge(
                        title,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 10),
                      AppText.bodyMedium(
                        description,
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 20),
                      OverflowBar(
                        alignment: MainAxisAlignment.end,
                        spacing: 10,
                        overflowSpacing: 10,
                        children: [
                          AppButton(
                            text: context.l10n.skip,
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.grey[600],
                            onPressed: () => controller.skip(),
                          ),
                          AppButton(
                            text: context.l10n.continueText,
                            backgroundColor: AppColors.primary,
                            onPressed: () => controller.next(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
