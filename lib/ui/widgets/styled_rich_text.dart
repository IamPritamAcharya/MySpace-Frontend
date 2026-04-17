import 'package:flutter/material.dart';

class StyledRichText extends StatelessWidget {
  final String lightText;
  final String boldText;
  final TextStyle? baseStyle;
  final Color? lightColor;
  final Color? boldColor;
  final double? lightFontSize;
  final double? boldFontSize;
  final bool lightItalic;

  const StyledRichText({
    super.key,
    required this.lightText,
    required this.boldText,
    this.baseStyle,
    this.lightColor,
    this.boldColor,
    this.lightFontSize,
    this.boldFontSize,
    this.lightItalic = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = baseStyle ?? theme.textTheme.titleLarge!;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$lightText ',
            style: style.copyWith(
              fontWeight: FontWeight.w300,
              fontStyle: lightItalic ? FontStyle.italic : FontStyle.normal,
              color: lightColor ?? theme.colorScheme.onSurfaceVariant,
              fontSize: lightFontSize,
              letterSpacing: 0,
            ),
          ),
          TextSpan(
            text: boldText,
            style: style.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: boldColor ?? theme.colorScheme.onSurface,
              fontSize: boldFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
