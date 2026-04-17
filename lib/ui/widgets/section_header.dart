import 'package:flutter/material.dart';
import 'package:myspace/ui/widgets/styled_rich_text.dart';

class SectionHeader extends StatelessWidget {
  final String lightTitle;
  final String boldTitle;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.lightTitle,
    required this.boldTitle,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StyledRichText(lightText: lightTitle, boldText: boldTitle),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}
