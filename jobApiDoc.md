# DevDevGo Jobs Service — API Documentation

**Base URL:** `https://devdevgo-jobservice.onrender.com`  
**API Version:** `v1`  
**Content-Type:** `application/json`  
**Protocol:** HTTP/HTTPS (reactive, non-blocking)

---

## Table of Contents

1. [Overview](#overview)
2. [Endpoints](#endpoints)
   - [GET /ping](#1-ping)
   - [GET /search](#2-search-jobs)
   - [POST /sync](#3-trigger-sync)
3. [Response Models](#response-models)
4. [Error Handling](#error-handling)
5. [Flutter Integration Guide](#flutter-integration-guide)
   - [Service Class](#flutter-service-class)
   - [Data Models](#flutter-data-models)
   - [Usage Examples](#usage-examples)

---

## Overview

The DevDevGo Jobs Service is a Spring Boot reactive REST API that aggregates job listings from the Adzuna API, stores them in Firestore, and exposes them for search. Jobs are auto-synced every hour via a background scheduler.

**Auto-tagging** is performed on every job listing. Supported tags include:

`internship` · `entry level` · `remote` · `flutter` · `react` · `java` · `python` · `data analyst` · `machine learning` · `qa` · `ui-ux` · `android` · `devops` · `security` · `sales` · `marketing` · `content writer` · `business analyst` · `support` · `campus`

---

## Endpoints

### 1. Ping

**`GET /api/v1/jobs/ping`**

Health check endpoint. Returns service status and current server timestamp.

#### Request

No parameters required.

```http
GET https://devdevgo-jobservice.onrender.com/api/v1/jobs/ping
```

#### Response — `200 OK`

```json
{
  "timestamp": "2026-04-18T10:00:00.000Z",
  "status": 200,
  "message": "devdevgo jobs service is running",
  "path": "/api/v1/jobs/ping"
}
```

| Field       | Type     | Description                          |
|-------------|----------|--------------------------------------|
| `timestamp` | `String` | ISO-8601 UTC timestamp of the response |
| `status`    | `int`    | HTTP status code (`200`)             |
| `message`   | `String` | Human-readable status message        |
| `path`      | `String` | The request path                     |

---

### 2. Search Jobs

**`GET /api/v1/jobs/search`**

Search the locally stored job listings with keyword, location, and tag filtering. Results are ranked by relevance scoring:

| Match Location | Score Points |
|----------------|-------------|
| Job **title** contains token | +10 per token |
| **Company name** contains token | +5 per token |
| Full **description/text** contains token | +2 per token |

Within equal scores, more recently fetched jobs appear first.

#### Request

```http
GET https://devdevgo-jobservice.onrender.com/api/v1/jobs/search?q=flutter&location=bangalore&tag=remote&page=1&size=10
```

#### Query Parameters

| Parameter  | Type       | Required | Default | Description |
|------------|------------|----------|---------|-------------|
| `q`        | `String`   | No       | `null`  | Keyword search. Matched against title, company, and description. Supports multi-word (space-separated tokens — all must match). |
| `location` | `String`   | No       | `null`  | Location filter. Matched against job location and search region (case-insensitive substring match). |
| `tag`      | `String[]` | No       | `null`  | One or more tag filters. All specified tags must be present on the job (AND logic). Repeat parameter for multiple: `?tag=flutter&tag=remote`. |
| `page`     | `int`      | No       | `1`     | 1-based page number. Minimum: `1`. |
| `size`     | `int`      | No       | `10`    | Number of results per page. Minimum: `1`. |

#### Response — `200 OK`

```json
{
  "total": 42,
  "page": 1,
  "size": 10,
  "items": [
    {
      "id": "adzuna::abc123",
      "title": "Flutter Developer",
      "company": "TechCorp India",
      "location": "Bangalore, Karnataka",
      "description": "We are looking for a skilled Flutter developer...",
      "redirectUrl": "https://www.adzuna.in/jobs/details/...",
      "createdAt": "2026-04-15T08:30:00Z",
      "contractType": "permanent",
      "contractTime": "full_time",
      "salaryMin": 800000.0,
      "salaryMax": 1500000.0,
      "salaryPredicted": false,
      "latitude": 12.9716,
      "longitude": 77.5946,
      "category": "IT Jobs",
      "categoryTag": "it-jobs",
      "source": "adzuna",
      "searchProfile": "flutter-india",
      "searchedWhat": "flutter developer",
      "searchedWhere": "india",
      "fetchedAt": "2026-04-18T09:00:00Z",
      "normalizedText": "flutter developer techcorp india bangalore...",
      "tags": ["flutter", "remote"]
    }
  ]
}
```

#### Response Fields

**Top-level:**

| Field   | Type           | Description |
|---------|----------------|-------------|
| `total` | `long`         | Total number of matched jobs (before pagination) |
| `page`  | `int`          | Current page number |
| `size`  | `int`          | Requested page size |
| `items` | `JobListing[]` | Array of job listing objects |

**`JobListing` object:**

| Field            | Type       | Nullable | Description |
|------------------|------------|----------|-------------|
| `id`             | `String`   | No       | Unique job identifier (from Adzuna or composite fallback) |
| `title`          | `String`   | Yes      | Job title |
| `company`        | `String`   | Yes      | Company name |
| `location`       | `String`   | Yes      | Human-readable location string |
| `description`    | `String`   | Yes      | Full job description |
| `redirectUrl`    | `String`   | Yes      | Original Adzuna job listing URL |
| `createdAt`      | `String`   | Yes      | ISO-8601 date the job was posted on Adzuna |
| `contractType`   | `String`   | Yes      | e.g. `permanent`, `contract` |
| `contractTime`   | `String`   | Yes      | e.g. `full_time`, `part_time` |
| `salaryMin`      | `double`   | Yes      | Minimum salary (currency: INR for Indian listings) |
| `salaryMax`      | `double`   | Yes      | Maximum salary |
| `salaryPredicted`| `boolean`  | No       | `true` if salary is Adzuna's estimate, not employer-stated |
| `latitude`       | `double`   | Yes      | Latitude for map display |
| `longitude`      | `double`   | Yes      | Longitude for map display |
| `category`       | `String`   | Yes      | Job category label (e.g. `IT Jobs`) |
| `categoryTag`    | `String`   | Yes      | Machine-readable category tag (e.g. `it-jobs`) |
| `source`         | `String`   | No       | Always `"adzuna"` |
| `searchProfile`  | `String`   | Yes      | Internal search profile that fetched this job |
| `searchedWhat`   | `String`   | Yes      | The keyword used to find this job |
| `searchedWhere`  | `String`   | Yes      | The region used to find this job |
| `fetchedAt`      | `String`   | No       | ISO-8601 timestamp when the job was synced |
| `normalizedText` | `String`   | Yes      | Lowercased concatenated text (used for search) |
| `tags`           | `String[]` | No       | Auto-extracted tags (see Overview for full list) |

---

### 3. Trigger Sync

**`POST /api/v1/jobs/sync`**

Manually triggers a job sync from the Adzuna API. Fetches the next batch of search profiles and upserts results into Firestore (or in-memory store). The scheduler also calls this automatically every hour.

#### Request

```http
POST https://devdevgo-jobservice.onrender.com/api/v1/jobs/sync?batchSize=2
```

#### Query Parameters

| Parameter   | Type  | Required | Default | Description |
|-------------|-------|----------|---------|-------------|
| `batchSize` | `int` | No       | `2`     | Number of search profiles to process in this sync run. Minimum: `1`. Maximum recommended: `8` (to stay within Adzuna's 250 req/day free-tier limit). |

#### Response — `200 OK`

```json
{
  "firebaseEnabled": true,
  "queriesRun": 2,
  "jobsFetched": 20,
  "jobsSaved": 18,
  "profiles": ["flutter-india", "react-india"],
  "startedAt": "2026-04-18T10:00:00.000Z",
  "finishedAt": "2026-04-18T10:00:03.412Z",
  "note": "Synced jobs into Firestore"
}
```

| Field             | Type       | Description |
|-------------------|------------|-------------|
| `firebaseEnabled` | `boolean`  | Whether Firestore persistence is active |
| `queriesRun`      | `int`      | Number of search profiles processed |
| `jobsFetched`     | `int`      | Total raw job listings fetched from Adzuna |
| `jobsSaved`       | `int`      | Listings actually written/updated in the store (deduped) |
| `profiles`        | `String[]` | Names of search profiles processed in this batch |
| `startedAt`       | `String`   | ISO-8601 sync start time |
| `finishedAt`      | `String`   | ISO-8601 sync end time |
| `note`            | `String`   | Human-readable status note |

---

## Response Models

### `PingResponse`

```json
{
  "timestamp": "String (ISO-8601)",
  "status": "int",
  "message": "String",
  "path": "String"
}
```

### `JobSearchResponse`

```json
{
  "total": "long",
  "page": "int",
  "size": "int",
  "items": [ /* JobListing[] */ ]
}
```

### `SyncReport`

```json
{
  "firebaseEnabled": "boolean",
  "queriesRun": "int",
  "jobsFetched": "int",
  "jobsSaved": "int",
  "profiles": [ "String" ],
  "startedAt": "String (ISO-8601)",
  "finishedAt": "String (ISO-8601)",
  "note": "String"
}
```

### `ApiErrorResponse`

```json
{
  "timestamp": "String (ISO-8601)",
  "status": "int",
  "error": "String",
  "message": "String",
  "path": "String"
}
```

---

## Error Handling

| HTTP Status | Trigger | `error` Field |
|-------------|---------|---------------|
| `400 Bad Request` | Invalid query parameters (e.g. negative page) | `"Bad Request"` |
| `502 Bad Gateway` | Adzuna API call failed during sync | `"Bad Gateway"` |
| `500 Internal Server Error` | Unexpected server-side error | `"Internal Server Error"` |

All errors share the `ApiErrorResponse` schema shown above.

---

## Flutter Integration Guide

### Flutter Service Class

```dart
// lib/services/jobs_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_listing.dart';
import '../models/job_search_response.dart';
import '../models/ping_response.dart';
import '../models/sync_report.dart';

class JobsApiService {
  static const String _baseUrl =
      'https://devdevgo-jobservice.onrender.com/api/v1/jobs';

  final http.Client _client;

  JobsApiService({http.Client? client}) : _client = client ?? http.Client();

  // ── Ping ────────────────────────────────────────────────────────────────────

  Future<PingResponse> ping() async {
    final response = await _client.get(Uri.parse('$_baseUrl/ping'));
    _assertOk(response);
    return PingResponse.fromJson(jsonDecode(response.body));
  }

  // ── Search Jobs ─────────────────────────────────────────────────────────────

  Future<JobSearchResponse> searchJobs({
    String? q,
    String? location,
    List<String>? tags,
    int page = 1,
    int size = 10,
  }) async {
    final queryParams = <String, String>{
      if (q != null && q.isNotEmpty) 'q': q,
      if (location != null && location.isNotEmpty) 'location': location,
      'page': page.toString(),
      'size': size.toString(),
    };

    var uri = Uri.parse('$_baseUrl/search').replace(queryParameters: queryParams);

    // Add multiple tag params manually (Uri doesn't support repeated keys natively)
    if (tags != null && tags.isNotEmpty) {
      final tagQuery = tags.map((t) => 'tag=${Uri.encodeQueryComponent(t)}').join('&');
      uri = Uri.parse('${uri.toString()}&$tagQuery');
    }

    final response = await _client.get(uri);
    _assertOk(response);
    return JobSearchResponse.fromJson(jsonDecode(response.body));
  }

  // ── Trigger Sync ─────────────────────────────────────────────────────────────

  Future<SyncReport> triggerSync({int batchSize = 2}) async {
    final uri = Uri.parse('$_baseUrl/sync').replace(
      queryParameters: {'batchSize': batchSize.toString()},
    );

    final response = await _client.post(uri);
    _assertOk(response);
    return SyncReport.fromJson(jsonDecode(response.body));
  }

  // ── Helper ───────────────────────────────────────────────────────────────────

  void _assertOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body);
      throw JobsApiException(
        statusCode: response.statusCode,
        error: body['error'] ?? 'Unknown error',
        message: body['message'] ?? response.reasonPhrase ?? '',
      );
    }
  }
}

class JobsApiException implements Exception {
  final int statusCode;
  final String error;
  final String message;

  const JobsApiException({
    required this.statusCode,
    required this.error,
    required this.message,
  });

  @override
  String toString() => 'JobsApiException($statusCode): $error — $message';
}
```

---

### Flutter Data Models

#### `lib/models/ping_response.dart`

```dart
class PingResponse {
  final String timestamp;
  final int status;
  final String message;
  final String path;

  const PingResponse({
    required this.timestamp,
    required this.status,
    required this.message,
    required this.path,
  });

  factory PingResponse.fromJson(Map<String, dynamic> json) => PingResponse(
        timestamp: json['timestamp'] as String,
        status: json['status'] as int,
        message: json['message'] as String,
        path: json['path'] as String,
      );
}
```

#### `lib/models/job_listing.dart`

```dart
class JobListing {
  final String id;
  final String? title;
  final String? company;
  final String? location;
  final String? description;
  final String? redirectUrl;
  final String? createdAt;
  final String? contractType;
  final String? contractTime;
  final double? salaryMin;
  final double? salaryMax;
  final bool salaryPredicted;
  final double? latitude;
  final double? longitude;
  final String? category;
  final String? categoryTag;
  final String source;
  final String? searchProfile;
  final String? searchedWhat;
  final String? searchedWhere;
  final String fetchedAt;
  final List<String> tags;

  const JobListing({
    required this.id,
    this.title,
    this.company,
    this.location,
    this.description,
    this.redirectUrl,
    this.createdAt,
    this.contractType,
    this.contractTime,
    this.salaryMin,
    this.salaryMax,
    this.salaryPredicted = false,
    this.latitude,
    this.longitude,
    this.category,
    this.categoryTag,
    required this.source,
    this.searchProfile,
    this.searchedWhat,
    this.searchedWhere,
    required this.fetchedAt,
    this.tags = const [],
  });

  factory JobListing.fromJson(Map<String, dynamic> json) => JobListing(
        id: json['id'] as String,
        title: json['title'] as String?,
        company: json['company'] as String?,
        location: json['location'] as String?,
        description: json['description'] as String?,
        redirectUrl: json['redirectUrl'] as String?,
        createdAt: json['createdAt'] as String?,
        contractType: json['contractType'] as String?,
        contractTime: json['contractTime'] as String?,
        salaryMin: (json['salaryMin'] as num?)?.toDouble(),
        salaryMax: (json['salaryMax'] as num?)?.toDouble(),
        salaryPredicted: json['salaryPredicted'] as bool? ?? false,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        category: json['category'] as String?,
        categoryTag: json['categoryTag'] as String?,
        source: json['source'] as String,
        searchProfile: json['searchProfile'] as String?,
        searchedWhat: json['searchedWhat'] as String?,
        searchedWhere: json['searchedWhere'] as String?,
        fetchedAt: json['fetchedAt'] as String,
        tags: List<String>.from(json['tags'] ?? []),
      );

  /// Returns a formatted salary range string, or null if unavailable.
  String? get salaryRange {
    if (salaryMin == null && salaryMax == null) return null;
    final suffix = salaryPredicted ? ' (estimated)' : '';
    if (salaryMin != null && salaryMax != null) {
      return '₹${_fmt(salaryMin!)} – ₹${_fmt(salaryMax!)}$suffix';
    }
    if (salaryMin != null) return '₹${_fmt(salaryMin!)}+$suffix';
    return 'Up to ₹${_fmt(salaryMax!)}$suffix';
  }

  String _fmt(double v) =>
      v >= 100000 ? '${(v / 100000).toStringAsFixed(1)}L' : v.toStringAsFixed(0);
}
```

#### `lib/models/job_search_response.dart`

```dart
import 'job_listing.dart';

class JobSearchResponse {
  final int total;
  final int page;
  final int size;
  final List<JobListing> items;

  const JobSearchResponse({
    required this.total,
    required this.page,
    required this.size,
    required this.items,
  });

  bool get hasNextPage => page * size < total;

  factory JobSearchResponse.fromJson(Map<String, dynamic> json) =>
      JobSearchResponse(
        total: (json['total'] as num).toInt(),
        page: json['page'] as int,
        size: json['size'] as int,
        items: (json['items'] as List)
            .map((e) => JobListing.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
```

#### `lib/models/sync_report.dart`

```dart
class SyncReport {
  final bool firebaseEnabled;
  final int queriesRun;
  final int jobsFetched;
  final int jobsSaved;
  final List<String> profiles;
  final String startedAt;
  final String finishedAt;
  final String note;

  const SyncReport({
    required this.firebaseEnabled,
    required this.queriesRun,
    required this.jobsFetched,
    required this.jobsSaved,
    required this.profiles,
    required this.startedAt,
    required this.finishedAt,
    required this.note,
  });

  factory SyncReport.fromJson(Map<String, dynamic> json) => SyncReport(
        firebaseEnabled: json['firebaseEnabled'] as bool,
        queriesRun: json['queriesRun'] as int,
        jobsFetched: json['jobsFetched'] as int,
        jobsSaved: json['jobsSaved'] as int,
        profiles: List<String>.from(json['profiles'] ?? []),
        startedAt: json['startedAt'] as String,
        finishedAt: json['finishedAt'] as String,
        note: json['note'] as String,
      );
}
```

---

### Usage Examples

#### Health Check

```dart
final service = JobsApiService();

try {
  final ping = await service.ping();
  print('Service is up: ${ping.message}'); // devdevgo jobs service is running
} on JobsApiException catch (e) {
  print('Service error: $e');
}
```

#### Search Jobs by Keyword

```dart
final response = await service.searchJobs(q: 'flutter developer');

print('Total results: ${response.total}');
for (final job in response.items) {
  print('${job.title} at ${job.company} — ${job.location}');
  print('  Salary: ${job.salaryRange ?? "Not disclosed"}');
  print('  Tags: ${job.tags.join(", ")}');
}
```

#### Search with Location and Tags

```dart
final response = await service.searchJobs(
  q: 'android developer',
  location: 'bangalore',
  tags: ['remote', 'android'],
  page: 1,
  size: 20,
);
```

#### Paginated List (Load More)

```dart
int currentPage = 1;
const int pageSize = 10;
List<JobListing> allJobs = [];

Future<void> loadMore() async {
  final response = await service.searchJobs(
    q: 'flutter',
    page: currentPage,
    size: pageSize,
  );
  allJobs.addAll(response.items);
  if (response.hasNextPage) currentPage++;
}
```

#### Filter by Tag Only

```dart
// Find all remote jobs with no keyword filter
final response = await service.searchJobs(
  tags: ['remote'],
  size: 50,
);
```

#### Trigger Manual Sync (Admin / Debug)

```dart
try {
  final report = await service.triggerSync(batchSize: 4);
  print('Sync complete: ${report.jobsSaved} jobs saved');
  print('Profiles synced: ${report.profiles.join(", ")}');
} on JobsApiException catch (e) {
  print('Sync failed: ${e.message}');
}
```

#### Error Handling Pattern

```dart
Future<void> loadJobs() async {
  try {
    final result = await service.searchJobs(q: 'java');
    // update state with result.items
  } on JobsApiException catch (e) {
    switch (e.statusCode) {
      case 400:
        // Show user-facing validation message
        break;
      case 502:
        // Adzuna upstream error — retry or show generic error
        break;
      case 500:
        // Server error
        break;
    }
  } catch (e) {
    // Network error, timeout, etc.
  }
}
```

---

## pubspec.yaml Dependency

Add the `http` package to your Flutter project:

```yaml
dependencies:
  http: ^1.2.0
```

---

## Notes

- The service is hosted on Render's free tier. The first request after inactivity may have a **cold-start delay of 30–60 seconds**.
- Jobs older than **14 days** are automatically purged from the store.
- The scheduler syncs **8 search profiles per hour** (192 Adzuna API calls/day), staying within the free-tier limit of 250 requests/day.
- The `normalizedText` field is an internal search field — it is safe to ignore in UI display logic.
- All timestamps are **ISO-8601 UTC strings** (e.g. `2026-04-18T10:00:00Z`). Parse with `DateTime.parse(job.fetchedAt)` in Dart.