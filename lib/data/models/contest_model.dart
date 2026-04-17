class Contest {
  final String name;
  final String platform;
  final int startTime;
  final String link;

  const Contest({
    required this.name,
    required this.platform,
    required this.startTime,
    required this.link,
  });

  factory Contest.fromJson(Map<String, dynamic> json) {
    return Contest(
      name: json['name'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      startTime: json['startTime'] as int? ?? 0,
      link: json['link'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'platform': platform,
    'startTime': startTime,
    'link': link,
  };

  DateTime get startDateTime =>
      DateTime.fromMillisecondsSinceEpoch(startTime * 1000);
}
