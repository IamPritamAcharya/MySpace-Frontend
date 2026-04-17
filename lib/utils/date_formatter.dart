class DateFormatter {
  DateFormatter._();

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String formatDateTime(DateTime dateTime) {
    return '${_months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} '
        'at ${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String getTimeRemaining(DateTime startTime) {
    final difference = startTime.difference(DateTime.now());

    if (difference.isNegative) return 'Live';
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    }
    return '${difference.inMinutes}m';
  }

  static String formatForCalendar(DateTime dateTime) {
    final utc = dateTime.toUtc();
    return '${utc.year}'
        '${utc.month.toString().padLeft(2, '0')}'
        '${utc.day.toString().padLeft(2, '0')}'
        'T'
        '${utc.hour.toString().padLeft(2, '0')}'
        '${utc.minute.toString().padLeft(2, '0')}'
        '${utc.second.toString().padLeft(2, '0')}'
        'Z';
  }
}
