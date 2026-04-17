import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myspace/controllers/contest_controller.dart';
import 'package:myspace/ui/widgets/contest_card.dart';
import 'package:myspace/ui/widgets/error_state.dart';
import 'package:myspace/ui/widgets/loading_indicator.dart';

class ContestListWidget extends StatelessWidget {
  const ContestListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<ContestController>();

    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }

        if (controller.hasError.value) {
          return ErrorState(
            icon: Icons.cloud_off_rounded,
            title: 'Unable to load contests',
            subtitle: 'Check your connection',
            iconColor: colorScheme.error.withValues(alpha: 0.7),
          );
        }

        if (controller.contests.isEmpty) {
          return const ErrorState(
            icon: Icons.event_available_outlined,
            title: 'No upcoming contests',
            subtitle: 'Check back soon',
          );
        }

        return ListView.separated(
          itemCount: controller.contests.length,
          padding: const EdgeInsets.all(12),
          physics: const ClampingScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) =>
              ContestCard(contest: controller.contests[index]),
        );
      }),
    );
  }
}
