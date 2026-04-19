import 'package:cloud_firestore/cloud_firestore.dart';

class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String url;
  final String imageUrl;
  final String source;
  final String sourceDomain;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final double score;
  final List<String> tags;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.sourceDomain,
    this.publishedAt,
    required this.createdAt,
    required this.score,
    required this.tags,
  });

  factory NewsArticle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NewsArticle(
      id: doc.id,
      title: data['title'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
      url: data['url'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      source: data['source'] as String? ?? '',
      sourceDomain: data['sourceDomain'] as String? ?? '',
      publishedAt: _parseEpochMs(data['publishedAt']),
      createdAt: _parseEpochMs(data['createdAt']) ?? DateTime.now(),
      score: (data['score'] as num?)?.toDouble() ?? 0.0,
      tags: List<String>.from(data['tags'] as List? ?? []),
    );
  }

  String get timeAgo {
    final ref = publishedAt ?? createdAt;
    final diff = DateTime.now().difference(ref);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String get displaySource =>
      sourceDomain.isNotEmpty ? sourceDomain : source;

  static DateTime? _parseEpochMs(dynamic value) {
    if (value == null) return null;
    final ms = (value as num).toInt();
    if (ms == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
