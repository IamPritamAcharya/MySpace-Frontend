import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myspace/data/models/news_article.dart';

class NewsService {
  NewsService._();

  static final _db = FirebaseFirestore.instance;

  static Future<List<NewsArticle>> fetchFeed({int limit = 30}) async {
    final snapshot = await _db
        .collection('news')
        .orderBy('score', descending: true)
        .limit(limit)
        .get(const GetOptions(source: Source.serverAndCache));
    return snapshot.docs.map(NewsArticle.fromFirestore).toList();
  }

  static Stream<List<NewsArticle>> feedStream({int limit = 30}) {
    return _db
        .collection('news')
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(NewsArticle.fromFirestore).toList());
  }

  static Future<List<NewsArticle>> fetchByTag(
    String tag, {
    int limit = 20,
  }) async {
    final snapshot = await _db
        .collection('news')
        .where('tags', arrayContains: tag)
        .orderBy('score', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(NewsArticle.fromFirestore).toList();
  }
}
