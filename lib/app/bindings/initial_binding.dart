import 'package:get/get.dart';
import 'package:myspace/controllers/navigation_controller.dart';
import 'package:myspace/controllers/contest_controller.dart';
import 'package:myspace/controllers/jobs_controller.dart';
import 'package:myspace/controllers/news_controller.dart';
import 'package:myspace/controllers/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController());
    Get.lazyPut(() => NavigationController());
    Get.lazyPut(() => ContestController());
    Get.lazyPut(() => JobsController());
    Get.lazyPut(() => NewsController());
  }
}
