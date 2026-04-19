import 'package:flutter/material.dart';
import 'package:myspace/data/models/news_article.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final bool showImage;

  const NewsCard({super.key, required this.article, required this.showImage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RepaintBoundary(
      child: Container(
        color: colorScheme.surface,
        child: Column(
          children: [
            if (showImage)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.36,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      article.imageUrl,
                      fit: BoxFit.cover,
                      frameBuilder: (_, child, frame, loaded) {
                        if (loaded) return child;
                        return AnimatedOpacity(
                          opacity: frame != null ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: child,
                        );
                      },

                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primaryContainer,
                              colorScheme.tertiaryContainer,
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              colorScheme.surface.withValues(alpha: 0.7),
                              colorScheme.surface,
                            ],
                            stops: const [0.0, 0.65, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, showImage ? 0 : 28, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _sourceAccent(
                              article.source,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _sourceIcon(article.source),
                                size: 13,
                                color: _sourceAccent(article.source),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                article.displaySource,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _sourceAccent(article.source),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          article.timeAgo,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _scoreColor(
                              article.score,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                size: 11,
                                color: _scoreColor(article.score),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                article.score.toStringAsFixed(1),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _scoreColor(article.score),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Text(
                      article.title,
                      style:
                          (showImage
                                  ? theme.textTheme.titleLarge
                                  : theme.textTheme.headlineSmall)
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                                letterSpacing: -0.5,
                                color: colorScheme.onSurface,
                              ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      article.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.7,
                        letterSpacing: 0.15,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (article.tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: article.tags
                            .take(4)
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tag,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      article.displaySource.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.45,
                        ),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  IconButton(
                    onPressed: () => _shareArticle(article),
                    icon: Icon(
                      Icons.share_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'Share',
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),

                  IconButton.filled(
                    onPressed: () => _openArticle(article.url),
                    icon: const Icon(Icons.arrow_outward_rounded, size: 18),
                    tooltip: 'Read full article',
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _sourceIcon(String source) {
    switch (source) {
      case 'hackernews':
        return Icons.terminal_rounded;
      case 'reddit':
        return Icons.reddit_rounded;
      case 'gnews':
        return Icons.public_rounded;
      case 'rss':
        return Icons.rss_feed_rounded;
      default:
        return Icons.article_outlined;
    }
  }

  Color _sourceAccent(String source) {
    switch (source) {
      case 'hackernews':
        return const Color(0xFFFF6600);
      case 'reddit':
        return const Color(0xFFFF4500);
      case 'gnews':
        return const Color(0xFF4285F4);
      case 'rss':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF78909C);
    }
  }

  Color _scoreColor(double score) {
    if (score >= 8.0) return const Color(0xFF2E7D32);
    if (score >= 6.0) return const Color(0xFF1565C0);
    if (score >= 4.0) return const Color(0xFFE65100);
    return const Color(0xFF616161);
  }

  Future<void> _openArticle(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _shareArticle(NewsArticle article) {
    final text = '${article.title}\n\n${article.url}';
    SharePlus.instance.share(ShareParams(text: text));
  }
}
