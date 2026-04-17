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
}
