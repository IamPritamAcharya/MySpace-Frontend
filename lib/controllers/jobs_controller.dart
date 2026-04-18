import 'package:get/get.dart';
import 'package:myspace/controllers/navigation_controller.dart';
import 'package:myspace/data/models/job_listing.dart';
import 'package:myspace/data/services/jobs_service.dart';

class JobsController extends GetxController {
  final jobs = <JobListing>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final searchQuery = ''.obs;
  final selectedTags = <String>[].obs;

  int _currentPage = 1;
  bool _hasMore = true;
  static const int _pageSize = 15;

  bool _initialFetchDone = false;

  static const int _jobsTabIndex = 2;

  static const List<String> availableTags = [
    'internship',
    'entry level',
    'remote',
    'flutter',
    'react',
    'java',
    'python',
    'data analyst',
    'machine learning',
    'qa',
    'ui-ux',
    'android',
    'devops',
    'security',
    'sales',
    'marketing',
    'content writer',
    'business analyst',
    'support',
    'campus',
  ];

  @override
  void onInit() {
    super.onInit();

    final nav = Get.find<NavigationController>();

    if (nav.selectedIndex.value == _jobsTabIndex) {
      _doInitialFetch();
    }

    ever(nav.selectedIndex, (index) {
      if (index == _jobsTabIndex && !_initialFetchDone) {
        _doInitialFetch();
      }
    });
  }

  void _doInitialFetch() {
    _initialFetchDone = true;
    fetchJobs();
  }

  void submitSearch(String value) {
    searchQuery.value = value.trim();
    _resetAndFetch();
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    _resetAndFetch();
  }

  Future<void> refreshJobs() => _resetAndFetch();

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasMore) return;
    isLoadingMore.value = true;

    try {
      final response = await JobsService.searchJobs(
        q: searchQuery.value.isEmpty ? null : searchQuery.value,
        tags: selectedTags.isEmpty ? null : selectedTags.toList(),
        page: _currentPage + 1,
        size: _pageSize,
      );
      jobs.addAll(response.items);
      _currentPage = response.page;
      _hasMore = response.hasNextPage;
    } catch (_) {
    } finally {
      isLoadingMore.value = false;
    }
  }

  bool get hasMore => _hasMore;

  Future<void> _resetAndFetch() async {
    _currentPage = 1;
    _hasMore = true;
    jobs.clear();
    await fetchJobs();
  }

  Future<void> fetchJobs() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final response = await JobsService.searchJobs(
        q: searchQuery.value.isEmpty ? null : searchQuery.value,
        tags: selectedTags.isEmpty ? null : selectedTags.toList(),
        page: _currentPage,
        size: _pageSize,
      );
      jobs.assignAll(response.items);
      _currentPage = response.page;
      _hasMore = response.hasNextPage;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
