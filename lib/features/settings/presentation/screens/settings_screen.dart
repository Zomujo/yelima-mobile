import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/options_block.dart';
import '../../../../core/utils/legal_links.dart';
import '../widgets/delete_account_modal.dart';

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
        title: const AppText.headlineSmall(
          'Settings',
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
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
                title: "Legal",
                blockItems: [
                  OptionBlockItem(
                    label: "Terms and Conditions",
                    icon: Iconsax.document_upload,
                    onTap: () => LegalLinks.launchTerms(),
                  ),
                  OptionBlockItem(
                    label: "Privacy Policy",
                    icon: Iconsax.security,
                    onTap: () => LegalLinks.launchPrivacy(),
                  ),
                ],
              ),
              OptionsBlock(
                title: "Account",
                blockItems: [
                  OptionBlockItem(
                    label: "Delete Account",
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
