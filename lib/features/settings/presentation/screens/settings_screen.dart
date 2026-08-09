import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/options_block.dart';
import '../../../../core/utils/legal_links.dart';
import '../widgets/delete_account_modal.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => context.pop(),
        ),
        title: AppText.headlineSmall(
          context.l10n.settings,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0F172A),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OptionsBlock(
                title: context.l10n.legal,
                blockItems: [
                  OptionBlockItem(
                    label: context.l10n.termsAndConditions,
                    icon: Iconsax.document_upload,
                    onTap: () => LegalLinks.launchTerms(),
                  ),
                  OptionBlockItem(
                    label: context.l10n.privacyPolicy,
                    icon: Iconsax.security,
                    onTap: () => LegalLinks.launchPrivacy(),
                  ),
                ],
              ),
              OptionsBlock(
                title: context.l10n.account,
                blockItems: [
                  OptionBlockItem(
                    label: context.l10n.deleteAccount,
                    icon: Iconsax.trash,
                    onTap: () => DeleteAccountModal.show(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
