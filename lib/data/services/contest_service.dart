import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myspace/app/config/api_config.dart';
import 'package:myspace/data/models/contest_model.dart';

class ContestService {
  ContestService._();

  static Future<List<Contest>> getContests() async {
    final response = await http
        .get(ApiConfig.contestsUri())
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body) as List;
      return jsonList
          .map((json) => Contest.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load contests (${response.statusCode})');
    }
  }
}
