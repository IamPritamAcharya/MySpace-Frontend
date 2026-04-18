import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myspace/app/config/api_config.dart';
import 'package:myspace/data/models/job_search_response.dart';

class JobsService {
  JobsService._();

  static Future<JobSearchResponse> searchJobs({
    String? q,
    String? location,
    List<String>? tags,
    int page = 1,
    int size = 15,
  }) async {
    final uri = ApiConfig.jobsSearchUri(
      q: q,
      location: location,
      tags: tags,
      page: page,
      size: size,
    );

    final response =
        await http.get(uri).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return JobSearchResponse.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      final body = json.decode(response.body) as Map<String, dynamic>;
      throw Exception(
        body['message'] ?? 'Failed to search jobs (${response.statusCode})',
      );
    }
  }
}
