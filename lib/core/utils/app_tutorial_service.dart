import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:yelima/core/services/shared_prefs_service.dart';
import 'package:yelima/injection_container.dart';
import 'package:provider/provider.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';

import 'package:yelima/core/utils/app_tutorial_keys.dart';
import 'package:yelima/core/utils/app_tutorial_target.dart';

class AppTutorialService {

  static Future<void> showTutorial({
    required BuildContext context,
    required String tutorialId,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) async {
    if (!context.mounted) return;

    final userController = context.read<UserController>();
    final user = userController.userEntity;
    
    final prefsService = sl<SharedPrefsService>();
    final String localKey = '${user?.id}_$tutorialId';

    final bool isCompletedLocally = prefsService.isTutorialCompleted(localKey);
    final bool isCompletedInProfile = user?.completedTutorials.contains(tutorialId) ?? false;

    if (isCompletedLocally || isCompletedInProfile) return;

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withValues(alpha: 0.85),
      paddingFocus: 10,
      opacityShadow: 0.85,
      hideSkip: true,
      onFinish: () {
        prefsService.setTutorialCompleted(localKey);
        userController.markTutorialCompleted(tutorialId);
        onFinish?.call();
      },
      onSkip: () {
        prefsService.setTutorialCompleted(localKey);
        userController.markTutorialCompleted(tutorialId);
        onSkip?.call();
        return true;
      },
    ).show(context: context, rootOverlay: true);
  }

  static Future<void> showHomeTutorial(BuildContext context) async {
    await showTutorial(
      context: context,
      tutorialId: 'home_screen_intro',
      targets: [
        AppTutorialTarget.create(
          identify: 'home_metrics',
          key: AppTutorialKeys.homeMetricsKey,
          title: context.l10n.tutorialHomeMetricsTitle,
          description: context.l10n.tutorialHomeMetricsDesc,
        ),
        AppTutorialTarget.create(
          identify: 'home_adherence',
          key: AppTutorialKeys.homeAdherenceKey,
          title: context.l10n.tutorialMedicationsAdherenceTitle,
          description: context.l10n.tutorialMedicationsAdherenceDesc,
        ),
        AppTutorialTarget.create(
          identify: 'home_daily_check_in',
          key: AppTutorialKeys.homeDailyCheckInKey,
          title: context.l10n.tutorialHomeDailyCheckInTitle,
          description: context.l10n.tutorialHomeDailyCheckInDesc,
        ),
        AppTutorialTarget.create(
          identify: 'home_action_cards',
          key: AppTutorialKeys.homeActionCardsKey,
          title: context.l10n.tutorialHomeActionCardsTitle,
          description: context.l10n.tutorialHomeActionCardsDesc,
        ),
      ],
    );
  }

  static Future<void> showMedicationsTutorial(BuildContext context) async {
    await showTutorial(
      context: context,
      tutorialId: 'medications_screen_intro',
      targets: [
        AppTutorialTarget.create(
          identify: 'medications_adherence',
          key: AppTutorialKeys.medicationsAdherenceKey,
          title: context.l10n.tutorialMedicationsAdherenceTitle,
          description: context.l10n.tutorialMedicationsAdherenceDesc,
        ),
        AppTutorialTarget.create(
          identify: 'medications_list',
          key: AppTutorialKeys.medicationsListKey,
          title: context.l10n.tutorialMedicationsListTitle,
          description: context.l10n.tutorialMedicationsListDesc,
        ),
      ],
    );
  }

  static Future<void> showAppointmentsTutorial(BuildContext context) async {
    await showTutorial(
      context: context,
      tutorialId: 'appointments_screen_intro',
      targets: [
        AppTutorialTarget.create(
          identify: 'appointments_ask',
          key: AppTutorialKeys.appointmentAskKey,
          title: context.l10n.tutorialAppointmentAskTitle,
          description: context.l10n.tutorialAppointmentAskDesc,
        ),
        AppTutorialTarget.create(
          identify: 'appointments_list',
          key: AppTutorialKeys.appointmentListKey,
          title: context.l10n.tutorialAppointmentListTitle,
          description: context.l10n.tutorialAppointmentListDesc,
        ),
        AppTutorialTarget.create(
          identify: 'appointments_past_list',
          key: AppTutorialKeys.appointmentPastListKey,
          title: context.l10n.tutorialAppointmentPastListTitle,
          description: context.l10n.tutorialAppointmentPastListDesc,
        ),
      ],
    );
  }

  static Future<void> showProgressTutorial(BuildContext context) async {
    await showTutorial(
      context: context,
      tutorialId: 'progress_screen_intro',
      targets: [
        AppTutorialTarget.create(
          identify: 'progress_graph',
          key: AppTutorialKeys.progressGraphKey,
          title: context.l10n.tutorialProgressGraphTitle,
          description: context.l10n.tutorialProgressGraphDesc,
        ),
      ],
    );
  }

  static Future<void> showLogReadingTutorial(BuildContext context) async {
    await showTutorial(
      context: context,
      tutorialId: 'log_reading_screen',
      targets: [
        AppTutorialTarget.create(
          identify: 'log_reading_type',
          key: AppTutorialKeys.logReadingTypeKey,
          title: context.l10n.tutorialLogReadingTypeTitle,
          description: context.l10n.tutorialLogReadingTypeDesc,
        ),
        AppTutorialTarget.create(
          identify: 'log_reading_input',
          key: AppTutorialKeys.logReadingInputKey,
          title: context.l10n.tutorialLogReadingInputTitle,
          description: context.l10n.tutorialLogReadingInputDesc,
        ),
        AppTutorialTarget.create(
          identify: 'log_reading_date',
          key: AppTutorialKeys.logReadingDateKey,
          title: context.l10n.tutorialLogReadingDateTitle,
          description: context.l10n.tutorialLogReadingDateDesc,
        ),
        AppTutorialTarget.create(
          identify: 'log_reading_save',
          key: AppTutorialKeys.logReadingSaveKey,
          title: context.l10n.tutorialLogReadingSaveTitle,
          description: context.l10n.tutorialLogReadingSaveDesc,
        ),
      ],
    );
  }

  static Future<void> showProfileTutorial(BuildContext context) async {
    await showTutorial(
      context: context,
      tutorialId: 'profile_screen_intro',
      targets: [
        AppTutorialTarget.create(
          identify: 'profile_avatar',
          key: AppTutorialKeys.profileAvatarKey,
          title: context.l10n.tutorialProfileAvatarTitle,
          description: context.l10n.tutorialProfileAvatarDesc,
        ),
        AppTutorialTarget.create(
          identify: 'profile_personal_options',
          key: AppTutorialKeys.profilePersonalOptionsKey,
          title: context.l10n.tutorialProfilePersonalTitle,
          description: context.l10n.tutorialProfilePersonalDesc,
        ),
        AppTutorialTarget.create(
          identify: 'profile_health_summary_options',
          key: AppTutorialKeys.profileHealthSummaryOptionsKey,
          title: context.l10n.tutorialProfileHealthTitle,
          description: context.l10n.tutorialProfileHealthDesc,
        ),
        AppTutorialTarget.create(
          identify: 'profile_language_options',
          key: AppTutorialKeys.profileLanguageOptionsKey,
          title: context.l10n.tutorialProfileLanguageTitle,
          description: context.l10n.tutorialProfileLanguageDesc,
        ),
        AppTutorialTarget.create(
          identify: 'profile_system_options',
          key: AppTutorialKeys.profileSystemOptionsKey,
          title: context.l10n.tutorialProfileSystemTitle,
          description: context.l10n.tutorialProfileSystemDesc,
        ),
      ],
    );
  }
}
