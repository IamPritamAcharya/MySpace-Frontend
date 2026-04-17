import 'package:get/get.dart';
import 'package:myspace/data/models/contest_model.dart';
import 'package:myspace/data/services/contest_service.dart';

class ContestController extends GetxController {
  final contests = <Contest>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContests();
  }

  Future<void> fetchContests() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    try {
      final data = await ContestService.getContests();
      contests.assignAll(data);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshContests() => fetchContests();
}
