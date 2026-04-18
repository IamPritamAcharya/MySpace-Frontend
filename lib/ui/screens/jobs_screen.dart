import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myspace/controllers/jobs_controller.dart';
import 'package:myspace/ui/widgets/error_state.dart';
import 'package:myspace/ui/widgets/job_card.dart';
import 'package:myspace/ui/widgets/loading_indicator.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSubmitSearch(JobsController controller) {
    FocusScope.of(context).unfocus();
    controller.submitSearch(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = Get.find<JobsController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshJobs,
          color: colorScheme.primary,
          displacement: 60,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover',
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
                              text: 'Job',
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
                              text: 'Board',
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
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSubmitSearch(controller),
                    decoration: InputDecoration(
                      hintText: 'Search jobs, companies, skills...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () => _onSubmitSearch(controller),
                          icon: Icon(
                            Icons.arrow_forward_rounded,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHigh,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 4),
                  child: SizedBox(
                    height: 40,
                    child: Obx(() {
                      final selected = controller.selectedTags.toList();
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: JobsController.availableTags.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final tag = JobsController.availableTags[index];
                          final isSelected = selected.contains(tag);

                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (_) => controller.toggleTag(tag),
                            labelStyle: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                            selectedColor: colorScheme.primaryContainer,
                            backgroundColor: colorScheme.surfaceContainerHigh,
                            checkmarkColor: colorScheme.onPrimaryContainer,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),

              Obx(() {
                final isLoading = controller.isLoading.value;
                final hasError = controller.hasError.value;
                final jobList = controller.jobs;
                final isLoadingMore = controller.isLoadingMore.value;

                if (isLoading) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: LoadingIndicator(),
                  );
                }

                if (hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ErrorState(
                          icon: Icons.cloud_off_rounded,
                          title: 'Unable to load jobs',
                          subtitle: 'Check your connection and try again',
                          iconColor: colorScheme.error.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: controller.refreshJobs,
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

                if (jobList.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorState(
                      icon: Icons.work_off_outlined,
                      title: 'No jobs found',
                      subtitle: 'Try a different search or filter',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == jobList.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        );
                      }

                      if (index == jobList.length - 3) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          controller.loadMore();
                        });
                      }

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < jobList.length - 1 ? 12 : 0,
                        ),
                        child: JobCard(job: jobList[index]),
                      );
                    }, childCount: jobList.length + (isLoadingMore ? 1 : 0)),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
