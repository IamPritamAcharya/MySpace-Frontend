import 'dart:convert';
import 'package:http/http.dart' as http;

class LeetCodeHeatmapService {
  static const _endpoint = 'https://leetcode.com/graphql';

  Future<Map<String, int>> fetchYearHeatmapBuckets({
    required String username,
    DateTime? endDateInclusive,
  }) async {
    final end = (endDateInclusive ?? DateTime.now());
    final endDate = DateTime(end.year, end.month, end.day);
    final startDate = endDate.subtract(const Duration(days: 364));

    final raw = await _fetchSubmissionCalendarRaw(username: username);

    final dayCounts = <String, int>{};

    raw.forEach((unixStr, count) {
      final seconds = int.tryParse(unixStr);
      if (seconds == null) return;

      final dt = DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000,
        isUtc: true,
      ).toLocal();
      final d = DateTime(dt.year, dt.month, dt.day);

      if (d.isBefore(startDate) || d.isAfter(endDate)) return;

      final iso = _isoDate(d);
      dayCounts[iso] = (dayCounts[iso] ?? 0) + count;
    });

    return _bucketize(dayCounts);
  }

  Future<Map<String, int>> _fetchSubmissionCalendarRaw({
    required String username,
  }) async {
    const query = r'''
      query userProfileCalendar($username: String!) {
        matchedUser(username: $username) {
          userCalendar {
            submissionCalendar
          }
        }
      }
    ''';

    final body = jsonEncode({
      'query': query,
      'variables': {'username': username},
    });

    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Flutter; HeatmapWidget)',
      },
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('LeetCode GraphQL failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    final data = decoded['data'] as Map<String, dynamic>?;
    if (data == null) throw Exception('No data in response');

    final matchedUser = data['matchedUser'] as Map<String, dynamic>?;
    if (matchedUser == null) {
      throw Exception('User not found or profile private: $username');
    }

    final userCalendar = matchedUser['userCalendar'] as Map<String, dynamic>?;
    if (userCalendar == null) throw Exception('No userCalendar for $username');

    final submissionCalendarStr = userCalendar['submissionCalendar'] as String?;
    if (submissionCalendarStr == null) {
      throw Exception('No submissionCalendar string');
    }

    final calendarDecoded =
        jsonDecode(submissionCalendarStr) as Map<String, dynamic>;

    final out = <String, int>{};
    calendarDecoded.forEach((k, v) {
      final key = k.toString();
      final val = (v is int) ? v : int.tryParse(v.toString()) ?? 0;
      out[key] = val;
    });
    return out;
  }

  Map<String, int> _bucketize(Map<String, int> dayCounts) {
    final buckets = <String, int>{};

    for (final e in dayCounts.entries) {
      final c = e.value;
      int b;
      if (c <= 0) {
        b = 0;
      } else if (c <= 2) {
        b = 1;
      } else if (c <= 5) {
        b = 2;
      } else if (c <= 9) {
        b = 3;
      } else {
        b = 4;
      }
      buckets[e.key] = b;
    }

    return buckets;
  }

  String _isoDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
