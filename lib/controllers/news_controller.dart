import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:myspace/controllers/navigation_controller.dart';
import 'package:myspace/data/models/news_article.dart';
import 'package:myspace/data/services/news_service.dart';

class NewsController extends GetxController {
  final articles = <NewsArticle>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final currentPage = 0.obs;

  final _validImageIds = <String>{};

  bool _initialFetchDone = false;

  static const int _exploreTabIndex = 1;

  @override
  void onInit() {
    super.onInit();

    final nav = Get.find<NavigationController>();

    if (nav.selectedIndex.value == _exploreTabIndex) {
      _doInitialFetch();
    }

    ever(nav.selectedIndex, (index) {
      if (index == _exploreTabIndex && !_initialFetchDone) {
        _doInitialFetch();
      }
    });
  }

  void _doInitialFetch() {
    _initialFetchDone = true;
    fetchArticles();
  }

  bool hasValidImage(String articleId) => _validImageIds.contains(articleId);

  Future<void> fetchArticles() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await NewsService.fetchFeed(limit: 30);

      _validImageIds.clear();
      await _prevalidateImages(result);

      articles.assignAll(result);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshArticles() async {
    await fetchArticles();
    currentPage.value = 0;
  }

  Future<void> _prevalidateImages(List<NewsArticle> results) async {
    final futures = results.where((a) => a.imageUrl.isNotEmpty).map((a) async {
      try {
        final response = await http
            .head(Uri.parse(a.imageUrl))
            .timeout(const Duration(seconds: 3));
        if (response.statusCode >= 200 && response.statusCode < 400) {
          _validImageIds.add(a.id);
        }
      } catch (_) {}
    });
    await Future.wait(futures);
  }
}
