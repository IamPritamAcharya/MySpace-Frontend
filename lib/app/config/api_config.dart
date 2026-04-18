class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://myspace-springboot.onrender.com';

  static const String _contests = '/api/contests';

  static Uri contestsUri() => Uri.parse('$baseUrl$_contests');

  static const String _leetcodeCalendar = '/api/leetcode/submissions-calender';

  static Uri leetcodeCalendarUri(String username, {int? year}) {
    final query = year != null ? '?year=$year' : '';
    return Uri.parse('$baseUrl$_leetcodeCalendar/$username$query');
  }

  // DevDevGo Jobs Service 
  static const String _jobsBaseUrl =
      'https://devdevgo-jobservice.onrender.com/api/v1/jobs';

  static Uri jobsSearchUri({
    String? q,
    String? location,
    List<String>? tags,
    int page = 1,
    int size = 15,
  }) {
    final params = <String, String>{
      if (q != null && q.isNotEmpty) 'q': q,
      if (location != null && location.isNotEmpty) 'location': location,
      'page': page.toString(),
      'size': size.toString(),
    };

    var uri =
        Uri.parse('$_jobsBaseUrl/search').replace(queryParameters: params);

    if (tags != null && tags.isNotEmpty) {
      final tagQuery =
          tags.map((t) => 'tag=${Uri.encodeQueryComponent(t)}').join('&');
      uri = Uri.parse('${uri.toString()}&$tagQuery');
    }

    return uri;
  }
}
