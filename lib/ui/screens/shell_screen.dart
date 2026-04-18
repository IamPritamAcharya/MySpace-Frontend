import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myspace/controllers/navigation_controller.dart';
import 'package:myspace/ui/screens/home_screen.dart';
import 'package:myspace/ui/screens/explore_screen.dart';
import 'package:myspace/ui/screens/jobs_screen.dart';
import 'package:myspace/ui/screens/profile_screen.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final nav = Get.find<NavigationController>();

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: nav.selectedIndex.value,
          children: const [
            HomeScreen(),
            ExploreScreen(),
            JobsScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: nav.selectedIndex.value,
          onDestinationSelected: nav.changePage,
          backgroundColor: colorScheme.surface,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline_rounded),
              selectedIcon: Icon(Icons.work_rounded),
              label: 'Jobs',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
