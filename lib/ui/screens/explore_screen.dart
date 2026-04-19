import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myspace/controllers/news_controller.dart';
import 'package:myspace/ui/widgets/error_state.dart';
import 'package:myspace/ui/widgets/loading_indicator.dart';
import 'package:myspace/ui/widgets/news_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = Get.find<NewsController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          final hasError = controller.hasError.value;
          final articles = controller.articles;

          if (isLoading) {
            return const LoadingIndicator();
          }

          if (hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ErrorState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Unable to load news',
                    subtitle: 'Check your connection and try again',
                    iconColor: colorScheme.error.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: controller.refreshArticles,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (articles.isEmpty) {
            return const ErrorState(
              icon: Icons.newspaper_rounded,
              title: 'No news yet',
              subtitle: 'Pull down to refresh',
            );
          }

          final itemCount = articles.length + 1;

          return Column(
            children: [
              Obx(
                () => _ProgressBar(
                  current: controller.currentPage.value,
                  total: articles.length,
                  colorScheme: colorScheme,
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshArticles,
                  color: colorScheme.primary,
                  displacement: 60,
                  child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: itemCount,
                    onPageChanged: (i) => controller.currentPage.value = i,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemBuilder: (_, index) {
                      if (index == articles.length) {
                        return _CompletionCard(
                          totalArticles: articles.length,
                          colorScheme: colorScheme,
                          theme: theme,
                          onBackToTop: () {
                            controller.currentPage.value = 0;
                            controller.refreshArticles();
                          },
                        );
                      }

                      final article = articles[index];
                      return NewsCard(
                        article: article,
                        showImage: controller.hasValidImage(article.id),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final ColorScheme colorScheme;

  const _ProgressBar({
    required this.current,
    required this.total,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = current.clamp(0, total - 1);
    final fraction = total > 1 ? (clamped + 1) / total : 1.0;

    return SizedBox(
      height: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fillWidth = constraints.maxWidth * fraction;
          return Stack(
            children: [
              Container(
                width: double.infinity,
                height: 3,
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: fillWidth,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.tertiary],
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(2),
                    bottomRight: Radius.circular(2),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  final int totalArticles;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onBackToTop;

  const _CompletionCard({
    required this.totalArticles,
    required this.colorScheme,
    required this.theme,
    required this.onBackToTop,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.15),
                    colorScheme.tertiary.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 28),

            Text(
              "You're all caught up!",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            Text(
              '$totalArticles articles · Today',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              'Come back later for fresh updates',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            FilledButton.tonal(
              onPressed: onBackToTop,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text('Refresh feed'),
                ],
              ),
            ),

            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}
