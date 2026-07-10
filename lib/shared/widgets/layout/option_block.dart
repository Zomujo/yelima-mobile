import 'package:flutter/material.dart';
import 'app_text.dart';

class OptionBlockItem {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  OptionBlockItem({
    this.onTap,
    required this.label,
    required this.icon,
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
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.titleMedium(
            title,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(
              blockItems.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OptionBlockTile(option: blockItems[index]),
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
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: option.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  option.icon,
                  color: theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                AppText.bodyLarge(
                  option.label,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
