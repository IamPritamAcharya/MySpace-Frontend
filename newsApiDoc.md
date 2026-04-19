# Firebase Integration Guide — Flutter News App

> **Architecture:** The Flutter frontend reads **directly from Firestore**.
> The Spring Boot backend (`https://devdevgo-newsservice.onrender.com`) runs as a
> background pipeline only — it fetches, ranks, summarises, and writes articles to
> Firestore on a schedule. The app **never calls backend REST APIs** except the
> health/status endpoints listed at the bottom of this doc.

---

## Table of Contents

1. [Firestore Collections Overview](#1-firestore-collections-overview)
2. [Collection: `news`](#2-collection-news)
3. [Collection: `system_state`](#3-collection-system_state)
4. [Collection: `recent_articles` _(internal, do not read)_](#4-collection-recent_articles)
5. [Flutter Firestore Queries — Full Reference](#5-flutter-firestore-queries--full-reference)
6. [Data Types & Field Reference](#6-data-types--field-reference)
7. [Tags Reference](#7-tags-reference)
8. [Score & Ranking Logic](#8-score--ranking-logic)
9. [Firestore Security Rules (Recommended)](#9-firestore-security-rules-recommended)
10. [Flutter Setup Checklist](#10-flutter-setup-checklist)
11. [Backend Health Endpoints (Optional)](#11-backend-health-endpoints-optional)
12. [Error Handling Patterns](#12-error-handling-patterns)
13. [Sample Flutter Service Class](#13-sample-flutter-service-class)

---

## 1. Firestore Collections Overview

| Collection        | Written by    | Read by Flutter? | Purpose                                    |
|-------------------|---------------|------------------|--------------------------------------------|
| `news`            | Backend       | ✅ YES            | Published, summarised, ranked articles     |
| `system_state`    | Backend       | ✅ Optional       | Last pipeline run status & timestamp       |
| `recent_articles` | Backend       | ❌ NO             | Internal dedup memory (48 h TTL, internal) |

---

## 2. Collection: `news`

### Document ID
Each document uses a **UUID derived from the article URL** — meaning re-runs are
idempotent. The same article is never duplicated; it is overwritten in place.

```
news/{uuid}
```

Example ID: `"3f2504e0-4f89-11d3-9a0c-0305e82c3301"`

---

### Full Document Shape

```jsonc
{
  // ─── Identity ──────────────────────────────────────────────────────
  "title":        "String   — Full headline of the article",
  "summary":      "String   — Gemini-generated summary, ≤ 60–80 words, developer-focused",
  "url":          "String   — Canonical article URL (full, with https://)",
  "imageUrl":     "String   — Hero image URL (may be empty string \"\" if unavailable)",

  // ─── Source ────────────────────────────────────────────────────────
  "source":       "String   — Fetcher source identifier (see Source IDs below)",
  "sourceDomain": "String   — Bare domain, e.g. \"techcrunch.com\" (no www, no https)",

  // ─── Timestamps (epoch milliseconds, stored as Number) ─────────────
  "publishedAt":  1713500400000,   // When the article was originally published
  "createdAt":    1713523812000,   // When the backend wrote it to Firestore

  // ─── Ranking ───────────────────────────────────────────────────────
  "score":        7.84,            // Final composite ranking score (0–10 approx)

  // ─── Taxonomy ──────────────────────────────────────────────────────
  "tags":         ["AI", "Open Source", "TechCrunch"]  // Up to 5 tags (see §7)
}
```

---

### Field-by-Field Reference

| Field         | Type     | Nullable / Empty? | Notes                                                                 |
|---------------|----------|--------------------|-----------------------------------------------------------------------|
| `title`       | `String` | Never empty        | Original headline, not truncated                                      |
| `summary`     | `String` | Never empty        | 5–80 words. Falls back to description or title if Gemini fails        |
| `url`         | `String` | Never empty        | Full article URL, use for "Read more"                                  |
| `imageUrl`    | `String` | May be `""`        | Always check for empty before loading. Use placeholder if empty        |
| `source`      | `String` | Never empty        | One of the Source IDs listed below                                    |
| `sourceDomain`| `String` | May be `""`        | Bare domain for display. Use for source chip/badge in UI              |
| `publishedAt` | `Number` | May be `0`         | Epoch ms. `0` means unknown. Always guard against 0 before formatting |
| `createdAt`   | `Number` | Never 0            | Epoch ms. Use this for "freshness" sorting if needed                  |
| `score`       | `Number` | Never null         | Float, roughly 0–10. Higher = better ranked                           |
| `tags`        | `Array<String>` | May be `[]` | Up to 5 items. May include source name as last element           |

---

### Source IDs (`source` field values)

| Value          | Description                                           |
|----------------|-------------------------------------------------------|
| `"gnews"`      | GNews API — top technology headlines                  |
| `"hackernews"` | Hacker News — stories with score ≥ 50                 |
| `"reddit"`     | Reddit r/programming, r/technology (upvotes ≥ 100)    |
| `"rss"`        | RSS feeds — articles published within last 12 hours   |

---

### Example Real Document

```jsonc
{
  "title":        "Anthropic releases Claude 3.5 Haiku with major speed improvements",
  "summary":      "Anthropic's Claude 3.5 Haiku delivers 3x faster inference than its predecessor while maintaining strong coding and reasoning performance. Available via API immediately, with pricing unchanged from the previous Haiku model. Developers can access it through the standard Messages endpoint.",
  "url":          "https://techcrunch.com/2025/04/18/anthropic-releases-claude-3-5-haiku",
  "imageUrl":     "https://techcrunch.com/wp-content/uploads/2025/04/anthropic-haiku.jpg",
  "source":       "gnews",
  "sourceDomain": "techcrunch.com",
  "publishedAt":  1713500400000,
  "createdAt":    1713523812000,
  "score":        8.74,
  "tags":         ["AI", "LLM", "Open Source", "TechCrunch"]
}
```

---

## 3. Collection: `system_state`

Single document: `system_state/news_fetch`

Used to know when the pipeline last ran — useful for a "Last updated X minutes ago"
indicator in your app's header or settings screen.

### Document Shape

```jsonc
{
  "lastFetchedAt":    1713523812000,  // Epoch ms of last successful pipeline run
  "lastRunStatus":   "success",       // "success" | "failed: <reason>" | "never"
  "lastArticleCount": 28              // Number of articles saved in the last run
}
```

### Field Reference

| Field               | Type     | Notes                                                         |
|---------------------|----------|---------------------------------------------------------------|
| `lastFetchedAt`     | `Number` | Epoch ms. `0` means the pipeline has never run               |
| `lastRunStatus`     | `String` | `"success"` or `"failed: <reason>"` or `"never"`             |
| `lastArticleCount`  | `Number` | Integer, 0–30. Useful for debug/status screens                |

---

## 4. Collection: `recent_articles`

> ⛔ **Do not read this collection in Flutter.** It is internal dedup memory used
> by the backend pipeline. Documents have a 48-hour TTL and are automatically
> cleaned up by the backend. Reading this collection from the app is wasteful and
> provides no useful information to the user.

---

## 5. Flutter Firestore Queries — Full Reference

### 5.1 Fetch top 30 articles (default home feed)

```dart
final snapshot = await FirebaseFirestore.instance
    .collection('news')
    .orderBy('score', descending: true)
    .limit(30)
    .get();
```

> The backend always maintains exactly 30 top articles (configurable via
> `news.pipeline.top-articles`). The `score` field is the composite ranking score.

---

### 5.2 Real-time feed with live updates

```dart
FirebaseFirestore.instance
    .collection('news')
    .orderBy('score', descending: true)
    .limit(30)
    .snapshots()
    .listen((snapshot) {
      final articles = snapshot.docs.map((doc) {
        return NewsArticle.fromFirestore(doc);
      }).toList();
      // update state
    });
```

---

### 5.3 Filter by tag

```dart
final snapshot = await FirebaseFirestore.instance
    .collection('news')
    .where('tags', arrayContains: 'AI')
    .orderBy('score', descending: true)
    .limit(20)
    .get();
```

> ⚠️ Requires a **composite index** on `(tags, score DESC)` in Firestore.
> Create it in the Firebase console or via `firestore.indexes.json`.

---

### 5.4 Filter by source

```dart
final snapshot = await FirebaseFirestore.instance
    .collection('news')
    .where('source', isEqualTo: 'hackernews')
    .orderBy('score', descending: true)
    .limit(20)
    .get();
```

> ⚠️ Requires a **composite index** on `(source, score DESC)`.

---

### 5.5 Filter by source domain (for publisher pages)

```dart
final snapshot = await FirebaseFirestore.instance
    .collection('news')
    .where('sourceDomain', isEqualTo: 'techcrunch.com')
    .orderBy('score', descending: true)
    .limit(10)
    .get();
```

---

### 5.6 Get articles newer than N hours (recency filter)

```dart
final cutoff = DateTime.now().subtract(Duration(hours: 12));
final cutoffMs = cutoff.millisecondsSinceEpoch;

final snapshot = await FirebaseFirestore.instance
    .collection('news')
    .where('publishedAt', isGreaterThan: cutoffMs)
    .orderBy('publishedAt', descending: true)
    .limit(20)
    .get();
```

> ⚠️ Articles with `publishedAt == 0` (unknown publish time) will be excluded
> by this query. This is intentional — prefer `createdAt` if you want to
> include all articles.

---

### 5.7 Read pipeline status (optional)

```dart
final doc = await FirebaseFirestore.instance
    .collection('system_state')
    .doc('news_fetch')
    .get();

if (doc.exists) {
  final data = doc.data()!;
  final lastFetchedAt = DateTime.fromMillisecondsSinceEpoch(
    (data['lastFetchedAt'] as num).toInt()
  );
  final status = data['lastRunStatus'] as String;
  final count  = data['lastArticleCount'] as int;
}
```

---

## 6. Data Types & Field Reference

### Timestamp handling

All timestamps are stored as **epoch milliseconds** (Number/int64), NOT as
Firestore `Timestamp` objects. Convert them in Dart like this:

```dart
// Safe conversion — handles 0 (unknown) gracefully
DateTime? parseEpochMs(dynamic value) {
  if (value == null) return null;
  final ms = (value as num).toInt();
  if (ms == 0) return null;
  return DateTime.fromMillisecondsSinceEpoch(ms);
}
```

### Dart model class

```dart
class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String url;
  final String imageUrl;       // may be empty
  final String source;
  final String sourceDomain;   // may be empty
  final DateTime? publishedAt; // null if unknown (was 0)
  final DateTime createdAt;
  final double score;
  final List<String> tags;

  NewsArticle({
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
      id:           doc.id,
      title:        data['title']        as String? ?? '',
      summary:      data['summary']      as String? ?? '',
      url:          data['url']          as String? ?? '',
      imageUrl:     data['imageUrl']     as String? ?? '',
      source:       data['source']       as String? ?? '',
      sourceDomain: data['sourceDomain'] as String? ?? '',
      publishedAt:  _parseEpochMs(data['publishedAt']),
      createdAt:    _parseEpochMs(data['createdAt']) ?? DateTime.now(),
      score:        (data['score']       as num?)?.toDouble() ?? 0.0,
      tags:         List<String>.from(data['tags'] as List? ?? []),
    );
  }

  static DateTime? _parseEpochMs(dynamic value) {
    if (value == null) return null;
    final ms = (value as num).toInt();
    if (ms == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
```

---

## 7. Tags Reference

Tags are derived automatically from article title + description keywords.
Up to 5 tags per article. The last tag is often the source name.

| Tag              | Triggered by keyword(s)                                   |
|------------------|-----------------------------------------------------------|
| `"AI"`           | "ai", "artificial intelligence"                           |
| `"Machine Learning"` | "machine learning", "deep learning", "neural"         |
| `"LLM"`          | "llm", "gpt", "claude", "gemini", "openai", "anthropic"  |
| `"Flutter"`      | "flutter", "dart"                                         |
| `"Python"`       | "python"                                                  |
| `"JavaScript"`   | "javascript"                                              |
| `"TypeScript"`   | "typescript"                                              |
| `"Rust"`         | "rust"                                                    |
| `"Go"`           | "go" (language context)                                   |
| `"Java"`         | "java"                                                    |
| `"Kubernetes"`   | "kubernetes", "k8s"                                       |
| `"Docker"`       | "docker", "container"                                     |
| `"Cloud"`        | "cloud", "aws", "gcp", "azure"                            |
| `"Security"`     | "security", "vulnerability", "breach"                     |
| `"Open Source"`  | "open source", "github"                                   |
| `"Android"`      | "android"                                                 |
| `"iOS"`          | "ios", "swift"                                            |
| `"React"`        | "react"                                                   |
| `"Blockchain"`   | "blockchain", "crypto"                                    |
| `"Startup"`      | "startup", "funding", "acquisition", "ipo"                |

> The source name (e.g. `"Hacker News"`, `"TechCrunch"`) is appended as the
> last tag automatically when it fits within the 5-tag limit.

---

## 8. Score & Ranking Logic

The `score` field in each document is a composite float computed by the backend's
`RankingEngine`. Understanding it helps you decide when to re-sort or filter in UI.

```
score = (recencyScore × 0.4)
      + (sourceScore  × 0.2)
      + (engagementScore × 0.2)
      + (titleQualityScore × 0.1)
      + (keywordBoost × 0.1)
```

| Component          | Range    | Weight | Description                                             |
|--------------------|----------|--------|---------------------------------------------------------|
| `recencyScore`     | 0–10     | 40%    | Linear decay: 0h = 10, 12h = 5, 24h+ = 0               |
| `sourceScore`      | 0–10     | 20%    | Trusted domain list. Unknown sources default to 5.0     |
| `engagementScore`  | 0–10     | 20%    | Log-scaled upvotes + comments (HN/Reddit). RSS = 3.0    |
| `titleQualityScore`| –5 to +5 | 10%    | Penalises clickbait & short titles; rewards clear titles|
| `keywordBoost`     | 0–3      | 10%    | Bonus for trending tech keywords in title/description   |

**Expected score ranges in practice:**
- `> 8.0` — Excellent: recent, from top source, high engagement
- `6.0–8.0` — Good: solid recency + reputable source
- `4.0–6.0` — Average: older or unknown source
- `< 4.0` — Lower quality, may be older than 12 hours

**Diversity rule:** Max 5 articles from any single `sourceDomain` in the top 30.

---

## 9. Firestore Security Rules (Recommended)

Since the Flutter app only reads `news` and `system_state`, lock down everything else.
The backend uses a service account with admin SDK — rules do not apply to it.

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Public read: anyone can browse the news feed
    match /news/{articleId} {
      allow read: true;
      allow write: false;  // only backend service account writes
    }

    // Public read: pipeline status (for "last updated" UI)
    match /system_state/{docId} {
      allow read: true;
      allow write: false;
    }

    // BLOCK all access: internal dedup collection
    match /recent_articles/{docId} {
      allow read, write: false;
    }

    // Deny everything else
    match /{document=**} {
      allow read, write: false;
    }
  }
}
```

> If you add **user authentication** later (bookmarks, preferences), add a
> `users/{userId}` rule with `allow read, write: if request.auth.uid == userId;`

---

## 10. Flutter Setup Checklist

### 1. Add dependencies to `pubspec.yaml`

```yaml
dependencies:
  firebase_core: ^3.x.x
  cloud_firestore: ^5.x.x
  # optional, if adding auth later:
  # firebase_auth: ^5.x.x
```

### 2. Run FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

This generates `lib/firebase_options.dart`.

### 3. Initialise in `main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### 4. Enable Firestore offline persistence (recommended)

```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

Call this **before** any Firestore reads, right after `Firebase.initializeApp`.

### 5. Required Firestore Indexes

Create these composite indexes in the Firebase console or via `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "news",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "tags",  "arrayConfig": "CONTAINS" },
        { "fieldPath": "score", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "news",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "source", "order": "ASCENDING" },
        { "fieldPath": "score",  "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "news",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "sourceDomain", "order": "ASCENDING" },
        { "fieldPath": "score",        "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "news",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "publishedAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

> The `score` single-field index is created automatically by Firestore.

---

## 11. Backend Health Endpoints (Optional)

The Spring Boot backend exposes three lightweight REST endpoints.
The Flutter app does **not** need to call these in normal operation —
they are for monitoring and DevOps use only.

### `GET /api/health`

Keep-alive / uptime check. Used by Render to prevent cold starts.
Can be pinged from a settings screen or a background isolate.

**Response `200 OK`:**
```json
{
  "status":    "UP",
  "timestamp": "2025-04-19T10:30:00.000Z",
  "service":   "news-aggregator"
}
```

| Field       | Type     | Description                          |
|-------------|----------|--------------------------------------|
| `status`    | `String` | Always `"UP"` if backend is running  |
| `timestamp` | `String` | ISO-8601 UTC timestamp               |
| `service`   | `String` | Always `"news-aggregator"`           |

---

### `GET /api/status`

Returns the current pipeline state from Firestore's `system_state/news_fetch`.
Useful for a debug / admin screen.

**Response `200 OK`:**
```json
{
  "lastFetchedAt":    "2025-04-19T09:00:12.000Z",
  "lastRunStatus":    "success",
  "lastArticleCount": 28,
  "timestamp":        "2025-04-19T10:30:00.000Z"
}
```

| Field               | Type     | Description                                             |
|---------------------|----------|---------------------------------------------------------|
| `lastFetchedAt`     | `String` | ISO-8601 UTC. `"1970-01-01T00:00:00Z"` = never run     |
| `lastRunStatus`     | `String` | `"success"` \| `"failed: <reason>"` \| `"never"`       |
| `lastArticleCount`  | `Number` | Articles saved in last run (0–30)                       |
| `timestamp`         | `String` | When this response was generated                        |

**Response `500 Internal Server Error`** (Firestore unreachable):
```json
{
  "error":     "Could not connect to Firestore",
  "timestamp": "2025-04-19T10:30:00.000Z"
}
```

---

### `POST /api/trigger` (or `GET /api/trigger`)

Manually triggers the news pipeline. **Do not expose this to end users.**
This is for GitHub Actions / cron pings only.

**Response `202 Accepted`:**
```json
{
  "message":   "Pipeline trigger accepted",
  "timestamp": "2025-04-19T10:30:00.000Z"
}
```

> The pipeline runs asynchronously. The 202 response only confirms the trigger
> was received — not that it completed. Poll `/api/status` or watch Firestore
> for the updated `system_state/news_fetch` doc.

---

## 12. Error Handling Patterns

### Empty `imageUrl`

```dart
imageUrl.isEmpty
    ? const AssetImage('assets/placeholder.png')
    : NetworkImage(imageUrl)
```

### Unknown `publishedAt` (value is 0)

```dart
final published = article.publishedAt;
final displayTime = published != null
    ? timeago.format(published)
    : 'Recently';
```

### Firestore query failures

```dart
try {
  final snapshot = await FirebaseFirestore.instance
      .collection('news')
      .orderBy('score', descending: true)
      .limit(30)
      .get(const GetOptions(source: Source.serverAndCache));
} on FirebaseException catch (e) {
  // e.code: 'unavailable', 'permission-denied', 'not-found'
  debugPrint('Firestore error: ${e.code} — ${e.message}');
  // Fall back to cached data automatically via offline persistence
}
```

### Empty `sourceDomain`

```dart
final displayDomain = article.sourceDomain.isNotEmpty
    ? article.sourceDomain
    : article.source; // fallback to source ID
```

---

## 13. Sample Flutter Service Class

A complete, production-ready service encapsulating all Firestore reads:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Home feed: top 30 by score ──────────────────────────────────────
  Future<List<NewsArticle>> fetchFeed({int limit = 30}) async {
    final snapshot = await _db
        .collection('news')
        .orderBy('score', descending: true)
        .limit(limit)
        .get(const GetOptions(source: Source.serverAndCache));
    return snapshot.docs.map(NewsArticle.fromFirestore).toList();
  }

  // ── Real-time home feed ─────────────────────────────────────────────
  Stream<List<NewsArticle>> feedStream({int limit = 30}) {
    return _db
        .collection('news')
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(NewsArticle.fromFirestore).toList());
  }

  // ── Filter by tag ───────────────────────────────────────────────────
  Future<List<NewsArticle>> fetchByTag(String tag, {int limit = 20}) async {
    final snapshot = await _db
        .collection('news')
        .where('tags', arrayContains: tag)
        .orderBy('score', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(NewsArticle.fromFirestore).toList();
  }

  // ── Filter by source ────────────────────────────────────────────────
  Future<List<NewsArticle>> fetchBySource(String source, {int limit = 20}) async {
    final snapshot = await _db
        .collection('news')
        .where('source', isEqualTo: source)
        .orderBy('score', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(NewsArticle.fromFirestore).toList();
  }

  // ── Pipeline status ─────────────────────────────────────────────────
  Future<PipelineStatus?> fetchPipelineStatus() async {
    final doc = await _db.collection('system_state').doc('news_fetch').get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return PipelineStatus(
      lastFetchedAt: NewsArticle._parseEpochMs(data['lastFetchedAt']),
      lastRunStatus: data['lastRunStatus'] as String? ?? 'unknown',
      lastArticleCount: (data['lastArticleCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class PipelineStatus {
  final DateTime? lastFetchedAt;
  final String lastRunStatus;
  final int lastArticleCount;

  PipelineStatus({
    this.lastFetchedAt,
    required this.lastRunStatus,
    required this.lastArticleCount,
  });

  bool get isSuccess => lastRunStatus == 'success';
}
```

---

_Last updated: April 2026. Generated from codebase analysis of `devdevgo-newsservice`._