import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/controllers/locale_controller.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';

/// Lets the user switch the app language.
class LanguagePickerModal extends StatelessWidget {
  const LanguagePickerModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguagePickerModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeController = context.watch<LocaleController>();
    final currentLanguageCode = localeController.locale?.languageCode ?? 'en';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 32),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppText.titleLarge(
                      context.l10n.chooseLanguage,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.slate500),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...languageCodes.map((code) {
              final isSelected = currentLanguageCode == code;
              return InkWell(
                onTap: () {
                  context.read<LocaleController>().setLocale(Locale(code));
                  Navigator.pop(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.bodyLarge(
                        context.l10n.languageName(code),
                        color:
                            isSelected ? AppColors.primary : AppColors.slate800,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppColors.primary),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
