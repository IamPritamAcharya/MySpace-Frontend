import 'package:flutter/material.dart';
import 'package:myspace/ui/widgets/contest_list_widget.dart';
import 'package:myspace/ui/widgets/hero_banner.dart';
import 'package:myspace/ui/widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'My',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w300,
                                    fontStyle: FontStyle.italic,
                                    color: colorScheme.primary,
                                    letterSpacing: 0,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ',
                                  style: theme.textTheme.displaySmall,
                                ),
                                TextSpan(
                                  text: 'Dashboard',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.5,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.person_outline,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        iconSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  HeroBanner(
                    icon: Icons.rocket_launch_rounded,
                    onTap: () {},
                    textSpans: [
                      TextSpan(
                        text: 'Ready ',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      TextSpan(
                        text: 'to ',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      TextSpan(
                        text: 'compete',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onPrimaryContainer,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: '?',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w300,
                          fontSize: 26,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SectionHeader(
                    lightTitle: 'Upcoming',
                    boldTitle: 'Contests',
                    subtitle: "Don't miss your chance",
                    trailing: IconButton.filledTonal(
                      onPressed: () {},
                      icon: const Icon(Icons.tune_rounded, size: 24),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const ContestListWidget(),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
