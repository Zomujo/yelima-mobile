import 'package:flutter/material.dart';
import 'app_text.dart';

class OptionBlockItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  OptionBlockItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });
}

class OptionsBlock extends StatelessWidget {
  final String title;
  final List<OptionBlockItem> blockItems;

  const OptionsBlock({
    super.key,
    required this.title,
    required this.blockItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AppText.labelMedium(
              title.toUpperCase(),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B), // Slate 500
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                blockItems.length,
                (index) => _OptionBlockTile(option: blockItems[index]),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _OptionBlockTile extends StatelessWidget {
  final OptionBlockItem option;
  const _OptionBlockTile({required this.option});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: option.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                color: option.iconColor ?? const Color(0xFF64748B), // Slate 500
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppText.bodyLarge(
                  option.label,
                  color: option.labelColor ?? const Color(0xFF1E293B), // Slate 800
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.chevron_right_rounded,
                color: option.iconColor ?? const Color(0xFF0F172A), // Slate 900
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
