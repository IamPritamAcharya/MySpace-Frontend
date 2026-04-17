import 'package:flutter/material.dart';
import 'package:myspace/data/models/contest_model.dart';
import 'package:myspace/ui/widgets/contest_utils.dart';
import 'package:myspace/utils/date_formatter.dart';

class ContestCard extends StatelessWidget {
  final Contest contest;

  const ContestCard({super.key, required this.contest});

  Color _getTimeBadgeColor(DateTime startTime, ColorScheme cs) {
    final difference = startTime.difference(DateTime.now());
    if (difference.isNegative) return cs.errorContainer;
    if (difference.inHours < 24) return cs.tertiaryContainer;
    return cs.secondaryContainer;
  }

  Color _getTimeBadgeTextColor(DateTime startTime, ColorScheme cs) {
    final difference = startTime.difference(DateTime.now());
    if (difference.isNegative) return cs.onErrorContainer;
    if (difference.inHours < 24) return cs.onTertiaryContainer;
    return cs.onSecondaryContainer;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeRemaining = DateFormatter.getTimeRemaining(contest.startDateTime);
    final badgeColor = _getTimeBadgeColor(contest.startDateTime, colorScheme);
    final badgeTextColor = _getTimeBadgeTextColor(
      contest.startDateTime,
      colorScheme,
    );

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => ContestUtilities.openContestLink(contest.link),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contest.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              letterSpacing: 0.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.language,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                contest.platform,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        timeRemaining,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: badgeTextColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        DateFormatter.formatDateTime(contest.startDateTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () =>
                            ContestUtilities.showAddToCalendarDialog(
                              context,
                              contest,
                            ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 18,
                              color: colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remind',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => ContestUtilities.shareContest(contest),
                        borderRadius: BorderRadius.circular(16),
                        splashFactory: InkRipple.splashFactory,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          child: Icon(
                            Icons.ios_share_rounded,
                            size: 20,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        onPressed: () =>
                            ContestUtilities.openContestLink(contest.link),
                        icon: Icon(
                          Icons.arrow_outward_rounded,
                          size: 20,
                          color: colorScheme.onPrimary,
                        ),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
